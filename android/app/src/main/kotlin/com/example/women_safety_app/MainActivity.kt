package com.example.women_safety_app

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity (instead of FlutterActivity) is required by the
// local_auth plugin so the biometric prompt can attach to the activity.
class MainActivity : FlutterFragmentActivity() {
    private val volumeChannelName = "women_safety/volume_button"
    private var volumeChannel: MethodChannel? = null

    private val monitorChannelName = "women_safety/safety_monitor"

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
