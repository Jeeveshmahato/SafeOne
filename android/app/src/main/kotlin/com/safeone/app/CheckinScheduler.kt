package com.safeone.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/// The alarms behind SafeOne's timed safety features:
///
/// - the safety check-in deadline ([CheckinAlarmReceiver]),
/// - the journey arrival deadline ([JourneyAlarmReceiver]),
/// - the next live-location update ([LiveShareAlarmReceiver]).
///
/// Deadlines use setAlarmClock, the most reliable exact alarm: it fires through
/// Doze and is treated like a user alarm. Live updates use an exact
/// allow-while-idle alarm, because a timer inside the app stops counting while
/// the phone sleeps. Android drops every alarm when the phone restarts, so the
/// deadlines are saved and [restoreAfterBoot] sets them again.
object CheckinScheduler {
    private const val PREFS = "FlutterSharedPreferences"
    private const val P = "flutter."

    private const val CHECKIN_CODE = 8201
    private const val JOURNEY_CODE = 8202
    private const val LIVE_CODE = 8203

    // --- Safety check-in ---

    fun schedule(context: Context, triggerAtMillis: Long) {
        prefs(context).edit().putLong(P + "checkin_deadline_ms", triggerAtMillis).apply()
        alarmClock(context, triggerAtMillis, operation(context, CheckinAlarmReceiver::class.java, CHECKIN_CODE))
    }

    fun cancel(context: Context) {
        prefs(context).edit()
            .remove(P + "checkin_deadline_ms")
            .remove(P + "checkin_started_ms")
            .apply()
        alarmManager(context).cancel(operation(context, CheckinAlarmReceiver::class.java, CHECKIN_CODE))
    }

    // --- Journey arrival ---

    fun scheduleJourney(context: Context, triggerAtMillis: Long) {
        alarmClock(context, triggerAtMillis, operation(context, JourneyAlarmReceiver::class.java, JOURNEY_CODE))
    }

    fun cancelJourney(context: Context) {
        alarmManager(context).cancel(operation(context, JourneyAlarmReceiver::class.java, JOURNEY_CODE))
    }

    // --- Live location updates ---

    fun scheduleLiveTick(context: Context, triggerAtMillis: Long) {
        val am = alarmManager(context)
        val op = operation(context, LiveShareAlarmReceiver::class.java, LIVE_CODE)
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || am.canScheduleExactAlarms()
        if (exact) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, op)
        } else {
            // Without exact-alarm access Android may delay it a little.
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, op)
        }
    }

    fun cancelLiveTick(context: Context) {
        alarmManager(context).cancel(operation(context, LiveShareAlarmReceiver::class.java, LIVE_CODE))
    }

    /// The phone restarted: set the deadlines again. One that passed while the
    /// phone was off fires shortly after start-up, so the alert still goes out.
    fun restoreAfterBoot(context: Context) {
        val p = prefs(context)
        val soon = System.currentTimeMillis() + 10_000
        if (p.getBoolean(P + "checkin_active", false)) {
            val at = p.getLong(P + "checkin_deadline_ms", 0L)
            if (at > 0) schedule(context, maxOf(at, soon))
        }
        if (p.getBoolean(P + "journey_active", false) &&
            !p.getBoolean(P + "journey_overdue", false)
        ) {
            val at = p.getLong(P + "journey_deadline_ms", 0L)
            if (at > 0) scheduleJourney(context, maxOf(at, soon))
        }
    }

    private fun alarmClock(context: Context, triggerAtMillis: Long, op: PendingIntent) {
        val show = PendingIntent.getActivity(
            context,
            0,
            context.packageManager.getLaunchIntentForPackage(context.packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        alarmManager(context).setAlarmClock(AlarmManager.AlarmClockInfo(triggerAtMillis, show), op)
    }

    private fun alarmManager(context: Context) =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun operation(context: Context, receiver: Class<*>, code: Int): PendingIntent {
        val intent = Intent(context, receiver)
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getBroadcast(context, code, intent, flags)
    }
}
