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

/// Sends the emergency SOS when a background trigger (hands-free shake /
/// volume / power, or the check-in deadline) fires — even when the app process
/// is dead or the phone is locked.
///
/// With the SEND_SMS permission (Google Play "Physical safety / emergency
/// alerts" exception) the SMS goes straight to every contact via [DirectSms]
/// and a short status notification confirms it. Without the permission — or
/// for any contact whose message fails — it posts a high-priority, full-screen
/// "tap to send SOS" notification that opens the SMS composer pre-filled.
object SosSender {
    private const val TAG = "SosSender"
    private const val PREFS = "FlutterSharedPreferences"
    private const val P = "flutter."

    private const val CHANNEL_ID = "sos_alert_v1"
    private const val NOTIF_ID = 4100
    // Live-location updates use their own ID so stopping sharing can remove
    // them without touching a pending SOS prompt.
    private const val FOLLOW_ME_NOTIF_ID = 4101
    // "SOS sent to N contacts" confirmation, on a quieter channel.
    private const val STATUS_CHANNEL_ID = "sos_status_v1"
    private const val STATUS_NOTIF_ID = 4102

    /// Sends the SOS to all saved contacts: directly by SMS when permitted,
    /// otherwise via a full-screen "tap to send" notification. Returns false if
    /// there are no contacts. [onDone] runs once the outcome is known (used by
    /// [CheckinAlarmReceiver] to keep its process alive until then).
    fun send(context: Context, onDone: (() -> Unit)? = null): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) {
            onDone?.invoke()
            return false
        }
        val message = buildMessage(context)
        val silent = prefBool(context, "silent_sos")
        if (DirectSms.canSend(context)) {
            DirectSms.send(context, contacts, message) { sent, failed ->
                if (sent.isNotEmpty()) {
                    if (!silent) {
                        vibrate(context)
                        notifyStatus(
                            context,
                            "SOS sent to ${sent.size} of ${contacts.size} contact(s)",
                        )
                    }
                }
                if (failed.isNotEmpty()) promptSos(context, failed, message)
                onDone?.invoke()
            }
            return true
        }
        promptSos(context, contacts, message)
        if (!silent) vibrate(context)
        onDone?.invoke()
        return true
    }

    /// The fallback: a full-screen "tap to send" notification for [recipients].
    private fun promptSos(context: Context, recipients: List<String>, message: String) {
        notifySos(
            context,
            id = NOTIF_ID,
            title = "Send emergency SOS",
            body = "Tap to send your SOS message to your emergency contacts.",
            recipients = recipients,
            message = message,
            fullScreen = true,
        )
    }

    /// Sends a live-location ("Follow Me") update: silently by SMS when
    /// permitted, otherwise a notification the user taps to send.
    fun sendFollowMe(context: Context): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) return false
        val link = lastKnownMapsLink(context) ?: "(location unavailable)"
        val message = "Following my journey. Live location: $link"
        if (DirectSms.canSend(context)) {
            DirectSms.send(context, contacts, message) { _, failed ->
                if (failed.isNotEmpty()) promptFollowMe(context, failed, message)
            }
            return true
        }
        promptFollowMe(context, contacts, message)
        return true
    }

    private fun promptFollowMe(context: Context, recipients: List<String>, message: String) {
        notifySos(
            context,
            id = FOLLOW_ME_NOTIF_ID,
            title = "Share your live location",
            body = "Tap to send your current location to your contacts.",
            recipients = recipients,
            message = message,
            // A routine update must not take over the screen like an SOS.
            fullScreen = false,
        )
    }

    /// A short, non-intrusive confirmation (e.g. "SOS sent to 3 contacts").
    private fun notifyStatus(context: Context, text: String) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(
                        STATUS_CHANNEL_ID,
                        "SOS status",
                        NotificationManager.IMPORTANCE_DEFAULT,
                    ).apply { description = "Confirms when your SOS has been sent." },
                )
            }
            val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pi = open?.let {
                PendingIntent.getActivity(
                    context, STATUS_NOTIF_ID, it,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                )
            }
            val n = NotificationCompat.Builder(context, STATUS_CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_safeone)
                .setContentTitle(text)
                .setContentText("Your contacts have your location.")
                .setAutoCancel(true)
                .setContentIntent(pi)
                .build()
            nm.notify(STATUS_NOTIF_ID, n)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to post SOS status", e)
        }
    }

    /// Removes the pending live-location prompt (called when sharing stops).
    fun cancelFollowMe(context: Context) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.cancel(FOLLOW_ME_NOTIF_ID)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cancel live-location notification", e)
        }
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
        id: Int,
        title: String,
        body: String,
        recipients: List<String>,
        message: String,
        fullScreen: Boolean,
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
            val contentIntent = PendingIntent.getActivity(context, id, smsIntent, flags)

            val builder = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_safeone)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText("$body\n\n$message"))
                .setPriority(
                    if (fullScreen) NotificationCompat.PRIORITY_MAX
                    else NotificationCompat.PRIORITY_HIGH,
                )
                .setCategory(
                    if (fullScreen) NotificationCompat.CATEGORY_ALARM
                    else NotificationCompat.CATEGORY_REMINDER,
                )
                .setAutoCancel(true)
                .setContentIntent(contentIntent)
            if (fullScreen) builder.setFullScreenIntent(contentIntent, true)

            nm.notify(id, builder.build())
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
