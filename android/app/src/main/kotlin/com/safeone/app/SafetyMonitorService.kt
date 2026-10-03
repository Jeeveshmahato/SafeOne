package com.safeone.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import kotlin.math.sqrt

/// Always-on foreground service that keeps the hands-free SOS triggers working
/// when the app is in the background or the screen is locked — exactly when the
/// in-app (Activity/Flutter) listeners are suspended by Android.
///
/// It detects three triggers natively and, on any of them, sends the SOS
/// (location + SMS) directly. SOS sending is done natively (SmsManager +
/// LocationManager) so it works even if the Flutter engine/app process is dead.
/// It reads the SAME data the Dart side writes via shared_preferences
/// (FlutterSharedPreferences, keys prefixed "flutter.").
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

        // Shake: ~2.7g spike, need a couple within the window to avoid accidents.
        private const val SHAKE_G = 2.7f
        private const val SHAKE_WINDOW_MS = 1_000L
        private const val SHAKE_COUNT = 2

        // Volume / power: three presses close together.
        private const val MULTI_WINDOW_MS = 1_800L
        private const val MULTI_COUNT = 3

        private const val DEFAULT_LIVE_INTERVAL_MS = 120_000L
    }

    private var sensorManager: SensorManager? = null
    private var lastSosAt = 0L
    private var sourcesRegistered = false

    // Live-location ("Follow Me") sharing runs as a self-rescheduling loop on
    // the service's thread. Because it lives inside a FOREGROUND service, it
    // keeps running when the app is swiped away — unlike the old background
    // alarm-isolate, which OEMs killed.
    private val liveShareHandler = Handler(Looper.getMainLooper())
    private var liveShareRunning = false
    private val liveShareRunnable = object : Runnable {
        override fun run() {
            if (!prefBool("live_sharing_active")) {
                liveShareRunning = false
                return
            }
            SosSender.sendFollowMe(this@SafetyMonitorService)
            liveShareHandler.postDelayed(this, liveShareIntervalMs())
        }
    }

    private val shakeTimes = ArrayDeque<Long>()
    private val volumeTimes = ArrayDeque<Long>()
    private val powerTimes = ArrayDeque<Long>()

    // Volume button changes broadcast this (works while locked).
    private val volumeReceiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) {
            if (!prefBool("volume_trigger")) return
            recordPress(volumeTimes, "volume")
        }
    }

    // Power button can't be observed directly; screen on/off toggles are the
    // proxy used by most "press power N times" features.
    private val powerReceiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context?, i: Intent?) {
            if (!prefBool("power_trigger")) return
            recordPress(powerTimes, "power")
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "onStartCommand action=${intent?.action}")
        if (intent?.action == ACTION_STOP) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        try {
            startForeground(NOTIF_ID, buildNotification())
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed", e)
        }

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
            sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.let {
                sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
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
                powerReceiver,
                IntentFilter().apply {
                    addAction(Intent.ACTION_SCREEN_ON)
                    addAction(Intent.ACTION_SCREEN_OFF)
                },
                ContextCompat.RECEIVER_NOT_EXPORTED,
            )
        }.onFailure { Log.e(TAG, "power receiver register failed", it) }
    }

    // --- Live location sharing ---

    private fun liveShareIntervalMs(): Long =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getLong("live_share_interval_ms", DEFAULT_LIVE_INTERVAL_MS)

    /// Start or stop the live-share loop to match the persisted flag.
    private fun syncLiveShare() {
        val active = prefBool("live_sharing_active")
        if (active && !liveShareRunning) {
            liveShareRunning = true
            // Send the first update immediately, then repeat on the interval.
            liveShareHandler.post(liveShareRunnable)
        } else if (!active && liveShareRunning) {
            liveShareRunning = false
            liveShareHandler.removeCallbacks(liveShareRunnable)
        }
    }

    override fun onDestroy() {
        liveShareHandler.removeCallbacks(liveShareRunnable)
        sensorManager?.unregisterListener(this)
        runCatching { unregisterReceiver(volumeReceiver) }
        runCatching { unregisterReceiver(powerReceiver) }
        super.onDestroy()
    }

    // --- Shake detection ---

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
        // Same native sender used by the background check-in deadline.
        SosSender.send(this)
    }

    // --- Preferences (read what Flutter wrote) ---

    private fun prefBool(key: String): Boolean =
        getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(P + key, false)

    // --- Foreground notification ---

    private fun buildNotification(): Notification {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Safety mode",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Keeps shake / volume / power SOS working when locked."
                setShowBadge(false)
            }
            nm.createNotificationChannel(channel)
        }

        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val pi = PendingIntent.getActivity(
            this, 0, launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Safety mode active")
            .setContentText("Shake / volume / power can send an SOS.")
            .setSmallIcon(R.drawable.ic_stat_safeone)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pi)
            .build()
    }
}
