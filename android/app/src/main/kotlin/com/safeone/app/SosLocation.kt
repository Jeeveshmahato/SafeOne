package com.safeone.app

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.location.CurrentLocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

/// Where the person is, for an SOS, an SOS update or a shutdown alert sent
/// without the app on screen.
///
///  1. A fix under [FRESH_MS] old (from the phone, or remembered from the
///     last alert) is used straight away.
///  2. Otherwise a fresh fix is requested from Google's fused location
///     (GPS + Wi-Fi + cell: fast and works indoors), falling back to the
///     platform GPS/network providers on phones without Play services. It is
///     never waited on longer than the caller allows.
///  3. If none arrives, the best older fix is sent, labelled with its age, so
///     contacts never mistake an old place for a live one.
///
/// Every good fix is remembered (see [remember]) so a later update can still
/// say where the person last was, even if the GPS drops out.
object SosLocation {
    private const val FRESH_MS = 2 * 60_000L
    private const val LABEL_AGE_MS = 5 * 60_000L
    private const val PREFS = "FlutterSharedPreferences"
    // "lat,lng,epochMillis,accuracyMeters", also written by the app (Dart).
    private const val LAST_FIX_KEY = "flutter.last_fix"

    fun get(context: Context, maxWaitMs: Long, onResult: (Location?) -> Unit) {
        val app = context.applicationContext
        val main = Handler(Looper.getMainLooper())
        val done = AtomicBoolean(false)
        val best = bestKnown(app)
        fun deliver(location: Location?) {
            if (!done.compareAndSet(false, true)) return
            val chosen = newest(location, best)
            if (chosen != null && chosen === location) remember(app, chosen)
            main.post { onResult(chosen) }
        }
        if (best != null && ageMs(best) <= FRESH_MS) {
            deliver(best)
            return
        }
        if (maxWaitMs <= 0) {
            deliver(null)
            return
        }
        main.postDelayed({ deliver(null) }, maxWaitMs)
        if (!requestFused(app, maxWaitMs) { deliver(it) }) {
            requestPlatform(app, maxWaitMs) { deliver(it) }
        }
    }

    /// A maps link, with a short plain-English note when it's rough or old,
    /// or null when there's no location at all (callers word that case
    /// themselves). Plain ASCII only: one character outside the GSM SMS
    /// alphabet (like "±", "—", or the narrow space some phones put in "10:42 PM")
    /// switches the whole SMS to UCS-2 and cuts each part to 70 characters.
    fun describe(location: Location?): String? {
        if (location == null) return null
        // 6 decimals is about 10 cm: plenty, and keeps the SMS short.
        val link = String.format(
            Locale.US, "https://maps.google.com/?q=%.6f,%.6f", location.latitude, location.longitude,
        )
        val notes = mutableListOf<String>()
        val age = ageMs(location)
        if (age >= LABEL_AGE_MS) {
            val minutes = age / 60_000
            notes += if (minutes < 120) "from $minutes min ago" else "from ${minutes / 60} hours ago"
        }
        if (location.hasAccuracy() && location.accuracy > 100f) {
            notes += "could be off by about ${roundMeters(location.accuracy)} m"
        }
        return if (notes.isEmpty()) link else "$link (${notes.joinToString(", ")})"
    }

    private fun roundMeters(m: Float): Int = when {
        m < 1000 -> ((m / 50).toInt() + 1) * 50
        else -> ((m / 500).toInt() + 1) * 500
    }

    /// Remember a good fix for later updates (only kept while a safety
    /// session needs it; see [forget]).
    fun remember(context: Context, location: Location) {
        val value = listOf(
            location.latitude, location.longitude, location.time,
            if (location.hasAccuracy()) location.accuracy else -1f,
        ).joinToString(",")
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(LAST_FIX_KEY, value).apply()
    }

    /// Drop the remembered fix (the user is safe again): no location history
    /// is kept on the phone longer than needed.
    fun forget(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().remove(LAST_FIX_KEY).apply()
    }

    // ---------------------------------------------------------------------

    @SuppressLint("MissingPermission")
    private fun requestFused(
        context: Context,
        maxWaitMs: Long,
        onFix: (Location?) -> Unit,
    ): Boolean {
        return try {
            val available = GoogleApiAvailability.getInstance()
                .isGooglePlayServicesAvailable(context) == ConnectionResult.SUCCESS
            if (!available) return false
            val cancel = CancellationTokenSource()
            val request = CurrentLocationRequest.Builder()
                .setPriority(Priority.PRIORITY_HIGH_ACCURACY)
                .setDurationMillis(maxWaitMs)
                .setMaxUpdateAgeMillis(FRESH_MS)
                .build()
            LocationServices.getFusedLocationProviderClient(context)
                .getCurrentLocation(request, cancel.token)
                .addOnSuccessListener { onFix(it) }
                .addOnFailureListener { onFix(null) }
            Handler(Looper.getMainLooper()).postDelayed({ cancel.cancel() }, maxWaitMs)
            true
        } catch (e: SecurityException) {
            false // no location permission right now
        } catch (e: Exception) {
            false
        }
    }

    @SuppressLint("MissingPermission")
    private fun requestPlatform(context: Context, maxWaitMs: Long, onFix: (Location?) -> Unit) {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val provider = listOfNotNull(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) LocationManager.FUSED_PROVIDER else null,
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
        ).firstOrNull { runCatching { lm.isProviderEnabled(it) }.getOrDefault(false) }
            ?: return onFix(null)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val cancel = CancellationSignal()
                lm.getCurrentLocation(provider, cancel, context.mainExecutor) { onFix(it) }
                Handler(Looper.getMainLooper()).postDelayed({ cancel.cancel() }, maxWaitMs)
            } else {
                val listener = object : LocationListener {
                    override fun onLocationChanged(location: Location) {
                        lm.removeUpdates(this)
                        onFix(location)
                    }

                    @Deprecated("Required on older Android versions")
                    override fun onStatusChanged(p: String?, s: Int, e: Bundle?) {}
                    override fun onProviderEnabled(p: String) {}
                    override fun onProviderDisabled(p: String) {}
                }
                @Suppress("DEPRECATION")
                lm.requestSingleUpdate(provider, listener, Looper.getMainLooper())
                Handler(Looper.getMainLooper()).postDelayed({ lm.removeUpdates(listener) }, maxWaitMs)
            }
        } catch (e: Exception) {
            onFix(null) // includes SecurityException (no permission)
        }
    }

    /// The newest fix the phone or SafeOne already knows, without waiting.
    @SuppressLint("MissingPermission")
    private fun bestKnown(context: Context): Location? {
        var best: Location? = remembered(context)
        try {
            val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            for (p in lm.getProviders(true)) {
                best = newest(lm.getLastKnownLocation(p), best)
            }
        } catch (_: Exception) {
        }
        return best
    }

    private fun remembered(context: Context): Location? {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(LAST_FIX_KEY, null) ?: return null
        val parts = raw.split(",")
        if (parts.size < 3) return null
        return try {
            Location("safeone").apply {
                latitude = parts[0].toDouble()
                longitude = parts[1].toDouble()
                time = parts[2].toDouble().toLong()
                parts.getOrNull(3)?.toFloatOrNull()?.takeIf { it >= 0 }?.let { accuracy = it }
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun newest(a: Location?, b: Location?): Location? = when {
        a == null -> b
        b == null -> a
        else -> if (ageMs(a) <= ageMs(b)) a else b
    }

    /// Age by wall clock: remembered fixes come from another process (or
    /// before a reboot), so elapsed-realtime can't be compared across them.
    private fun ageMs(location: Location): Long =
        (System.currentTimeMillis() - location.time).coerceAtLeast(0)
}
