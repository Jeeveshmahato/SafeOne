package com.safeone.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.util.concurrent.atomic.AtomicBoolean

/// Fires when a journey's arrival time passes. If the user hasn't tapped
/// "I arrived" (which ends the journey and cancels this alarm), it alerts
/// their contacts natively, so it works with the app closed or the phone
/// locked. Location sharing carries on, now saying they haven't arrived,
/// until they tap "I arrived".
class JourneyAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!SosSender.prefBool(context, "journey_active") ||
            SosSender.prefBool(context, "journey_overdue")
        ) {
            return
        }
        SosSender.setPrefBool(context, "journey_overdue", true)
        val destination = SosSender.prefString(context, "journey_destination").orEmpty()
            .ifBlank { "where I was going" }
        Log.i("JourneyAlarm", "Arrival time passed — alerting contacts")
        SafetyMonitorService.refresh(context) // "You haven't checked in"

        val pending = goAsync()
        val done = AtomicBoolean(false)
        val finish = { if (done.compareAndSet(false, true)) pending.finish() }
        // Same budget as the check-in alarm: hand the SMS over well within
        // the ~10 s a receiver gets.
        Handler(Looper.getMainLooper()).postDelayed({ finish() }, 9_000)
        SosSender.send(context, SosSender.Alert.MissedJourney(destination), locationWaitMs = 4_000) { finish() }
    }
}
