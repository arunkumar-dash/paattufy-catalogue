package com.paattufy.paattufy_native

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * `paattufy/intents` — "Open with" / share-target (AP §6, §8.14). Tapping an
 * audio file in a file manager, or sharing one to Paattufy, arrives here as
 * ACTION_VIEW / ACTION_SEND and is forwarded to Dart as a content URI.
 */
class IntentsChannel(private val context: android.content.Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler, PluginRegistry.NewIntentListener {

    private var sink: EventChannel.EventSink? = null
    private var binding: ActivityPluginBinding? = null
    private var initial: Map<String, Any?>? = null
    private var initialConsumed = false

    init {
        MethodChannel(messenger, PaattufyChannelNames.INTENTS).setMethodCallHandler(this)
        EventChannel(messenger, PaattufyChannelNames.INTENTS + "_events").setStreamHandler(this)
    }

    fun attach(b: ActivityPluginBinding) {
        binding = b
        b.addOnNewIntentListener(this)
        if (!initialConsumed) initial = describe(b.activity.intent)
    }

    fun detach() {
        binding?.removeOnNewIntentListener(this)
        binding = null
    }

    fun dispose() = detach()

    override fun onNewIntent(intent: Intent): Boolean {
        val d = describe(intent) ?: return false
        sink?.success(d)
        return true
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initial" -> {
                val v = initial
                initial = null
                initialConsumed = true
                result.success(v)
            }
            "resolve" -> result.success(resolveMediaUri(call.argument<String>("uri")))
            else -> result.notImplemented()
        }
    }

    /**
     * Maps a document/file-manager URI to the MediaStore audio URI of the same
     * file (API 30+), so the library row can be found and played.
     */
    private fun resolveMediaUri(uri: String?): String? {
        if (uri == null) return null
        return try {
            android.provider.MediaStore.getMediaUri(context, Uri.parse(uri))?.toString()
        } catch (_: Throwable) {
            null
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun describe(intent: Intent?): Map<String, Any?>? {
        if (intent == null) return null
        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> @Suppress("DEPRECATION") intent.getParcelableExtra(Intent.EXTRA_STREAM)
            else -> null
        }
        if (uri == null) return null
        return mapOf("uri" to uri.toString(), "action" to intent.action, "mime" to intent.type)
    }
}
