package com.contentwhale.safeone

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/// Schedules / cancels the native safety check-in deadline alarm. Uses
/// setAlarmClock — the most reliable exact alarm (fires through Doze, treated as
/// a user alarm) — pointed at [CheckinAlarmReceiver].
object CheckinScheduler {
    private const val REQUEST_CODE = 8201

    fun schedule(context: Context, triggerAtMillis: Long) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val show = PendingIntent.getActivity(
            context,
            0,
            context.packageManager.getLaunchIntentForPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        am.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAtMillis, show), operation(context))
    }

    fun cancel(context: Context) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(operation(context))
    }

    private fun operation(context: Context): PendingIntent {
        val intent = Intent(context, CheckinAlarmReceiver::class.java)
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getBroadcast(context, REQUEST_CODE, intent, flags)
    }
}
