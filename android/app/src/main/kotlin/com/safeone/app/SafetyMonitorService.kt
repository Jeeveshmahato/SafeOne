package com.safeone.app

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.sqrt

/// Always-on foreground service that keeps the hands-free SOS triggers working
/// when the app is in the background or the screen is locked — exactly when the
/// in-app (Activity/Flutter) listeners are suspended by Android.
///
/// It detects three triggers natively and, on any of them, sends the SOS
/// (location + SMS) directly. It also runs live location sharing: after an
/// SOS, during Follow Me and during a journey. Everything is done natively
/// (SmsManager + LocationManager) so it works even if the Flutter engine/app
/// process is dead. It reads the SAME data the Dart side writes via
/// shared_preferences (FlutterSharedPreferences, keys prefixed "flutter.").
class SafetyMonitorService : Service(), SensorEventListener {

    companion object {
        const val ACTION_START = "women_safety.START_MONITOR"
        const val ACTION_STOP = "women_safety.STOP_MONITOR"

        private const val TAG = "SafetyMonitor"
        private const val CHANNEL_ID = "safety_monitor"
        private const val NOTIF_ID = 9100

        // Flutter shared_preferences file + key prefix.
        private const val PREFS = "FlutterSharedPreferences"
        private const val P = "flutter."

        // Don't fire two SOS messages within this window (debounce real triggers
        // and avoid loops).
        private const val SOS_COOLDOWN_MS = 15_000L

        // Shake: a few hard shakes, not one bump. Readings above ~2.7g count
        // as one shake only if they're at least SHAKE_GAP_MS apart (one jolt
        // spans several readings), and SHAKE_COUNT of them must come within
        // SHAKE_WINDOW_MS. A dropped phone or a bumpy ride doesn't do that.
        private const val SHAKE_G = 2.7f
        private const val SHAKE_GAP_MS = 150L
        private const val SHAKE_WINDOW_MS = 1_500L
        private const val SHAKE_COUNT = 3

        // Volume / power: three presses close together.
        private const val MULTI_WINDOW_MS = 1_800L
        private const val MULTI_COUNT = 3

        private const val DEFAULT_LIVE_INTERVAL_MS = 120_000L
        private const val MIN_LIVE_INTERVAL_MS = 60_000L
        // Location wait (20 s) plus handing the SMS over.
        private const val LIVE_TICK_BUDGET_MS = 45_000L

        // The running service, so an alarm can hand it the next update.
        @Volatile
        private var instance: SafetyMonitorService? = null

        /// The live-update alarm went off. The service sends it; if Android
        /// stopped the service meanwhile, starting it again sends any update
        /// that's due.
        fun onLiveShareAlarm(context: Context) {
            val running = instance
            if (running != null) {
                running.liveTick()
                return
            }
            start(context)
        }

        /// Re-show the notification after something changed in the background
        /// (a journey running late).
        fun refresh(context: Context) {
            instance?.refreshNotification() ?: start(context)
        }

        /// Re-show the notification if the service is running, without
        /// starting it (a check-in that just ended needs no service).
        fun refreshIfRunning() {
            instance?.refreshNotification()
        }

        private fun start(context: Context) {
            try {
                val i = Intent(context, SafetyMonitorService::class.java).setAction(ACTION_START)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(i)
                } else {
                    context.startService(i)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Couldn't start the safety service", e)
            }
        }
    }

    private var sensorManager: SensorManager? = null
    private var accelerometerWakes = false
    private var lastSosAt = 0L
    private var sourcesRegistered = false

    // Live updates: each one is an exact alarm ([CheckinScheduler]), because a
    // timer here stops counting while the phone sleeps. While one is being
    // sent, a short wake lock keeps the phone awake.
    private val sendingLiveUpdate = AtomicBoolean(false)
    private val handler = Handler(Looper.getMainLooper())

    // With the screen off the phone sleeps and the accelerometer stops
    // reporting, so shake to SOS would only work with the screen on. While
    // shake is on and the screen is off, this keeps the processor (not the
    // screen) awake. Not needed if the sensor wakes the phone by itself.
    private var shakeWakeLock: PowerManager.WakeLock? = null

    private val shakeTimes = ArrayDeque<Long>()
    private var lastShakeAt = 0L
    private val volumeTimes = ArrayDeque<Long>()
    private val powerTimes = ArrayDeque<Long>()

    // Volume button changes broadcast this (works while locked).
    private val volumeReceiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) {
            if (!prefBool("volume_trigger")) return
            recordPress(volumeTimes, "volume")
        }
    }

    // The phone is about to power off or restart. Android waits a few
    // seconds for apps to finish; goAsync() holds the shutdown until the SMS
    // is handed over (or the safety timeout). Factory reset from Settings
    // also restarts the phone, so it arrives here too. A forced power-off
    // (holding the button 10+ s) or a pulled battery sends nothing.
    private val shutdownReceiver = object : BroadcastReceiver() {
        private var handled = false
        override fun onReceive(c: Context, i: Intent?) {
            if (handled || !SosSender.shouldAlertOnShutdown(c)) return
            handled = true
            Log.i(TAG, "Shutdown (${i?.action}) — alerting contacts")
            val pending = goAsync()
            val finished = AtomicBoolean(false)
            val finish = { if (finished.compareAndSet(false, true)) pending.finish() }
            Handler(Looper.getMainLooper()).postDelayed({ finish() }, 8_000)
            SosSender.sendShutdownAlert(c) { finish() }
        }
    }

    // Screen on/off: keeps shake working with the screen off, and is the
    // proxy for the power button (it can't be observed directly; "press power
    // N times" features count screen toggles).
    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) {
            updateShakeWakeLock(screenOff = i?.action == Intent.ACTION_SCREEN_OFF)
            if (prefBool("power_trigger")) recordPress(powerTimes, "power")
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "onStartCommand action=${intent?.action}")
        if (intent?.action == ACTION_STOP) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        startInForeground()

        registerSources()
        syncLiveShare()

        Log.i(TAG, "SafetyMonitorService started")
        // START_STICKY: the OS restarts the service if it's killed while active.
        return START_STICKY
    }

    /// Register the trigger sources exactly once (onStartCommand may be called
    /// repeatedly to re-evaluate live-share state).
    private fun registerSources() {
        if (sourcesRegistered) return
        sourcesRegistered = true

        // Each source is registered defensively — a failure in one (e.g. an OEM
        // that doesn't broadcast volume changes) must NOT stop the others.
        try {
            sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
            // Prefer an accelerometer that wakes the phone by itself (few
            // phones have one); otherwise the wake lock above covers it.
            val wakeUp = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER, true)
            val sensor = wakeUp ?: sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
            accelerometerWakes = wakeUp != null
            sensor?.let {
                // GAME rate (~50 Hz): UI rate can miss the peak of a shake.
                sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
            }
        } catch (e: Exception) {
            Log.e(TAG, "accelerometer register failed", e)
        }

        // Android 14+ REQUIRES an export flag for dynamically-registered
        // receivers of non-system broadcasts; VOLUME_CHANGED_ACTION is not a
        // protected broadcast, so registerReceiver() without the flag throws a
        // SecurityException — which previously crashed the whole service and
        // broke ALL three triggers. RECEIVER_NOT_EXPORTED (system can still
        // deliver) is the correct flag here.
        runCatching {
            ContextCompat.registerReceiver(
                this,
                volumeReceiver,
                IntentFilter("android.media.VOLUME_CHANGED_ACTION"),
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
        }.onFailure { Log.e(TAG, "volume receiver register failed", it) }

        runCatching {
            ContextCompat.registerReceiver(
                this,
                screenReceiver,
                IntentFilter().apply {
                    addAction(Intent.ACTION_SCREEN_ON)
                    addAction(Intent.ACTION_SCREEN_OFF)
                },
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
        }.onFailure { Log.e(TAG, "screen receiver register failed", it) }

        runCatching {
            ContextCompat.registerReceiver(
                this,
                shutdownReceiver,
                IntentFilter().apply {
                    addAction(Intent.ACTION_SHUTDOWN)
                    addAction(Intent.ACTION_REBOOT)
                    // Some manufacturers' "fast" power-off.
                    addAction("android.intent.action.QUICKBOOT_POWEROFF")
                    addAction("com.htc.intent.action.QUICKBOOT_POWEROFF")
                },
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
        }.onFailure { Log.e(TAG, "shutdown receiver register failed", it) }

        // Started with the screen already off (after a reboot, say).
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        updateShakeWakeLock(screenOff = !pm.isInteractive)
    }

    /// While live location is being shared, run as a LOCATION foreground
    /// service: that's what lets Android give us the location with the app
    /// in the background ("While using the app" permission is enough). It
    /// can only be started that way while the app is on screen (when the
    /// user starts sharing) or with "Allow all the time"; if Android refuses
    /// (e.g. restarted after being killed), fall back to the plain type and
    /// use the last known fix.
    private fun startInForeground() {
        val notification = buildNotification()
        val special = if (Build.VERSION.SDK_INT >= 34) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            0
        }
        val wantsLocation = prefBool("live_sharing_active") && hasLocationPermission()
        if (wantsLocation && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                ServiceCompat.startForeground(
                    this, NOTIF_ID, notification,
                    special or ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
                )
                return
            } catch (e: Exception) {
                Log.w(TAG, "location foreground type refused; continuing without", e)
            }
        }
        try {
            if (special != 0) {
                ServiceCompat.startForeground(this, NOTIF_ID, notification, special)
            } else {
                startForeground(NOTIF_ID, notification)
            }
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed", e)
        }
    }

    private fun refreshNotification() {
        try {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(NOTIF_ID, buildNotification())
        } catch (e: Exception) {
            Log.e(TAG, "Couldn't update the notification", e)
        }
    }

    private fun hasLocationPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun hasBackgroundLocation(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_BACKGROUND_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    // --- Live location sharing ---

    private fun liveShareIntervalMs(): Long =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getLong("live_share_interval_ms", DEFAULT_LIVE_INTERVAL_MS)
            .coerceAtLeast(MIN_LIVE_INTERVAL_MS)

    /// "every 2 min", "every hour", "every 3 hours".
    private fun everyText(): String {
        val minutes = (liveShareIntervalMs() / 60_000).coerceAtLeast(1)
        return when {
            minutes == 60L -> "every hour"
            minutes % 60 == 0L -> "every ${minutes / 60} hours"
            else -> "every $minutes min"
        }
    }

    /// Schedule the next update to match the saved session, or cancel it
    /// when sharing is off. Called on every start, so a session carries on
    /// after the service or the phone restarts.
    private fun syncLiveShare() {
        if (!prefBool("live_sharing_active")) {
            CheckinScheduler.cancelLiveTick(this)
            return
        }
        val now = System.currentTimeMillis()
        val p = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val last = p.getLong(P + "live_share_last_sent_ms", 0L)
            .takeIf { it > 0 } ?: p.getLong("live_share_last_sent_ms", 0L)
        val started = p.getLong(P + "live_share_started_ms", 0L).takeIf { it > 0 } ?: now
        val mode = p.getString(P + "live_share_mode", null) ?: "sos"
        val due = when {
            last > 0 -> last + liveShareIntervalMs()
            // The SOS itself just carried a fresh location.
            mode == "sos" -> started + liveShareIntervalMs()
            // Follow Me and a journey start with a text straight away.
            else -> now
        }
        if (due <= now) liveTick() else CheckinScheduler.scheduleLiveTick(this, due)
    }

    /// Send one live update now, then set the alarm for the next.
    private fun liveTick() {
        if (!prefBool("live_sharing_active")) return
        if (!sendingLiveUpdate.compareAndSet(false, true)) return
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "SafeOne:liveUpdate")
        wakeLock.acquire(LIVE_TICK_BUDGET_MS + 5_000)

        val finished = AtomicBoolean(false)
        val finish = {
            if (finished.compareAndSet(false, true)) {
                sendingLiveUpdate.set(false)
                if (prefBool("live_sharing_active")) {
                    CheckinScheduler.scheduleLiveTick(
                        this, System.currentTimeMillis() + liveShareIntervalMs(),
                    )
                }
                if (wakeLock.isHeld) wakeLock.release()
            }
        }
        handler.postDelayed({ finish() }, LIVE_TICK_BUDGET_MS)
        SosSender.sendLiveUpdate(this) { handler.post { finish() } }
    }

    override fun onDestroy() {
        instance = null
        handler.removeCallbacksAndMessages(null)
        sensorManager?.unregisterListener(this)
        releaseShakeWakeLock()
        runCatching { unregisterReceiver(volumeReceiver) }
        runCatching { unregisterReceiver(screenReceiver) }
        runCatching { unregisterReceiver(shutdownReceiver) }
        super.onDestroy()
    }

    // --- Shake detection ---

    @SuppressLint("WakelockTimeout") // released as soon as the screen turns on
    private fun updateShakeWakeLock(screenOff: Boolean) {
        val needed = screenOff && !accelerometerWakes && prefBool("shake_enabled")
        if (needed && shakeWakeLock == null) {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            shakeWakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "SafeOne:shake")
                .apply {
                    setReferenceCounted(false)
                    acquire()
                }
        } else if (!needed) {
            releaseShakeWakeLock()
        }
    }

    private fun releaseShakeWakeLock() {
        shakeWakeLock?.let { if (it.isHeld) it.release() }
        shakeWakeLock = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_ACCELEROMETER) return
        if (!prefBool("shake_enabled")) return
        val gForce = sqrt(
            (event.values[0] * event.values[0] +
                event.values[1] * event.values[1] +
                event.values[2] * event.values[2]).toDouble(),
        ) / SensorManager.GRAVITY_EARTH
        if (gForce < SHAKE_G) return

        val now = System.currentTimeMillis()
        if (now - lastShakeAt < SHAKE_GAP_MS) return // same jolt
        lastShakeAt = now
        shakeTimes.addLast(now)
        while (shakeTimes.isNotEmpty() && now - shakeTimes.first() > SHAKE_WINDOW_MS) {
            shakeTimes.removeFirst()
        }
        if (shakeTimes.size >= SHAKE_COUNT) {
            shakeTimes.clear()
            triggerSos("shake")
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    // --- Volume / power press counting ---

    private fun recordPress(times: ArrayDeque<Long>, source: String) {
        val now = System.currentTimeMillis()
        times.addLast(now)
        while (times.isNotEmpty() && now - times.first() > MULTI_WINDOW_MS) {
            times.removeFirst()
        }
        if (times.size >= MULTI_COUNT) {
            times.clear()
            triggerSos(source)
        }
    }

    // --- SOS ---

    private fun triggerSos(source: String) {
        val now = System.currentTimeMillis()
        if (now - lastSosAt < SOS_COOLDOWN_MS) return
        lastSosAt = now
        Log.i(TAG, "SOS triggered by $source")
        // Hold the phone awake until the text is handed over.
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "SafeOne:sos")
        wakeLock.acquire(30_000)
        val sent = SosSender.send(this, SosSender.Alert.Trigger(source)) {
            if (wakeLock.isHeld) wakeLock.release()
        }
        if (sent) maybeStartLiveSharing()
    }

    /// Like an SOS from the app: keep sending the location until the user
    /// taps "I'm safe", if they have live updates on. Only with "Allow all the
    /// time" location: started from the background, Android gives no location
    /// otherwise, and contacts would only get "can't find my location".
    private fun maybeStartLiveSharing() {
        val p = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!p.getBoolean(P + "live_updates", true)) return
        if (!hasLocationPermission() || !hasBackgroundLocation()) return
        val mode = p.getString(P + "live_share_mode", null)
        if (prefBool("live_sharing_active") && mode == "sos") return
        p.edit()
            .putLong("live_share_interval_ms", DEFAULT_LIVE_INTERVAL_MS)
            .putString(P + "live_share_mode", "sos")
            .putLong(P + "live_share_started_ms", System.currentTimeMillis())
            .putLong(P + "live_share_count", 0L)
            .remove(P + "live_share_last_sent_ms")
            .putBoolean(P + "live_share_no_fix_sent", false)
            .putBoolean(P + "live_sharing_active", true)
            // An SOS ends a journey: "I still need help" from here on.
            .remove(P + "journey_active")
            .remove(P + "journey_overdue")
            .remove(P + "journey_destination")
            .remove(P + "journey_deadline_ms")
            .commit()
        CheckinScheduler.cancelJourney(this)
        startInForeground() // now as a location service too
        syncLiveShare()
    }

    // --- Preferences (read what Flutter wrote) ---

    private fun prefBool(key: String): Boolean =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(P + key, false)

    private fun prefString(key: String): String? =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(P + key, null)

    private fun prefLong(key: String): Long = SosSender.prefLong(this, key)

    // --- Foreground notification ---

    private fun buildNotification(): Notification {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Safety mode",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Lets your SOS shortcuts and location sharing work while the phone is locked."
                setShowBadge(false)
            }
            nm.createNotificationChannel(channel)
        }

        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val pi = PendingIntent.getActivity(
            this, 0, launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        // Be clear when location is being shared: the user must always know.
        val (title, text) = notificationText()
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setSmallIcon(R.drawable.ic_stat_safeone)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pi)
            .build()
    }

    private fun notificationText(): Pair<String, String> {
        if (!prefBool("live_sharing_active")) {
            val checkinAt = prefLong("checkin_deadline_ms")
            if (prefBool("checkin_active") && checkinAt > 0) {
                val at = java.text.DateFormat.getTimeInstance(java.text.DateFormat.SHORT)
                    .format(java.util.Date(checkinAt))
                return "Check-in timer is on" to
                    "Your contacts get an alert at $at unless you tap \"I'm safe\" in SafeOne."
            }
            return "Safety mode is on" to "Ready to alert your contacts, even with the screen locked."
        }
        return when (prefString("live_share_mode")) {
            "follow_me" -> "Sharing your location" to
                "Your contacts get your location ${everyText()} until you tap Stop sharing in SafeOne."
            "journey" -> if (prefBool("journey_overdue")) {
                "You haven't checked in" to
                    "Your contacts were alerted. They keep getting your location until you tap \"I arrived\" in SafeOne."
            } else {
                "On a journey" to
                    "Your contacts get your location ${everyText()}. Tap \"I arrived\" in SafeOne when you get there."
            }
            else -> "Sharing your live location" to
                "Your contacts get an update ${everyText()} until you tap \"I'm safe\"."
        }
    }
}
