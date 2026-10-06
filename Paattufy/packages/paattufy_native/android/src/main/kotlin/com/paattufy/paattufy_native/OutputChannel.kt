package com.paattufy.paattufy_native

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.MediaRouter2
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * `paattufy/output` + `paattufy/output_events` — audio route awareness
 * (AP §3.6, TP §5.5).
 *
 * A route is reported as `speaker`, `wired:<name>` or `bluetooth:<name>`. The
 * event stream fires on *any* change of the media route: a device appearing or
 * disappearing ([AudioDeviceCallback]) and a switch between two already
 * connected outputs such as speaker ↔ Bluetooth ([MediaRouter2] system
 * controller updates). Dart reacts by stopping playback.
 */
class OutputChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val handler = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var lastRoute: String = currentRouteString()

    private val mediaAttrs = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build()

    private val deviceCallback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) = recheckSoon()
        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) = recheckSoon()
    }

    private var controllerCallback: MediaRouter2.ControllerCallback? = null

    init {
        MethodChannel(messenger, PaattufyChannelNames.OUTPUT).setMethodCallHandler(this)
        EventChannel(messenger, PaattufyChannelNames.OUTPUT_EVENTS).setStreamHandler(this)
        audioManager.registerAudioDeviceCallback(deviceCallback, handler)
        try {
            val router = MediaRouter2.getInstance(context)
            val cb = object : MediaRouter2.ControllerCallback() {
                override fun onControllerUpdated(controller: MediaRouter2.RoutingController) = recheckSoon()
            }
            router?.registerControllerCallback({ r -> handler.post(r) }, cb)
            controllerCallback = cb
        } catch (_: Throwable) {
            // Device-callback path still covers plug/unplug and BT connect/disconnect.
        }
    }

    fun dispose() {
        audioManager.unregisterAudioDeviceCallback(deviceCallback)
        try {
            controllerCallback?.let { MediaRouter2.getInstance(context)?.unregisterControllerCallback(it) }
        } catch (_: Throwable) {}
    }

    // Routing settles shortly after the platform event; debounce and compare.
    private fun recheckSoon() {
        handler.removeCallbacks(recheck)
        handler.postDelayed(recheck, 350)
    }

    private val recheck = Runnable {
        val now = currentRouteString()
        if (now != lastRoute) {
            lastRoute = now
            sink?.success(now)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "currentRoute" -> result.success(currentRouteString())
            "listOutputs" -> result.success(listOutputs())
            "openSwitcher" -> result.success(openSwitcher())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        lastRoute = currentRouteString()
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun activeDevice(): AudioDeviceInfo? =
        audioManager.getAudioDevicesForAttributes(mediaAttrs).firstOrNull()

    private fun kindOf(d: AudioDeviceInfo): String = when (d.type) {
        AudioDeviceInfo.TYPE_BUILTIN_SPEAKER, AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> "speaker"
        AudioDeviceInfo.TYPE_WIRED_HEADPHONES, AudioDeviceInfo.TYPE_WIRED_HEADSET,
        AudioDeviceInfo.TYPE_USB_HEADSET, AudioDeviceInfo.TYPE_USB_DEVICE,
        AudioDeviceInfo.TYPE_USB_ACCESSORY, AudioDeviceInfo.TYPE_LINE_ANALOG,
        AudioDeviceInfo.TYPE_LINE_DIGITAL, AudioDeviceInfo.TYPE_AUX_LINE -> "wired"
        AudioDeviceInfo.TYPE_BLUETOOTH_A2DP, AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
        AudioDeviceInfo.TYPE_BLE_HEADSET, AudioDeviceInfo.TYPE_BLE_SPEAKER,
        AudioDeviceInfo.TYPE_BLE_BROADCAST, AudioDeviceInfo.TYPE_HEARING_AID -> "bluetooth"
        else -> "other"
    }

    private fun currentRouteString(): String {
        val d = activeDevice() ?: return "speaker"
        val kind = kindOf(d)
        return if (kind == "speaker") "speaker" else "$kind:${d.productName}"
    }

    private fun listOutputs(): List<Map<String, Any?>> {
        val active = activeDevice()
        return audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            .filter { kindOf(it) != "other" }
            .map {
                mapOf(
                    "id" to it.id,
                    "kind" to kindOf(it),
                    "name" to (if (kindOf(it) == "speaker") "Phone speaker" else it.productName.toString()),
                    "active" to (active != null && active.id == it.id),
                )
            }
    }

    /**
     * Opens the system media-output switcher, the supported way for an app to
     * let the user move playback between the phone speaker and Bluetooth.
     */
    private fun openSwitcher(): Boolean {
        val intents = listOf(
            Intent("com.android.settings.panel.action.MEDIA_OUTPUT")
                .putExtra("com.android.settings.panel.extra.PACKAGE_NAME", context.packageName),
            Intent(android.provider.Settings.Panel.ACTION_VOLUME),
        )
        for (i in intents) {
            try {
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(i)
                return true
            } catch (_: Throwable) {}
        }
        return false
    }
}
