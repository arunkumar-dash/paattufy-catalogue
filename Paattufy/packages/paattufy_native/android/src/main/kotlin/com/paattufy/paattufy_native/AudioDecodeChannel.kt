package com.paattufy.paattufy_native

import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executors

/**
 * `paattufy/audio_decode` — decodes an excerpt of a track to mono float PCM at
 * a target sample rate, for *analysis only* (TP §5.7 step 1). Playback never
 * goes through here, so it stays bit-perfect.
 */
class AudioDecodeChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())

    init {
        MethodChannel(messenger, PaattufyChannelNames.AUDIO_DECODE).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "decode") {
            result.notImplemented()
            return
        }
        val uri = call.argument<String>("contentUri")
        val rate = call.argument<Number>("sampleRate")?.toInt() ?: 22050
        val startMs = call.argument<Number>("startMs")?.toLong() ?: 0L
        val durationMs = call.argument<Number>("durationMs")?.toLong() ?: 60_000L
        if (uri == null) {
            result.error("bad_args", "contentUri required", null)
            return
        }
        executor.execute {
            try {
                val bytes = decode(Uri.parse(uri), rate, startMs, durationMs)
                mainHandler.post { result.success(bytes) }
            } catch (e: Throwable) {
                mainHandler.post { result.error("decode_failed", e.message, null) }
            }
        }
    }

    /** Returns little-endian float32 mono PCM, or null if the file has no audio track. */
    private fun decode(uri: Uri, targetRate: Int, startMs: Long, durationMs: Long): ByteArray? {
        val extractor = MediaExtractor()
        var codec: MediaCodec? = null
        try {
            extractor.setDataSource(context, uri, null)
            var trackIndex = -1
            var format: MediaFormat? = null
            for (i in 0 until extractor.trackCount) {
                val f = extractor.getTrackFormat(i)
                if ((f.getString(MediaFormat.KEY_MIME) ?: "").startsWith("audio/")) {
                    trackIndex = i
                    format = f
                    break
                }
            }
            if (trackIndex < 0 || format == null) return null
            extractor.selectTrack(trackIndex)
            if (startMs > 0) extractor.seekTo(startMs * 1000, MediaExtractor.SEEK_TO_CLOSEST_SYNC)

            codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
            codec.configure(format, null, null, 0)
            codec.start()

            var srcRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            var isFloat = false

            val info = MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false
            var mono = FloatArray(0)
            var monoCount = 0
            val wantFrames = { (durationMs * srcRate / 1000).toInt() }

            fun append(v: Float) {
                if (monoCount == mono.size) mono = mono.copyOf(maxOf(65536, mono.size * 2))
                mono[monoCount++] = v
            }

            while (!outputDone) {
                if (!inputDone) {
                    val inIdx = codec.dequeueInputBuffer(10_000)
                    if (inIdx >= 0) {
                        val buf = codec.getInputBuffer(inIdx)!!
                        val size = extractor.readSampleData(buf, 0)
                        if (size < 0) {
                            codec.queueInputBuffer(inIdx, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(inIdx, 0, size, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val outIdx = codec.dequeueOutputBuffer(info, 10_000)
                when {
                    outIdx == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        val of = codec.outputFormat
                        srcRate = of.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                        channels = of.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                        isFloat = of.containsKey(MediaFormat.KEY_PCM_ENCODING) &&
                            of.getInteger(MediaFormat.KEY_PCM_ENCODING) == android.media.AudioFormat.ENCODING_PCM_FLOAT
                    }
                    outIdx >= 0 -> {
                        val out = codec.getOutputBuffer(outIdx)!!
                        out.position(info.offset)
                        out.limit(info.offset + info.size)
                        out.order(ByteOrder.nativeOrder())
                        if (isFloat) {
                            val fb = out.asFloatBuffer()
                            while (fb.remaining() >= channels) {
                                var s = 0f
                                for (c in 0 until channels) s += fb.get()
                                append(s / channels)
                            }
                        } else {
                            val sb = out.asShortBuffer()
                            while (sb.remaining() >= channels) {
                                var s = 0f
                                for (c in 0 until channels) s += sb.get() / 32768f
                                append(s / channels)
                            }
                        }
                        codec.releaseOutputBuffer(outIdx, false)
                        if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) outputDone = true
                        if (monoCount >= wantFrames()) outputDone = true
                    }
                }
            }

            val frames = minOf(monoCount, wantFrames())
            val resampled = resample(mono, frames, srcRate, targetRate)
            val out = ByteBuffer.allocate(resampled.size * 4).order(ByteOrder.LITTLE_ENDIAN)
            out.asFloatBuffer().put(resampled)
            return out.array()
        } finally {
            try { codec?.stop() } catch (_: Throwable) {}
            try { codec?.release() } catch (_: Throwable) {}
            extractor.release()
        }
    }

    /** Linear-interpolation resampler — plenty for spectral analysis. */
    private fun resample(input: FloatArray, count: Int, from: Int, to: Int): FloatArray {
        if (from == to || count == 0) return input.copyOf(count)
        val ratio = from.toDouble() / to
        val outLen = (count / ratio).toInt()
        val out = FloatArray(outLen)
        for (i in 0 until outLen) {
            val pos = i * ratio
            val i0 = pos.toInt()
            val i1 = minOf(i0 + 1, count - 1)
            val frac = (pos - i0).toFloat()
            out[i] = input[i0] * (1 - frac) + input[i1] * frac
        }
        return out
    }
}

object PaattufyChannelNames {
    const val MEDIA_STORE = "paattufy/media_store"
    const val AUDIO_DECODE = "paattufy/audio_decode"
    const val OUTPUT = "paattufy/output"
    const val OUTPUT_EVENTS = "paattufy/output_events"
    const val SYSTEM = "paattufy/system"
    const val ICON_SWITCH = "paattufy/icon_switch"
    const val VISUALIZER = "paattufy/visualizer"
    const val VISUALIZER_EVENTS = "paattufy/visualizer_events"
    const val TAG_EDITOR = "paattufy/tag_editor"
    const val INTENTS = "paattufy/intents"
}
