package com.safeone.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.util.concurrent.atomic.AtomicBoolean

/// Fires when a safety check-in deadline passes. If the user hasn't tapped
/// "I'm safe" (which clears the `checkin_active` flag and cancels this alarm),
/// it sends the SOS NATIVELY via [SosSender] — no Flutter isolate required, so
/// it works even if the app process is dead or the phone is locked. goAsync()
/// keeps the process alive until the SMS "sent" confirmations arrive.
class CheckinAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Only act if a check-in is still active (guards against a race where
        // the user marked safe just as the alarm fired).
        if (!SosSender.prefBool(context, "checkin_active")) return
        SosSender.setPrefBool(context, "checkin_active", false)
        CheckinScheduler.cancel(context) // clears the saved deadline
        SafetyMonitorService.refreshIfRunning() // drop the check-in from the notification
        Log.i("CheckinAlarm", "Check-in deadline passed — sending SOS")
        val pending = goAsync()
        val done = AtomicBoolean(false)
        val finish = { if (done.compareAndSet(false, true)) pending.finish() }
        // A receiver gets ~10 s: wait at most 4 s for a fresh location so the
        // SMS is handed to the system well before then, and stop waiting for
        // the "sent" confirmations rather than overrun.
        Handler(Looper.getMainLooper()).postDelayed({ finish() }, 9_000)
        SosSender.send(context, SosSender.Alert.MissedCheckin, locationWaitMs = 4_000) { finish() }
    }
}
