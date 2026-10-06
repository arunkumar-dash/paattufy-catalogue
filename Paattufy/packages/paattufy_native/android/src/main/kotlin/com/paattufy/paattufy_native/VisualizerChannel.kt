package com.paattufy.paattufy_native

import android.content.Context
import android.media.audiofx.Visualizer
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * `paattufy/visualizer` — taps the app's *own* audio session (TP §5.10), never
 * the global mix, and streams waveform + FFT magnitude bytes to Dart.
 *
 * `start` returns false when the platform refuses the tap (some OS versions
 * gate Visualizer capture behind RECORD_AUDIO, which this app deliberately does
 * not request); Dart then falls back to a tempo-driven procedural animation.
 */
class VisualizerChannel(context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private var visualizer: Visualizer? = null
    private var sink: EventChannel.EventSink? = null

    init {
        MethodChannel(messenger, PaattufyChannelNames.VISUALIZER).setMethodCallHandler(this)
        EventChannel(messenger, PaattufyChannelNames.VISUALIZER_EVENTS).setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> result.success(start(call.argument<Number>("audioSessionId")?.toInt() ?: 0))
            "stop" -> {
                stop()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun start(sessionId: Int): Boolean {
        stop()
        if (sessionId == 0) return false // never tap the global output mix
        return try {
            val v = Visualizer(sessionId)
            v.captureSize = Visualizer.getCaptureSizeRange()[0].coerceAtLeast(256)
            v.setDataCaptureListener(
                object : Visualizer.OnDataCaptureListener {
                    override fun onWaveFormDataCapture(vis: Visualizer?, waveform: ByteArray?, samplingRate: Int) {
                        emit("wave", waveform)
                    }

                    override fun onFftDataCapture(vis: Visualizer?, fft: ByteArray?, samplingRate: Int) {
                        emit("fft", fft)
                    }
                },
                Visualizer.getMaxCaptureRate() / 2, // ≈10–15 Hz bursts; Dart interpolates to ~30 fps
                true,
                true,
            )
            v.enabled = true
            visualizer = v
            true
        } catch (_: Throwable) {
            visualizer = null
            false
        }
    }

    private fun emit(kind: String, data: ByteArray?) {
        if (data == null) return
        val copy = data.copyOf()
        mainHandler.post { sink?.success(mapOf("kind" to kind, "data" to copy)) }
    }

    private fun stop() {
        try {
            visualizer?.enabled = false
            visualizer?.release()
        } catch (_: Throwable) {}
        visualizer = null
    }

    fun dispose() = stop()

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}
