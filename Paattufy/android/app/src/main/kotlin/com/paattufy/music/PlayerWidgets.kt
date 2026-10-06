package com.paattufy.music

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.LruCache
import android.view.KeyEvent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/**
 * Home-screen widgets styled after Spotify's (AP §6, §11.20). State is written
 * by Dart through `home_widget` into shared preferences; these providers only
 * render it. Artwork is a pre-sized JPEG on disk and the decoded bitmap is kept
 * in an LRU, so updates never re-decode it (AP §8.13).
 */
object WidgetRender {
    private val bitmaps = object : LruCache<String, Bitmap>(6) {}

    fun art(path: String?): Bitmap? {
        if (path.isNullOrEmpty()) return null
        val f = File(path)
        if (!f.exists()) return null
        val key = "$path@${f.lastModified()}"
        bitmaps.get(key)?.let { return it }
        val opts = BitmapFactory.Options().apply { inSampleSize = 2 }
        val bmp = BitmapFactory.decodeFile(path, opts) ?: return null
        bitmaps.put(key, bmp)
        return bmp
    }

    /** Media-button PendingIntent routed to audio_service's receiver → the live MediaSession. */
    fun mediaButton(ctx: Context, keyCode: Int): PendingIntent {
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
            .setComponent(ComponentName(ctx, "com.ryanheise.audioservice.MediaButtonReceiver"))
            .putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        return PendingIntent.getBroadcast(ctx, keyCode, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    /** Custom session actions (shuffle / repeat) have no media key; go through [WidgetActionReceiver]. */
    fun customAction(ctx: Context, action: String): PendingIntent {
        val intent = Intent(ctx, WidgetActionReceiver::class.java).setAction(action)
        return PendingIntent.getBroadcast(ctx, action.hashCode(), intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    fun openNowPlaying(ctx: Context): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(ctx, MainActivity::class.java, Uri.parse("paattufy://now-playing"))

    fun bind(ctx: Context, views: RemoteViews, d: SharedPreferences, large: Boolean, showTexts: Boolean) {
        val playing = d.getBoolean("playing", false)
        val accent = d.getInt("accent", 0xFF8B3DFF.toInt())
        val art = art(d.getString("artPath", null))
        if (art != null) views.setImageViewBitmap(R.id.art, art) else views.setImageViewResource(R.id.art, R.drawable.ic_stat_music)

        views.setImageViewResource(R.id.btn_play, if (playing) R.drawable.ic_w_pause else R.drawable.ic_w_play)
        // Widgets follow the app theme: tint the play disc with the seed colour.
        views.setColorStateList(R.id.btn_play, "setBackgroundTintList", android.content.res.ColorStateList.valueOf(accent))
        views.setOnClickPendingIntent(R.id.btn_play, mediaButton(ctx, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE))
        views.setOnClickPendingIntent(R.id.art, openNowPlaying(ctx))

        if (showTexts) {
            val title = d.getString("title", null)
            views.setTextViewText(R.id.title, title ?: "Nothing playing")
            views.setTextViewText(R.id.artist, d.getString("artist", "") ?: "")
            views.setOnClickPendingIntent(R.id.btn_prev, mediaButton(ctx, KeyEvent.KEYCODE_MEDIA_PREVIOUS))
            views.setOnClickPendingIntent(R.id.btn_next, mediaButton(ctx, KeyEvent.KEYCODE_MEDIA_NEXT))
        }
        if (large) {
            views.setProgressBar(R.id.progress, 1000, (d.getFloat("progress", 0f) * 1000).toInt().coerceIn(0, 1000), false)
            views.setColorStateList(R.id.progress, "setProgressTintList", android.content.res.ColorStateList.valueOf(accent))
            val shuffle = d.getBoolean("shuffle", false)
            val repeat = d.getInt("repeat", 0)
            views.setInt(R.id.btn_shuffle, "setColorFilter", if (shuffle) accent else 0xFFFFFFFF.toInt())
            views.setImageViewResource(R.id.btn_repeat, if (repeat == 2) R.drawable.ic_w_repeat_one else R.drawable.ic_w_repeat)
            views.setInt(R.id.btn_repeat, "setColorFilter", if (repeat == 0) 0xFFFFFFFF.toInt() else accent)
            views.setOnClickPendingIntent(R.id.btn_shuffle, customAction(ctx, WidgetActionReceiver.ACTION_SHUFFLE))
            views.setOnClickPendingIntent(R.id.btn_repeat, customAction(ctx, WidgetActionReceiver.ACTION_REPEAT))
            for ((i, id) in listOf(R.id.queue1, R.id.queue2, R.id.queue3).withIndex()) {
                val t = d.getString("queue${i + 1}", null)
                views.setTextViewText(id, if (t.isNullOrEmpty()) "" else "${i + 1}  $t")
            }
        }
    }
}

class PlayerWidgetSmall : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, widgetData: SharedPreferences) {
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_small)
            WidgetRender.bind(context, v, widgetData, large = false, showTexts = false)
            manager.updateAppWidget(id, v)
        }
    }
}

class PlayerWidgetMedium : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, widgetData: SharedPreferences) {
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_medium)
            WidgetRender.bind(context, v, widgetData, large = false, showTexts = true)
            manager.updateAppWidget(id, v)
        }
    }
}

class PlayerWidgetLarge : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, widgetData: SharedPreferences) {
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_large)
            WidgetRender.bind(context, v, widgetData, large = true, showTexts = true)
            manager.updateAppWidget(id, v)
        }
    }
}
