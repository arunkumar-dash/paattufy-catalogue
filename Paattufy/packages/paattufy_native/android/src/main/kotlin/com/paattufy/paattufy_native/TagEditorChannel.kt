package com.paattufy.paattufy_native

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.ParcelFileDescriptor
import com.kyant.taglib.AudioPropertiesReadStyle
import com.kyant.taglib.Picture
import com.kyant.taglib.TagLib
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * `paattufy/tag_editor` — read/write tags via TagLib (phase-9 spike, TP §11):
 * ID3v2 (MP3), Vorbis comments (FLAC/OGG), MP4 atoms. Writes go through the
 * content resolver (scoped storage); with All-files access granted the
 * provider allows the write. Only tag *metadata* is changed — audio frames are
 * untouched, so playback stays bit-perfect.
 */
class TagEditorChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())

    init {
        MethodChannel(messenger, PaattufyChannelNames.TAG_EDITOR).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        executor.execute {
            try {
                val out: Any? = when (call.method) {
                    "read" -> read(call.argument<String>("contentUri")!!)
                    "write" -> write(
                        call.argument<String>("contentUri")!!,
                        call.argument<String>("filePath"),
                        call.argument<Map<String, String>>("fields") ?: emptyMap(),
                    )
                    "setArtwork" -> setArtwork(
                        call.argument<String>("contentUri")!!,
                        call.argument<String>("filePath"),
                        call.argument<ByteArray>("bytes"),
                        call.argument<String>("mime") ?: "image/jpeg",
                    )
                    else -> {
                        mainHandler.post { result.notImplemented() }
                        return@execute
                    }
                }
                mainHandler.post { result.success(out) }
            } catch (e: Throwable) {
                mainHandler.post { result.error("tag_error", e.message, null) }
            }
        }
    }

    private fun open(contentUri: String, filePath: String?, mode: String): ParcelFileDescriptor {
        try {
            context.contentResolver.openFileDescriptor(Uri.parse(contentUri), mode)?.let { return it }
        } catch (_: Exception) {
            // fall through to a direct file path (All-files access)
        }
        val f = File(filePath ?: throw IllegalStateException("cannot open $contentUri"))
        return ParcelFileDescriptor.open(
            f,
            if (mode == "r") ParcelFileDescriptor.MODE_READ_ONLY else ParcelFileDescriptor.MODE_READ_WRITE,
        )
    }

    /** TagLib takes ownership of the descriptor it is given, so hand it a dup. */
    private fun <T> withFd(contentUri: String, filePath: String?, mode: String, block: (Int) -> T): T {
        val pfd = open(contentUri, filePath, mode)
        try {
            return block(pfd.dup().detachFd())
        } finally {
            pfd.close()
        }
    }

    private fun first(map: HashMap<String, Array<String>>, vararg keys: String): String? {
        for (k in keys) map[k]?.firstOrNull()?.takeIf { it.isNotBlank() }?.let { return it }
        return null
    }

    private fun read(contentUri: String): Map<String, Any?> {
        val meta = withFd(contentUri, null, "r") { TagLib.getMetadata(it, true) }
            ?: return mapOf("supported" to false)
        val p = meta.propertyMap
        val props = withFd(contentUri, null, "r") { TagLib.getAudioProperties(it, AudioPropertiesReadStyle.Fast) }
        return mapOf(
            "supported" to true,
            "title" to first(p, "TITLE"),
            "artist" to first(p, "ARTIST"),
            "album" to first(p, "ALBUM"),
            "albumArtist" to first(p, "ALBUMARTIST"),
            "genre" to first(p, "GENRE"),
            "year" to first(p, "DATE", "YEAR"),
            "track" to first(p, "TRACKNUMBER"),
            "lyrics" to first(p, "LYRICS", "UNSYNCEDLYRICS"),
            "hasArtwork" to (meta.pictures.isNotEmpty()),
            "bitrate" to props?.bitrate,
            "sampleRate" to props?.sampleRate,
        )
    }

    private fun write(contentUri: String, filePath: String?, fields: Map<String, String>): Boolean {
        val keyMap = mapOf(
            "title" to "TITLE", "artist" to "ARTIST", "album" to "ALBUM", "albumArtist" to "ALBUMARTIST",
            "genre" to "GENRE", "year" to "DATE", "track" to "TRACKNUMBER", "lyrics" to "LYRICS",
        )
        val ok = withFd(contentUri, filePath, "rw") { fd ->
            // Merge into the existing properties so untouched frames survive.
            val existing = TagLib.getMetadata(fd.let { dupFd(contentUri, filePath) }, false)?.propertyMap
                ?: HashMap()
            for ((k, v) in fields) {
                val tag = keyMap[k] ?: continue
                if (v.isBlank()) existing.remove(tag) else existing[tag] = arrayOf(v.trim())
            }
            TagLib.savePropertyMap(fd, existing)
        }
        if (ok) rescan(contentUri, filePath)
        return ok
    }

    private fun dupFd(contentUri: String, filePath: String?): Int {
        val pfd = open(contentUri, filePath, "r")
        try {
            return pfd.dup().detachFd()
        } finally {
            pfd.close()
        }
    }

    private fun setArtwork(contentUri: String, filePath: String?, bytes: ByteArray?, mime: String): Boolean {
        val ok = withFd(contentUri, filePath, "rw") { fd ->
            val pictures = if (bytes == null) emptyArray() else arrayOf(Picture(bytes, "", "Front Cover", mime))
            TagLib.savePictures(fd, pictures)
        }
        if (ok) rescan(contentUri, filePath)
        return ok
    }

    /** Refresh MediaStore's copy of the metadata so the library picks up the edit. */
    private fun rescan(contentUri: String, filePath: String?) {
        if (filePath != null) MediaScannerConnection.scanFile(context, arrayOf(filePath), null, null)
    }
}
