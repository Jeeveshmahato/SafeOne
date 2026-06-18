package com.safeone.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/// Restarts the SafetyMonitorService after a reboot IF the user had it on, so
/// the hands-free SOS triggers keep working without the user reopening the app.
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            return
        }
        val active = context
            .getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getBoolean("flutter.safety_monitor_active", false)
        if (!active) return

        val i = Intent(context, SafetyMonitorService::class.java).apply {
            this.action = SafetyMonitorService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(i)
        } else {
            context.startService(i)
        }
    }
}
