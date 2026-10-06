package com.paattufy.paattufy_native

import android.content.Context
import android.content.Intent
import android.media.audiofx.AudioEffect
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** `paattufy/system` — small platform intents: system EQ and share. */
class SystemChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    init {
        MethodChannel(messenger, PaattufyChannelNames.SYSTEM).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openEqualizer" -> result.success(openEqualizer(call.argument<Number>("audioSessionId")?.toInt() ?: 0))
            "shareAudio" -> result.success(
                shareAudio(call.argument<String>("contentUri"), call.argument<String>("title"))
            )
            "isMetered" -> result.success(isMetered())
            "openExternal" -> result.success(openExternal(call.argument<String>("url")))
            else -> result.notImplemented()
        }
    }

    /** Opens a URL in the user's browser (browse-mode toolbar "open external"). */
    private fun openExternal(url: String?): Boolean {
        if (url == null) return false
        return try {
            context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (_: Throwable) {
            false
        }
    }

    /** True on cellular / metered connections, for the "Wi-Fi only" downloads setting. */
    private fun isMetered(): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as android.net.ConnectivityManager
        return cm.isActiveNetworkMetered
    }

    /**
     * System equalizer bound to our audio session (AP §6): no in-app DSP, so no
     * quality loss. Returns false if no equalizer app handles the intent.
     */
    private fun openEqualizer(sessionId: Int): Boolean {
        val intent = Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL).apply {
            putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId)
            putExtra(AudioEffect.EXTRA_PACKAGE_NAME, context.packageName)
            putExtra(AudioEffect.EXTRA_CONTENT_TYPE, AudioEffect.CONTENT_TYPE_MUSIC)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return try {
            context.startActivity(intent)
            true
        } catch (_: Throwable) {
            false
        }
    }

    private fun shareAudio(contentUri: String?, title: String?): Boolean {
        if (contentUri == null) return false
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "audio/*"
            putExtra(Intent.EXTRA_STREAM, Uri.parse(contentUri))
            if (title != null) putExtra(Intent.EXTRA_TITLE, title)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val chooser = Intent.createChooser(send, title ?: "Share").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            context.startActivity(chooser)
            true
        } catch (_: Throwable) {
            false
        }
    }
}
