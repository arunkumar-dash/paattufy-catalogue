package com.paattufy.music

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.session.MediaControllerCompat

/**
 * Sends the session's custom actions (shuffle / repeat) from the large widget.
 * Connects a short-lived MediaBrowser to audio_service's service, forwards the
 * action over the MediaSession, and disconnects.
 */
class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val name = when (action) {
            ACTION_SHUFFLE -> "toggleShuffle"
            ACTION_REPEAT -> "cycleRepeat"
            else -> return
        }
        val pending = goAsync()
        lateinit var browser: MediaBrowserCompat
        browser = MediaBrowserCompat(
            context,
            ComponentName(context, "com.ryanheise.audioservice.AudioService"),
            object : MediaBrowserCompat.ConnectionCallback() {
                override fun onConnected() {
                    try {
                        MediaControllerCompat(context, browser.sessionToken).transportControls.sendCustomAction(name, null)
                    } finally {
                        browser.disconnect()
                        pending.finish()
                    }
                }

                override fun onConnectionFailed() {
                    browser.disconnect()
                    pending.finish()
                }
            },
            null,
        )
        browser.connect()
    }

    companion object {
        const val ACTION_SHUFFLE = "com.paattufy.music.WIDGET_SHUFFLE"
        const val ACTION_REPEAT = "com.paattufy.music.WIDGET_REPEAT"
    }
}
