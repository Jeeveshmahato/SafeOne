package com.safeone.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONArray

/// Surfaces the emergency SOS when a background trigger (hands-free shake /
/// volume / power, or the check-in deadline) fires.
///
/// This app deliberately does NOT hold the restricted SEND_SMS permission
/// (Google Play limits it to default SMS handlers), so it can no longer send
/// the SMS silently from the background. Instead it posts a high-priority,
/// full-screen "tap to send SOS" notification that opens the SMS composer with
/// the message + location pre-filled. The notification fires even when the app
/// process is dead and shows over the lock screen, so the user can send with a
/// single tap.
object SosSender {
    private const val TAG = "SosSender"
    private const val PREFS = "FlutterSharedPreferences"
    private const val P = "flutter."

    private const val CHANNEL_ID = "sos_alert_v1"
    private const val NOTIF_ID = 4100

    /// Surfaces the SOS to all saved contacts via a full-screen "tap to send"
    /// notification. Returns true if a notification was posted.
    fun send(context: Context): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) return false
        notifySos(
            context,
            title = "Send emergency SOS",
            body = "Tap to send your SOS message to your emergency contacts.",
            recipients = contacts,
            message = buildMessage(context),
        )
        if (!prefBool(context, "silent_sos")) vibrate(context)
        return true
    }

    /// Surfaces a live-location ("Follow Me") update for the user to send.
    fun sendFollowMe(context: Context): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) return false
        val link = lastKnownMapsLink(context) ?: "(location unavailable)"
        notifySos(
            context,
            title = "Share your live location",
            body = "Tap to send your current location to your contacts.",
            recipients = contacts,
            message = "Following my journey. Live location: $link",
        )
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

    /// Posts a high-priority, full-screen notification that opens the system SMS
    /// composer (pre-filled with [message] addressed to [recipients]) when
    /// tapped. This replaces the old silent SmsManager send, which needed the
    /// SEND_SMS permission that Google Play restricts.
    private fun notifySos(
        context: Context,
        title: String,
        body: String,
        recipients: List<String>,
        message: String,
    ) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Emergency SOS",
                    NotificationManager.IMPORTANCE_HIGH,
                )
                channel.description = "Prompts you to send an emergency SOS message."
                nm.createNotificationChannel(channel)
            }

            // sms:<recipients>?body=<message> opens the composer pre-filled.
            val smsUri = Uri.parse(
                "smsto:${recipients.joinToString(",")}",
            )
            val smsIntent = Intent(Intent.ACTION_SENDTO, smsUri).apply {
                putExtra("sms_body", message)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                    PendingIntent.FLAG_IMMUTABLE else 0
            val contentIntent = PendingIntent.getActivity(context, NOTIF_ID, smsIntent, flags)

            val builder = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_alert)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText("$body\n\n$message"))
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setAutoCancel(true)
                .setContentIntent(contentIntent)
                .setFullScreenIntent(contentIntent, true)

            nm.notify(NOTIF_ID, builder.build())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to post SOS notification", e)
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
