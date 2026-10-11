package com.safeone.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.location.Location
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONArray

/// Sends the emergency SOS when a background trigger (hands-free shake /
/// volume / power, a check-in or journey deadline) fires, and the live
/// location updates — even when the app process
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

    /// What set off an automatic alert. It decides the wording: contacts
    /// should know when the user didn't write or send the text themselves.
    sealed class Alert {
        /// A hands-free shortcut: "shake", "volume" or "power".
        data class Trigger(val source: String) : Alert()
        object MissedCheckin : Alert()
        data class MissedJourney(val destination: String) : Alert()
    }

    data class Contact(val name: String, val phone: String)

    /// Sends the alert to all saved contacts: directly by SMS when permitted,
    /// otherwise via a full-screen "tap to send" notification, and adds it to
    /// Records. Returns false if there are no contacts. [onDone] runs once the
    /// outcome is known (used by the alarm receivers to keep their process
    /// alive until then).
    ///
    /// Waits at most [locationWaitMs] for a fresh location fix when the last
    /// known one is old; the alert is never held back longer than that.
    fun send(
        context: Context,
        alert: Alert,
        locationWaitMs: Long = 10_000,
        onDone: (() -> Unit)? = null,
    ): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) {
            onDone?.invoke()
            return false
        }
        SosLocation.get(context, locationWaitMs) { location ->
            val message = when (alert) {
                is Alert.Trigger -> buildMessage(context, location)
                Alert.MissedCheckin -> missedCheckinMessage(context, location)
                is Alert.MissedJourney -> missedJourneyMessage(context, alert.destination, location)
            }
            sendNow(context, contacts, message, alert, onDone)
        }
        return true
    }

    private fun sendNow(
        context: Context,
        contacts: List<Contact>,
        message: String,
        alert: Alert,
        onDone: (() -> Unit)?,
    ) {
        val silent = prefBool(context, "silent_sos")
        val numbers = contacts.map { it.phone }
        if (DirectSms.canSend(context)) {
            DirectSms.send(context, numbers, message) { sent, failed ->
                if (sent.isNotEmpty()) {
                    if (!silent) {
                        vibrate(context)
                        notifyStatus(context, sentTitle(sent.size, contacts.size))
                    }
                }
                if (failed.isNotEmpty()) promptSos(context, failed, message)
                logAlert(context, alert, contacts, sent)
                onDone?.invoke()
            }
            return
        }
        promptSos(context, numbers, message)
        if (!silent) vibrate(context)
        logAlert(context, alert, contacts, emptyList())
        onDone?.invoke()
    }

    /// Adds the alert to Records. [sent] are the numbers that got the text
    /// without the user having to tap Send.
    private fun logAlert(context: Context, alert: Alert, contacts: List<Contact>, sent: List<String>) {
        val reached = if (sent.isEmpty()) {
            "is ready in Messages. Tap Send to reach ${SafetyLog.contactsPhrase(contacts.size, contacts.size)}"
        } else {
            "was sent to ${SafetyLog.contactsPhrase(sent.size, contacts.size)}"
        }
        val description = when (alert) {
            is Alert.Trigger -> {
                val how = when (alert.source) {
                    "shake" -> "you shook your phone"
                    "volume" -> "you pressed the volume button 3 times"
                    "power" -> "you pressed the power button 3 times"
                    else -> "a shortcut"
                }
                "SOS $reached ($how)"
            }
            Alert.MissedCheckin -> "Safety timer ran out, so an alert $reached"
            is Alert.MissedJourney ->
                "You hadn't reached ${alert.destination} in time, so an alert $reached"
        }
        val names = if (sent.isEmpty()) contacts else contacts.filter { it.phone in sent }
        SafetyLog.add(context, SafetyLog.SOS, description, names.map { it.name })
    }

    /// The fallback: a full-screen "tap to send" notification for [recipients].
    private fun promptSos(context: Context, recipients: List<String>, message: String) {
        notifySos(
            context,
            id = NOTIF_ID,
            title = "Tap to send your SOS",
            body = "Your message is ready in Messages. Just tap Send.",
            recipients = recipients,
            message = message,
            fullScreen = true,
        )
    }

    /// Sends one live-location update while sharing is on: silently by SMS
    /// when permitted, otherwise a notification the user taps to send. The
    /// wording follows what started the sharing: an SOS, Follow Me or a
    /// journey ("live_share_mode").
    ///
    /// Waits up to [locationWaitMs] for a fresh fix. If there's no location
    /// at all, contacts are told once and the next updates are skipped until
    /// a location is available again, rather than repeating a useless text.
    /// [onDone] runs once the text is handed over or skipped.
    fun sendLiveUpdate(
        context: Context,
        locationWaitMs: Long = 20_000,
        onDone: (() -> Unit)? = null,
    ): Boolean {
        val contacts = loadContacts(context)
        if (contacts.isEmpty()) {
            onDone?.invoke()
            return false
        }
        SosLocation.get(context, locationWaitMs) { location ->
            if (!prefBool(context, "live_sharing_active")) { // stopped meanwhile
                onDone?.invoke()
                return@get
            }
            val message = liveMessage(context, SosLocation.describe(location))
            if (message == null) {
                onDone?.invoke()
                return@get
            }
            sendOrPrompt(
                context, contacts.map { it.phone }, message,
                FOLLOW_ME_NOTIF_ID, "Send your location update",
            ) {
                setPrefLong(context, "live_share_count", prefLong(context, "live_share_count") + 1)
                setPrefLong(context, "live_share_last_sent_ms", System.currentTimeMillis())
                onDone?.invoke()
            }
        }
        return true
    }

    /// The text for one live update, or null to skip it (still no location,
    /// and contacts were already told). [where] is null without a location.
    private fun liveMessage(context: Context, where: String?): String? {
        val mode = prefString(context, "live_share_mode") ?: "sos"
        // An SOS already carried the location; Follow Me and a journey open
        // with a text that says what's going on.
        val first = mode != "sos" && prefLong(context, "live_share_count") == 0L
        val destination = prefString(context, "journey_destination").orEmpty()
        val overdue = prefBool(context, "journey_overdue")
        if (where != null) {
            setPrefBool(context, "live_share_no_fix_sent", false)
        } else if (!first) {
            if (prefBool(context, "live_share_no_fix_sent")) return null
            setPrefBool(context, "live_share_no_fix_sent", true)
        }
        val noFix = "My phone can't find my location right now, so go by the last one I sent."
        return when {
            mode == "journey" && overdue -> "I still haven't reached $destination. " +
                (if (where != null) "I'm here now: $where" else noFix) + batteryLine(context)
            mode == "journey" && first -> "I'm on my way to $destination. I'll text when I get there. " +
                (if (where != null) "I'm here now: $where" else "My phone can't find my location yet, I'll send it as soon as it can.")
            mode == "journey" -> "On my way to $destination. " +
                (if (where != null) "I'm here now: $where" else noFix)
            mode == "follow_me" && first -> "I'm sharing my location with you while I'm out. " +
                (if (where != null) "I'm here now: $where" else "My phone can't find it yet, I'll send it as soon as it can.")
            mode == "follow_me" -> if (where != null) "Here's where I am now: $where" else noFix
            else -> "I still need help. " +
                (if (where != null) "I'm here now: $where" else noFix) + batteryLine(context)
        }
    }

    /// The phone is shutting down or restarting (or being reset from
    /// Settings, which restarts it). Android gives a few seconds, so: the best
    /// location known right now (no long wait), sent straight away. [onDone]
    /// runs once the SMS is handed over, so the caller can let the shutdown
    /// continue.
    fun sendShutdownAlert(context: Context, onDone: () -> Unit) {
        val contacts = loadContacts(context)
        if (contacts.isEmpty() || !DirectSms.canSend(context)) {
            // Without SMS permission there's no one to tap a notification on
            // a phone that is switching off.
            onDone()
            return
        }
        // During an SOS, a journey or a check-in the phone going dark is a
        // warning sign; with "always" on it's usually just a restart, so
        // don't alarm anyone.
        val inSession = prefBool(context, "live_sharing_active") ||
            prefBool(context, "checkin_active")
        SosLocation.get(context, 2_500) { location ->
            val where = SosLocation.describe(location)
            val message = buildString {
                append("My phone is switching off or restarting")
                append(if (inSession) ". If you can't reach me soon, please check on me." else ", so I may not reply for a bit.")
                if (where != null) append(" Last location: $where")
                append(batteryLine(context))
                append("\n(Sent automatically by SafeOne)")
            }
            DirectSms.send(context, contacts.map { it.phone }, message) { sent, _ ->
                if (sent.isNotEmpty()) {
                    SafetyLog.add(
                        context, SafetyLog.LOCATION_SHARED,
                        "Your phone was switching off, so " +
                            "${SafetyLog.contactsPhrase(sent.size, contacts.size)} " +
                            "got your last location",
                        contacts.filter { it.phone in sent }.map { it.name },
                    )
                }
                onDone()
            }
        }
    }

    /// Whether a shutdown should alert contacts, per the user's setting:
    /// "off", "always", or (default) "active": only while location is being
    /// shared (SOS, Follow Me, journey) or a safety check-in is running.
    fun shouldAlertOnShutdown(context: Context): Boolean =
        when (prefString(context, "shutdown_alert_mode") ?: "active") {
            "off" -> false
            "always" -> true
            else -> prefBool(context, "live_sharing_active") || prefBool(context, "checkin_active")
        }

    /// Sends [message] by SMS when permitted, otherwise (or for any failed
    /// number) posts a tap-to-send notification. [onSent] runs once it's
    /// handed over, either way.
    private fun sendOrPrompt(
        context: Context,
        contacts: List<String>,
        message: String,
        notifId: Int,
        title: String,
        onSent: () -> Unit,
    ) {
        val prompt = { recipients: List<String> ->
            notifySos(
                context,
                id = notifId,
                title = title,
                body = "Tap to text your contacts where you are now.",
                recipients = recipients,
                message = message,
                // A routine update must not take over the screen like an SOS.
                fullScreen = false,
            )
        }
        if (DirectSms.canSend(context)) {
            DirectSms.send(context, contacts, message) { _, failed ->
                if (failed.isNotEmpty()) prompt(failed)
                onSent()
            }
        } else {
            prompt(contacts)
            onSent()
        }
    }

    /// "\nBattery 34%": tells contacts how long the phone may stay reachable.
    /// On its own line, so the maps link before it never picks up stray
    /// punctuation.
    private fun batteryLine(context: Context): String {
        return try {
            val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val level = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            if (level in 0..100) "\nBattery $level%" else ""
        } catch (_: Exception) {
            ""
        }
    }

    /// "SOS sent to all 3 contacts", "SOS sent to 2 of 3 contacts".
    private fun sentTitle(sent: Int, total: Int): String = when {
        total == 1 -> "SOS sent to your contact"
        sent == total -> "SOS sent to all $total contacts"
        else -> "SOS sent to $sent of $total contacts"
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
                    ).apply { description = "Lets you know your SOS went out." },
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
                .setContentText("They have your location.")
                .setAutoCancel(true)
                .setContentIntent(pi)
                .build()
            nm.notify(STATUS_NOTIF_ID, n)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to post SOS status", e)
        }
    }

    /// Ends a live-sharing session (SOS, Follow Me or journey): removes any
    /// pending update prompt and everything the session kept.
    fun endLiveShare(context: Context) {
        // The user is safe: keep no location history on the phone.
        SosLocation.forget(context)
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean(P + "live_sharing_active", false)
            .remove(P + "live_share_no_fix_sent")
            .remove(P + "live_share_count")
            .remove(P + "live_share_last_sent_ms")
            .remove(P + "live_share_started_ms")
            .remove(P + "live_share_mode")
            .remove(P + "journey_active")
            .remove(P + "journey_overdue")
            .remove(P + "journey_destination")
            .remove(P + "journey_deadline_ms")
            .remove("live_share_last_sent_ms") // before 1.3.4
            .apply()
        CheckinScheduler.cancelJourney(context)
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.cancel(FOLLOW_ME_NOTIF_ID)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cancel live-location notification", e)
        }
    }

    // Keep in sync with SettingsRepository.defaultSosMessage (Dart).
    private const val DEFAULT_SOS = "I need help right now. This is where I am: {location}"
    private const val DEFAULT_SOS_NO_LOCATION =
        "I need help right now. My phone couldn't find my location, please call me."
    private val OLD_DEFAULT_SOS = setOf(
        "EMERGENCY! I need help. My current location: {location}",
    )

    private fun buildMessage(context: Context, location: Location?): String {
        var template = prefString(context, "sos_message")
        if (template.isNullOrBlank() || template in OLD_DEFAULT_SOS) template = DEFAULT_SOS
        val where = SosLocation.describe(location)
        if (where == null && template == DEFAULT_SOS) return DEFAULT_SOS_NO_LOCATION
        return fillTemplate(template, where ?: "(my phone couldn't get my location)")
    }

    private fun missedCheckinMessage(context: Context, location: Location?): String {
        val where = SosLocation.describe(location)
        return buildString {
            append("I set a safety timer and didn't check in on time. I may need help, please call me.")
            if (where != null) append(" Last location: $where")
            append(batteryLine(context))
            append("\n(Sent automatically by SafeOne)")
        }
    }

    private fun missedJourneyMessage(context: Context, destination: String, location: Location?): String {
        val where = SosLocation.describe(location)
        return buildString {
            append("I should have reached $destination by now but haven't checked in. ")
            append("I may need help, please call me.")
            if (where != null) append(" Last location: $where")
            append(batteryLine(context))
            append("\n(Sent automatically by SafeOne)")
        }
    }

    /// The user's own text with the location where they put {location}, or
    /// after it (on its own, so the link stays tappable).
    private fun fillTemplate(template: String, where: String): String =
        if (template.contains("{location}")) {
            template.replace("{location}", where)
        } else {
            "${template.trimEnd()} $where"
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
                channel.description = "Asks you to tap Send when your SOS can't go out by itself."
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
                // On a locked phone show only the generic title: the message
                // carries the user's live location link.
                .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
                .setPublicVersion(
                    NotificationCompat.Builder(context, CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_stat_safeone)
                        .setContentTitle(title)
                        .setContentText("Unlock your phone to send it.")
                        .build(),
                )
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

    private fun loadContacts(context: Context): List<Contact> {
        val raw = prefString(context, "emergency_contacts") ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { i ->
                val c = arr.getJSONObject(i)
                val phone = c.optString("phone").takeIf { it.isNotBlank() } ?: return@mapNotNull null
                Contact(c.optString("name").ifBlank { phone }, phone)
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

    fun prefLong(context: Context, key: String): Long =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getLong(P + key, 0L)

    fun setPrefLong(context: Context, key: String, value: Long) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putLong(P + key, value).apply()
    }
}
