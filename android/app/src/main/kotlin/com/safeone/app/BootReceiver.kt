package com.safeone.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/// After a restart (or an app update): sets the check-in and journey
/// deadlines again, since Android drops alarms on reboot, and restarts the
/// SafetyMonitorService IF the user had it on, so the hands-free SOS triggers
/// and any live sharing keep working without the user reopening the app.
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            return
        }
        CheckinScheduler.restoreAfterBoot(context)

        val active = context
            .getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getBoolean("flutter.safety_monitor_active", false)
        if (!active) return

        val i = Intent(context, SafetyMonitorService::class.java).apply {
            this.action = SafetyMonitorService.ACTION_START
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(i)
            } else {
                context.startService(i)
            }
        } catch (_: Exception) {
            // Some phones refuse this until the app is opened once.
        }
    }
}
