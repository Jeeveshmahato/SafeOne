package com.safeone.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// Time for the next live-location update. The alarm wakes the phone even
/// in deep sleep; the safety service takes it from here.
class LiveShareAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        SafetyMonitorService.onLiveShareAlarm(context)
    }
}
