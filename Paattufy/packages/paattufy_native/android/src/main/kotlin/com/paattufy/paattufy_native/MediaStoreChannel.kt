package com.paattufy.paattufy_native

import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Size
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

/**
 * `paattufy/media_store` — direct ContentResolver access to MediaStore.Audio
 * (TP §5.1). Chosen over a third-party plugin for folder-exclusion pushdown
 * and an incremental (DATE_MODIFIED watermark) mode.
 *
 * Read-only by construction: nothing here ever calls delete/update (AP §11.8).
 */
class MediaStoreChannel(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())

    init {
        MethodChannel(messenger, PaattufyChannelNames.MEDIA_STORE).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scanPage" -> async(result) { scanPage(call) }
            "listIds" -> async(result) { listIds() }
            "artwork" -> async(result) { artwork(call) }
            "probe" -> async(result) { probe(call) }
            "scanFiles" -> scanFiles(call, result)
            else -> result.notImplemented()
        }
    }

    private fun async(result: MethodChannel.Result, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                mainHandler.post { result.success(value) }
            } catch (e: Throwable) {
                mainHandler.post { result.error("media_store_error", e.message, null) }
            }
        }
    }

    /**
     * Asks MediaStore to index freshly written files (download-hub extraction,
     * AP §3.8) and replies once every file has been processed, so the Dart side
     * can run its incremental scan straight after.
     */
    private fun scanFiles(call: MethodCall, result: MethodChannel.Result) {
        val paths = call.argument<List<String>>("paths") ?: emptyList()
        if (paths.isEmpty()) {
            result.success(0)
            return
        }
        val remaining = java.util.concurrent.atomic.AtomicInteger(paths.size)
        android.media.MediaScannerConnection.scanFile(context, paths.toTypedArray(), null) { _, _ ->
            if (remaining.decrementAndGet() == 0) mainHandler.post { result.success(paths.size) }
        }
    }

    private fun escapeLike(s: String) =
        s.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")

    private fun scanPage(call: MethodCall): List<Map<String, Any?>> {
        val excluded = call.argument<List<String>>("excluded") ?: emptyList()
        val modifiedSince = call.argument<Number>("modifiedSince")?.toLong()
        val minDurationMs = call.argument<Number>("minDurationMs")?.toLong() ?: 0L
        val offset = call.argument<Number>("offset")?.toInt() ?: 0
        val limit = call.argument<Number>("limit")?.toInt() ?: 500

        val selection = StringBuilder(
            "${MediaStore.Audio.Media.IS_RINGTONE} = 0 AND " +
                "${MediaStore.Audio.Media.IS_NOTIFICATION} = 0 AND " +
                "${MediaStore.Audio.Media.IS_ALARM} = 0 AND " +
                "${MediaStore.Audio.Media.DURATION} >= ?"
        )
        val args = ArrayList<String>()
        args.add(minDurationMs.toString())
        if (modifiedSince != null) {
            selection.append(" AND ${MediaStore.Audio.Media.DATE_MODIFIED} > ?")
            args.add(modifiedSince.toString())
        }
        // Excluded-folder pushdown (TP §5.1): skip the folder and everything under it.
        for (folder in excluded) {
            val prefix = folder.trimEnd('/')
            selection.append(" AND ${MediaStore.Audio.Media.DATA} NOT LIKE ? ESCAPE '\\'")
            args.add(escapeLike(prefix) + "/%")
        }

        val query = Bundle().apply {
            putString(ContentResolver.QUERY_ARG_SQL_SELECTION, selection.toString())
            putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, args.toTypedArray())
            putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, "${MediaStore.Audio.Media._ID} ASC")
            putInt(ContentResolver.QUERY_ARG_LIMIT, limit)
            putInt(ContentResolver.QUERY_ARG_OFFSET, offset)
        }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ARTIST,
            MediaStore.Audio.Media.GENRE,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.DATE_MODIFIED,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.BITRATE,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.DISPLAY_NAME,
        )

        val out = ArrayList<Map<String, Any?>>()
        context.contentResolver.query(AUDIO_URI, projection, query, null)?.use { c ->
            val iId = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val iTitle = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val iArtist = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val iAlbum = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val iAlbumArtist = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ARTIST)
            val iGenre = c.getColumnIndexOrThrow(MediaStore.Audio.Media.GENRE)
            val iYear = c.getColumnIndexOrThrow(MediaStore.Audio.Media.YEAR)
            val iTrack = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)
            val iDuration = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val iData = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val iAdded = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
            val iModified = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED)
            val iSize = c.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val iBitrate = c.getColumnIndexOrThrow(MediaStore.Audio.Media.BITRATE)
            val iMime = c.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE)
            val iName = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)

            while (c.moveToNext()) {
                val id = c.getLong(iId)
                val path = c.getString(iData) ?: continue
                val file = File(path)
                val track = c.getInt(iTrack)
                val year = c.getInt(iYear)
                val artist = c.getString(iArtist)?.takeUnless { it == "<unknown>" }
                val album = c.getString(iAlbum)?.takeUnless { it == "<unknown>" }
                // Sidecar .lrc next to the file (AP §3.7, TP §5.6).
                val lrc = File(file.parentFile, file.nameWithoutExtension + ".lrc")
                out.add(
                    mapOf(
                        "mediaStoreId" to id,
                        "title" to (c.getString(iTitle) ?: c.getString(iName) ?: file.nameWithoutExtension),
                        "artist" to artist,
                        "album" to album,
                        "albumArtist" to c.getString(iAlbumArtist),
                        "genre" to c.getString(iGenre),
                        "year" to if (year > 0) year else null,
                        // MediaStore encodes disc*1000 + track.
                        "trackNumber" to if (track > 0) track % 1000 else null,
                        "durationMs" to c.getLong(iDuration),
                        "filePath" to path,
                        "contentUri" to ContentUris.withAppendedId(AUDIO_URI, id).toString(),
                        "folderPath" to (file.parent ?: ""),
                        "dateAdded" to c.getLong(iAdded),
                        "dateModified" to c.getLong(iModified),
                        "sizeBytes" to c.getLong(iSize),
                        "bitrate" to c.getInt(iBitrate).takeIf { it > 0 },
                        "format" to formatOf(c.getString(iMime), file.extension),
                        "embeddedLrcPath" to if (lrc.exists()) lrc.absolutePath else null,
                    )
                )
            }
        }
        return out
    }

    /** All audio ids currently in MediaStore (unfiltered), to detect removals. */
    private fun listIds(): List<Long> {
        val ids = ArrayList<Long>()
        context.contentResolver.query(
            AUDIO_URI, arrayOf(MediaStore.Audio.Media._ID), null, null, null
        )?.use { c ->
            val i = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            while (c.moveToNext()) ids.add(c.getLong(i))
        }
        return ids
    }

    private fun artwork(call: MethodCall): ByteArray? {
        val uri = Uri.parse(call.argument<String>("contentUri") ?: return null)
        val px = call.argument<Number>("size")?.toInt() ?: 256
        return try {
            val bmp = context.contentResolver.loadThumbnail(uri, Size(px, px), null)
            val bos = ByteArrayOutputStream()
            bmp.compress(android.graphics.Bitmap.CompressFormat.JPEG, 88, bos)
            bos.toByteArray()
        } catch (e: Exception) {
            null // no embedded art
        }
    }

    /** Extra technical details for the Details sheet (sample rate, bitrate). */
    private fun probe(call: MethodCall): Map<String, Any?> {
        val uri = Uri.parse(call.argument<String>("contentUri") ?: return emptyMap())
        val r = android.media.MediaMetadataRetriever()
        return try {
            r.setDataSource(context, uri)
            mapOf(
                "bitrate" to r.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_BITRATE)?.toIntOrNull(),
                "sampleRate" to if (Build.VERSION.SDK_INT >= 31)
                    r.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_SAMPLERATE)?.toIntOrNull()
                else null,
                "mime" to r.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_MIMETYPE),
            )
        } catch (e: Exception) {
            emptyMap()
        } finally {
            r.release()
        }
    }

    private fun formatOf(mime: String?, ext: String): String = when {
        ext.isNotEmpty() -> ext.lowercase()
        mime != null -> mime.substringAfter('/')
        else -> ""
    }

    companion object {
        private val AUDIO_URI: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
    }
}
