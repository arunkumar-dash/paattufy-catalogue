package com.paattufy.music

import android.content.Context
import android.media.AudioManager
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.view.KeyEvent

/**
 * Quick-settings tile (AP §6): forwards play/pause to the existing media
 * session as a media key — no extra playback logic.
 */
class PlaybackTileService : TileService() {
    override fun onStartListening() {
        qsTile?.apply {
            state = Tile.STATE_INACTIVE
            label = "Paattufy"
            subtitle = "Play / pause"
            updateTile()
        }
    }

    override fun onClick() {
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        am.dispatchMediaKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE))
        am.dispatchMediaKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE))
    }
}
