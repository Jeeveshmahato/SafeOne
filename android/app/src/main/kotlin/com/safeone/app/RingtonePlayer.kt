package com.safeone.app

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.util.Log

/// Plays a phone ringtone for the fake call, the way a real incoming call
/// does: on the ringtone audio stream (so it follows the ringer volume) and
/// looping until stopped.
///
/// [uri] is a ringtone the user picked; null means the phone's own default
/// ringtone. If the chosen sound can't be played (e.g. the file was deleted),
/// it falls back to the default ringtone.
object RingtonePlayer {
    private const val TAG = "RingtonePlayer"
    private var player: MediaPlayer? = null

    fun play(context: Context, uri: String?): Boolean {
        stop()
        val candidates = listOfNotNull(
            uri?.let { Uri.parse(it) },
            RingtoneManager.getActualDefaultRingtoneUri(
                context, RingtoneManager.TYPE_RINGTONE,
            ),
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
        ).distinct()
        for (candidate in candidates) {
            try {
                player = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build(),
                    )
                    setDataSource(context, candidate)
                    isLooping = true
                    prepare()
                    start()
                }
                return true
            } catch (e: Exception) {
                Log.w(TAG, "Can't play $candidate", e)
                stop()
            }
        }
        return false
    }

    fun stop() {
        try {
            player?.run {
                if (isPlaying) stop()
                release()
            }
        } catch (e: Exception) {
            Log.w(TAG, "stop failed", e)
        }
        player = null
    }

    /// The display name of a ringtone (e.g. "Pixel Sounds"), or null.
    fun title(context: Context, uri: String?): String? = try {
        val u = uri?.let { Uri.parse(it) }
            ?: RingtoneManager.getActualDefaultRingtoneUri(
                context, RingtoneManager.TYPE_RINGTONE,
            )
        u?.let { RingtoneManager.getRingtone(context, it)?.getTitle(context) }
    } catch (e: Exception) {
        null
    }
}
