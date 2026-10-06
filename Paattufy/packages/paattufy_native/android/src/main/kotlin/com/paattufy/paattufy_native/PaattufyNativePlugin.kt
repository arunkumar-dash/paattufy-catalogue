package com.paattufy.paattufy_native

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/**
 * Registers every Paattufy native channel. Being a real Flutter plugin (rather
 * than code in MainActivity) means the channels also exist in background
 * engines — notably the workmanager isolate that analyses audio while charging.
 */
class PaattufyNativePlugin : FlutterPlugin, ActivityAware {
    private var mediaStore: MediaStoreChannel? = null
    private var audioDecode: AudioDecodeChannel? = null
    private var output: OutputChannel? = null
    private var system: SystemChannel? = null
    private var iconSwitch: IconSwitchChannel? = null
    private var visualizer: VisualizerChannel? = null
    private var tagEditor: TagEditorChannel? = null
    private var intents: IntentsChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val ctx: Context = binding.applicationContext
        val messenger = binding.binaryMessenger
        mediaStore = MediaStoreChannel(ctx, messenger)
        audioDecode = AudioDecodeChannel(ctx, messenger)
        output = OutputChannel(ctx, messenger)
        system = SystemChannel(ctx, messenger)
        iconSwitch = IconSwitchChannel(ctx, messenger)
        visualizer = VisualizerChannel(ctx, messenger)
        tagEditor = TagEditorChannel(ctx, messenger)
        intents = IntentsChannel(ctx, messenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        output?.dispose()
        visualizer?.dispose()
        intents?.dispose()
    }

    // Activity lifecycle: only the open-with / share-target channel needs it.
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        intents?.attach(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        intents?.detach()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        intents?.attach(binding)
    }

    override fun onDetachedFromActivity() {
        intents?.detach()
    }
}
