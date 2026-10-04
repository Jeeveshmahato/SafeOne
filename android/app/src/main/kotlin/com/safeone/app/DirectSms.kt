package com.safeone.app

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import android.util.Log
import androidx.core.content.ContextCompat
import java.util.concurrent.atomic.AtomicInteger

/// Sends the emergency SMS straight from the phone, one message per contact.
///
/// Used under Google Play's "Physical safety / emergency alerts" exception for
/// SEND_SMS (declared in Play Console). Each contact gets their own SMS, so no
/// group MMS (which needs mobile data and reveals everyone's number), and
/// long messages are split into parts automatically.
///
/// Results come from Android's "sent" confirmations, so the app only says an
/// alert was sent when the network actually accepted it.
object DirectSms {
    private const val TAG = "DirectSms"
    private const val EXTRA_NUMBER = "number"
    private const val TIMEOUT_MS = 30_000L
    private val requestCodes = AtomicInteger(9000)

    /// True if this phone can send SMS and the user granted SEND_SMS.
    fun canSend(context: Context): Boolean {
        val hasTelephony =
            context.packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)
        return hasTelephony && ContextCompat.checkSelfPermission(
            context, Manifest.permission.SEND_SMS,
        ) == PackageManager.PERMISSION_GRANTED
    }

    /// Sends [message] to every number in [numbers] and reports which were
    /// accepted for delivery ([onDone] runs once, on the main thread).
    fun send(
        context: Context,
        numbers: List<String>,
        message: String,
        onDone: (sent: List<String>, failed: List<String>) -> Unit,
    ) {
        val app = context.applicationContext
        val main = Handler(Looper.getMainLooper())
        val recipients = numbers.map { it.trim() }.filter { it.isNotEmpty() }.distinct()
        if (recipients.isEmpty()) {
            main.post { onDone(emptyList(), emptyList()) }
            return
        }
        val sms = try {
            smsManager(app)
        } catch (e: Exception) {
            Log.e(TAG, "No SMS manager", e)
            main.post { onDone(emptyList(), recipients) }
            return
        }
        val parts = sms.divideMessage(message)
        val action = "${app.packageName}.SMS_SENT.${System.nanoTime()}"

        // Parts still awaiting confirmation per number, and numbers that failed.
        val pending = recipients.associateWith { parts.size }.toMutableMap()
        val failed = mutableSetOf<String>()
        var finished = false

        lateinit var receiver: BroadcastReceiver
        fun finish() {
            if (finished) return
            finished = true
            runCatching { app.unregisterReceiver(receiver) }
            // Anything unconfirmed by the timeout counts as failed, so the
            // caller falls back to the Messages app rather than over-promising.
            failed += pending.filterValues { it > 0 }.keys
            onDone(recipients.filter { it !in failed }, recipients.filter { it in failed })
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                val number = intent.getStringExtra(EXTRA_NUMBER) ?: return
                if (resultCode != Activity.RESULT_OK) {
                    failed += number
                    pending[number] = 0
                } else {
                    pending[number] = (pending[number] ?: 1) - 1
                }
                if (pending.values.all { it <= 0 }) finish()
            }
        }
        ContextCompat.registerReceiver(
            app, receiver, IntentFilter(action), ContextCompat.RECEIVER_NOT_EXPORTED,
        )
        main.postDelayed({ finish() }, TIMEOUT_MS)

        val flags = PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        for (number in recipients) {
            try {
                val sentIntents = ArrayList<PendingIntent>(parts.size)
                repeat(parts.size) {
                    val intent = Intent(action)
                        .setPackage(app.packageName)
                        .putExtra(EXTRA_NUMBER, number)
                    sentIntents += PendingIntent.getBroadcast(
                        app, requestCodes.incrementAndGet(), intent, flags,
                    )
                }
                if (parts.size > 1) {
                    sms.sendMultipartTextMessage(number, null, parts, sentIntents, null)
                } else {
                    sms.sendTextMessage(number, null, message, sentIntents[0], null)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Send to a contact failed", e)
                failed += number
                pending[number] = 0
            }
        }
        if (pending.values.all { it <= 0 }) main.post { finish() }
    }

    /// The SMS manager for the phone's default SMS SIM (dual-SIM aware).
    private fun smsManager(context: Context): SmsManager {
        val subId = SubscriptionManager.getDefaultSmsSubscriptionId()
        val valid = subId != SubscriptionManager.INVALID_SUBSCRIPTION_ID
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val base = context.getSystemService(SmsManager::class.java)
            if (valid) base.createForSubscriptionId(subId) else base
        } else {
            @Suppress("DEPRECATION")
            if (valid) SmsManager.getSmsManagerForSubscriptionId(subId) else SmsManager.getDefault()
        }
    }
}
