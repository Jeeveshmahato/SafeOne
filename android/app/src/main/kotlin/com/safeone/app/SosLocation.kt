package com.safeone.app

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
import java.util.concurrent.atomic.AtomicBoolean

/// Where the person is, for an SOS sent without the app open.
///
/// The phone's "last known" location can be hours old (e.g. after a night
/// indoors). Sending that as "my current location" could send help to the
/// wrong place, so:
///   1. a last-known fix under [FRESH_MS] old is used straight away;
///   2. otherwise a fresh fix is requested, but never waited on for longer
///      than the caller allows (the alert must not be held back);
///   3. if none arrives, the old fix is sent labelled with its age.
object SosLocation {
    private const val FRESH_MS = 2 * 60_000L
    private const val LABEL_AGE_MS = 5 * 60_000L

    fun get(context: Context, maxWaitMs: Long, onResult: (Location?) -> Unit) {
        val main = Handler(Looper.getMainLooper())
        val done = AtomicBoolean(false)
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val last = lastKnown(lm)
        fun deliver(location: Location?) {
            if (done.compareAndSet(false, true)) main.post { onResult(location) }
        }
        if (last != null && ageMs(last) <= FRESH_MS) {
            deliver(last)
            return
        }
        val provider = provider(lm)
        if (provider == null || maxWaitMs <= 0) {
            deliver(last)
            return
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val cancel = CancellationSignal()
                lm.getCurrentLocation(provider, cancel, context.mainExecutor) { fresh ->
                    deliver(fresh ?: last)
                }
                main.postDelayed({
                    cancel.cancel()
                    deliver(last)
                }, maxWaitMs)
            } else {
                val listener = object : LocationListener {
                    override fun onLocationChanged(location: Location) {
                        lm.removeUpdates(this)
                        deliver(location)
                    }

                    @Deprecated("Required on older Android versions")
                    override fun onStatusChanged(p: String?, s: Int, e: Bundle?) {}
                    override fun onProviderEnabled(p: String) {}
                    override fun onProviderDisabled(p: String) {}
                }
                @Suppress("DEPRECATION")
                lm.requestSingleUpdate(provider, listener, Looper.getMainLooper())
                main.postDelayed({
                    lm.removeUpdates(listener)
                    deliver(last)
                }, maxWaitMs)
            }
        } catch (e: SecurityException) {
            deliver(last) // no location permission
        } catch (e: Exception) {
            deliver(last)
        }
    }

    /// A maps link, with the fix's age when it's old, or a clear note when
    /// there's no location at all.
    fun describe(location: Location?): String {
        if (location == null) return "(location unavailable)"
        val link = "https://maps.google.com/?q=${location.latitude},${location.longitude}"
        val age = ageMs(location)
        if (age < LABEL_AGE_MS) return link
        val minutes = age / 60_000
        val ago = if (minutes < 120) "$minutes min ago" else "${minutes / 60} h ago"
        return "$link (last known location, from $ago)"
    }

    private fun ageMs(location: Location): Long {
        // Elapsed-realtime is immune to the user changing the clock.
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            (SystemClock.elapsedRealtimeNanos() - location.elapsedRealtimeNanos) / 1_000_000
        } else {
            System.currentTimeMillis() - location.time
        }
    }

    private fun lastKnown(lm: LocationManager): Location? {
        return try {
            var best: Location? = null
            for (p in lm.getProviders(true)) {
                val loc = lm.getLastKnownLocation(p) ?: continue
                if (best == null || ageMs(loc) < ageMs(best)) best = loc
            }
            best
        } catch (e: SecurityException) {
            null
        }
    }

    /// The best enabled provider: fused (Android 12+), then GPS, then network.
    private fun provider(lm: LocationManager): String? {
        val order = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) add(LocationManager.FUSED_PROVIDER)
            add(LocationManager.GPS_PROVIDER)
            add(LocationManager.NETWORK_PROVIDER)
        }
        return order.firstOrNull {
            try {
                lm.isProviderEnabled(it)
            } catch (e: Exception) {
                false
            }
        }
    }
}
