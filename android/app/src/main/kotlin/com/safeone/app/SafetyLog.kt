package com.safeone.app

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/// Records what the background side did (an SOS from a shake, a missed
/// check-in alert, a switch-off alert) so it shows up in the app's Records.
///
/// The log itself is encrypted by the Dart side, which this process can't
/// reach while the app is closed. So each event is written as its own
/// "native_event_*" preference, and the app moves them into the encrypted log
/// (and deletes them) the next time it opens. One key per event means the
/// two sides never overwrite each other's writes. No location is stored here:
/// the texts that went out already carry it.
object SafetyLog {
    private const val PREFS = "FlutterSharedPreferences"
    const val KEY_PREFIX = "flutter.native_event_"

    // Same names as the Dart SafetyEventType enum.
    const val SOS = "sos"
    const val CHECK_IN = "checkIn"
    const val LOCATION_SHARED = "locationShared"

    fun add(context: Context, type: String, description: String, contacts: List<String> = emptyList()) {
        try {
            val now = System.currentTimeMillis()
            val id = "${now}${(1000..9999).random()}"
            val json = JSONObject()
                .put("id", id)
                .put("timestamp", isoLocal(now))
                .put("type", type)
                .put("description", description)
                .put("contactsNotified", JSONArray(contacts))
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putString(KEY_PREFIX + id, json.toString())
                .apply()
        } catch (e: Exception) {
            Log.e("SafetyLog", "Couldn't record event", e)
        }
    }

    /// "your contact", "all 3 contacts", "2 of 3 contacts".
    fun contactsPhrase(sent: Int, total: Int): String = when {
        total == 1 -> "your contact"
        sent >= total -> "all $total contacts"
        else -> "$sent of $total contacts"
    }

    // Dart's DateTime.parse reads this as local time, like the events the
    // app logs itself.
    private fun isoLocal(ms: Long): String =
        SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).apply {
            timeZone = TimeZone.getDefault()
        }.format(Date(ms))
}
