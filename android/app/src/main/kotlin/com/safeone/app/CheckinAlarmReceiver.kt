package com.safeone.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/// Fires when a safety check-in deadline passes. If the user hasn't tapped
/// "I'm safe" (which clears the `checkin_active` flag and cancels this alarm),
/// it sends the SOS NATIVELY via [SosSender] — no Flutter isolate required, so
/// it works even if the app process is dead or the phone is locked.
class CheckinAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Only act if a check-in is still active (guards against a race where
        // the user marked safe just as the alarm fired).
        if (!SosSender.prefBool(context, "checkin_active")) return
        SosSender.setPrefBool(context, "checkin_active", false)
        Log.i("CheckinAlarm", "Check-in deadline passed — sending SOS")
        SosSender.send(context)
    }
}
