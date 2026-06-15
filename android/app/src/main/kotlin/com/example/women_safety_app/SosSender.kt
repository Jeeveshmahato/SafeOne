package com.example.women_safety_app

import android.content.Context
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.telephony.SmsManager
import android.util.Log
import org.json.JSONArray

/// Sends the emergency SOS natively (SMS + last-known location link), reading
/// the SAME data Flutter wrote via shared_preferences. Native so it works even
/// if the Flutter app process is dead — used by both the hands-free trigger
/// service and the background check-in deadline.
object SosSender {
    private const val TAG = "SosSender"
    private const val PREFS = "FlutterSharedPreferences"
    private const val P = "flutter."

    /// Sends the SOS to all saved contacts. Returns true if at least attempted.
    fun send(context: Context): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) return false
        sendSms(context, contacts, buildMessage(context))
        if (!prefBool(context, "silent_sos")) vibrate(context)
        return true
    }

    /// Sends a live-location ("Follow Me") update to all contacts. Silent — no
    /// vibration — because it repeats on a timer while the user travels.
    fun sendFollowMe(context: Context): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) return false
        val link = lastKnownMapsLink(context) ?: "(location unavailable)"
        sendSms(context, contacts, "Following my journey. Live location: $link")
        return true
    }

    private fun buildMessage(context: Context): String {
        var template = prefString(context, "sos_message")
        if (template.isNullOrBlank()) {
            template = "EMERGENCY! I need help. My current location: {location}"
        }
        val link = lastKnownMapsLink(context)
        return if (template.contains("{location}")) {
            template.replace("{location}", link ?: "(location unavailable)")
        } else if (link != null) {
            "$template $link"
        } else {
            template
        }
    }

    private fun lastKnownMapsLink(context: Context): String? {
        return try {
            val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            var best: Location? = null
            for (p in lm.getProviders(true)) {
                val loc = lm.getLastKnownLocation(p) ?: continue
                if (best == null || loc.time > best!!.time) best = loc
            }
            best?.let { "https://maps.google.com/?q=${it.latitude},${it.longitude}" }
        } catch (e: SecurityException) {
            null
        } catch (e: Exception) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun sendSms(context: Context, numbers: List<String>, message: String) {
        val sm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(SmsManager::class.java)
        } else {
            SmsManager.getDefault()
        }
        for (number in numbers) {
            try {
                val parts = sm.divideMessage(message)
                if (parts.size > 1) {
                    sm.sendMultipartTextMessage(number, null, parts, null, null)
                } else {
                    sm.sendTextMessage(number, null, message, null, null)
                }
            } catch (e: Exception) {
                Log.e(TAG, "SMS to $number failed", e)
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun vibrate(context: Context) {
        try {
            val vib = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                    .defaultVibrator
            } else {
                context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            vib.vibrate(VibrationEffect.createOneShot(800, VibrationEffect.DEFAULT_AMPLITUDE))
        } catch (_: Exception) {}
    }

    private fun loadContacts(context: Context): List<String> {
        val raw = prefString(context, "emergency_contacts") ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { i ->
                arr.getJSONObject(i).optString("phone").takeIf { it.isNotBlank() }
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun prefBool(context: Context, key: String): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(P + key, false)

    fun prefString(context: Context, key: String): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(P + key, null)

    fun setPrefBool(context: Context, key: String, value: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean(P + key, value).apply()
    }
}
