package com.safeone.app

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity (instead of FlutterActivity) is required by the
// local_auth plugin so the biometric prompt can attach to the activity.
class MainActivity : FlutterFragmentActivity() {
    private val volumeChannelName = "women_safety/volume_button"
    private var volumeChannel: MethodChannel? = null

    private val monitorChannelName = "women_safety/safety_monitor"
    private val ringtoneChannelName = "com.safeone.app/ringtone"
    private val smsChannelName = "com.safeone.app/sms"
    private val deviceChannelName = "com.safeone.app/device"
    private val vaultChannelName = "com.safeone.app/vault"

    // The system ringtone picker: lists the phone's ringtones and lets the
    // user add their own sound file, with no storage permission needed.
    private var pendingPick: MethodChannel.Result? = null
    private val ringtonePicker =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { res ->
            val callback = pendingPick ?: return@registerForActivityResult
            pendingPick = null
            if (res.resultCode != Activity.RESULT_OK) {
                callback.success(null) // cancelled
                return@registerForActivityResult
            }
            @Suppress("DEPRECATION")
            val uri: Uri? = res.data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
            if (uri == null) {
                callback.success(mapOf("uri" to null, "title" to null))
            } else {
                callback.success(
                    mapOf(
                        "uri" to uri.toString(),
                        "title" to RingtonePlayer.title(this, uri.toString()),
                    ),
                )
            }
        }

    // Allow the app to appear over the lock screen and wake the screen, so the
    // scheduled fake call's full-screen intent shows like a real incoming call
    // when the phone is locked.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
        // Nothing SafeOne shows (contacts, medical info, PIN entry) may be
        // captured: no screenshots, no screen recording or casting by other
        // apps, and a blank recent-apps thumbnail.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(false)
        }
        // Robust autostart: if the user has any hands-free trigger enabled (or
        // live-sharing is active), (re)start the monitor service NATIVELY on
        // every app open — independent of the Dart MethodChannel timing and even
        // while the app-lock PIN gate is still showing.
        syncService()
    }

    override fun onResume() {
        super.onResume()
        syncService()
    }

    private fun prefs() =
        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    private fun anyTriggerEnabled(): Boolean {
        val p = prefs()
        return p.getBoolean("flutter.shake_enabled", false) ||
            p.getBoolean("flutter.volume_trigger", false) ||
            p.getBoolean("flutter.power_trigger", false)
    }

    private fun liveSharingActive(): Boolean =
        prefs().getBoolean("flutter.live_sharing_active", false)

    /// The foreground service must run while ANY trigger is on OR live-location
    /// sharing is active.
    private fun syncService() {
        if (anyTriggerEnabled() || liveSharingActive()) startMonitor() else stopMonitor()
    }

    private fun startMonitor() {
        try {
            val i = Intent(this, SafetyMonitorService::class.java).apply {
                action = SafetyMonitorService.ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(i)
            } else {
                startService(i)
            }
            prefs().edit().putBoolean("flutter.safety_monitor_active", true).apply()
            Log.i("SafetyMonitor", "startMonitor requested")
        } catch (e: Exception) {
            Log.e("SafetyMonitor", "startMonitor failed", e)
        }
    }

    private fun stopMonitor() {
        try {
            val i = Intent(this, SafetyMonitorService::class.java).apply {
                action = SafetyMonitorService.ACTION_STOP
            }
            startService(i)
            prefs().edit().putBoolean("flutter.safety_monitor_active", false).apply()
        } catch (e: Exception) {
            Log.e("SafetyMonitor", "stopMonitor failed", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        volumeChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            volumeChannelName,
        )

        // Start/stop the always-on SafetyMonitorService that keeps the
        // hands-free SOS triggers alive when locked / backgrounded.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            monitorChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                // Trigger settings already persisted by Dart; just re-evaluate
                // whether the service should be running (also respects live-share).
                "start", "stop" -> {
                    syncService()
                    result.success(true)
                }
                // Live location sharing — runs inside the foreground service so
                // it survives the app being swiped away (unlike the old
                // android_alarm_manager background isolate).
                "startLiveShare" -> {
                    val interval = (call.argument<Number>("intervalMillis"))?.toLong()
                        ?: 120_000L
                    prefs().edit().putLong("live_share_interval_ms", interval).apply()
                    SosSender.setPrefBool(this, "live_sharing_active", true)
                    startMonitor() // (re)start → service picks up the live-share loop
                    result.success(true)
                }
                "stopLiveShare" -> {
                    SosSender.setPrefBool(this, "live_sharing_active", false)
                    SosSender.cancelFollowMe(this)
                    syncService() // keep running if a trigger is on, else stop
                    result.success(true)
                }
                // Native safety check-in: schedule an exact alarm that sends the
                // SOS if not cancelled. Replaces the fragile android_alarm_manager
                // background isolate, which OEMs block when the app is swiped away.
                "scheduleCheckin" -> {
                    val at = (call.argument<Number>("epochMillis"))?.toLong()
                    if (at == null) {
                        result.error("bad_args", "epochMillis required", null)
                    } else {
                        SosSender.setPrefBool(this, "checkin_active", true)
                        CheckinScheduler.schedule(this, at)
                        result.success(true)
                    }
                }
                "cancelCheckin" -> {
                    SosSender.setPrefBool(this, "checkin_active", false)
                    CheckinScheduler.cancel(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Emergency SMS: one message per contact, straight from the phone
        // (Google Play "Physical safety / emergency alerts" exception).
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            smsChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "canSend" -> result.success(DirectSms.canSend(this))
                "send" -> {
                    val numbers = call.argument<List<String>>("numbers").orEmpty()
                    val message = call.argument<String>("message").orEmpty()
                    if (!DirectSms.canSend(this)) {
                        result.error("no_permission", "SEND_SMS not granted", null)
                        return@setMethodCallHandler
                    }
                    DirectSms.send(this, numbers, message) { sent, failed ->
                        result.success(mapOf("sent" to sent, "failed" to failed))
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Lets the app lock check whether the phone itself is locked: SafeOne
        // may be shown over the lock screen (fake call), and must never show
        // unlocked content there.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deviceChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isKeyguardLocked" -> {
                    val km = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                    result.success(km.isKeyguardLocked)
                }
                "securityStatus" -> result.success(
                    mapOf(
                        "binding" to HardwareKeys.bindingLevel(),
                        "rooted" to HardwareKeys.looksRooted(),
                    ),
                )
                else -> result.notImplemented()
            }
        }

        // Hardware-backed keys for the PIN and the encrypted data vault.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            vaultChannelName,
        ).setMethodCallHandler { call, result ->
            // Key generation and StrongBox calls can take a while: keep them
            // off the UI thread and reply on it.
            Thread {
                val reply: () -> Unit = try {
                    val value: Any? = when (call.method) {
                        "bind" -> HardwareKeys.bind(call.argument<ByteArray>("data")!!)
                        "ensureRecovery" -> HardwareKeys.ensureRecovery(this)
                        "recoveryWrap" -> HardwareKeys.recoveryWrap(call.argument<ByteArray>("data")!!)
                        "recoveryUnwrap" -> HardwareKeys.recoveryUnwrap(call.argument<ByteArray>("data")!!)
                        "deleteAll" -> {
                            HardwareKeys.deleteAll()
                            true
                        }
                        else -> null.also {
                            runOnUiThread { result.notImplemented() }
                            return@Thread
                        }
                    }
                    { result.success(value) }
                } catch (e: HardwareKeys.NotAuthenticated) {
                    { result.error("not_authenticated", "Strong authentication required", null) }
                } catch (e: HardwareKeys.Invalidated) {
                    { result.error("invalidated", "Recovery key no longer usable", null) }
                } catch (e: Exception) {
                    { result.error("unavailable", e.javaClass.simpleName, null) }
                }
                runOnUiThread(reply)
            }.start()
        }

        // Fake-call ringtone: pick, name and play the phone's ringtones.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ringtoneChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pick" -> {
                    if (pendingPick != null) {
                        result.error("busy", "Picker already open", null)
                        return@setMethodCallHandler
                    }
                    val current = call.argument<String>("current")
                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_RINGTONE)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                        putExtra(
                            RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI,
                            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
                        )
                        putExtra(
                            RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                            current?.let { Uri.parse(it) }
                                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
                        )
                    }
                    try {
                        pendingPick = result
                        ringtonePicker.launch(intent)
                    } catch (e: Exception) {
                        pendingPick = null
                        result.error("unavailable", "No ringtone picker", null)
                    }
                }
                "title" -> result.success(RingtonePlayer.title(this, call.argument("uri")))
                "play" -> result.success(RingtonePlayer.play(this, call.argument("uri")))
                "stop" -> {
                    RingtonePlayer.stop()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Forward volume key presses to Flutter for the "triple-press to SOS"
    // feature, but DO NOT consume the event so the volume still changes.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN &&
            (event.keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
                event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)
        ) {
            volumeChannel?.invokeMethod("volumePressed", null)
        }
        return super.dispatchKeyEvent(event)
    }
}
