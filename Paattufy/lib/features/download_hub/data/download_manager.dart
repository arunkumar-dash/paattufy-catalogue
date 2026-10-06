import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings.dart';
import '../domain/catalogue.dart';
import '../domain/listing_parser.dart';

class DownloadStatus {
  static const queued = 'queued';
  static const running = 'running';
  static const paused = 'paused';
  static const done = 'done';
  static const failed = 'failed';
}

const audioExtensions = {
  '.mp3', '.m4a', '.aac', '.flac', '.wav', '.ogg', '.opus', '.oga', '.wma', '.m4b', '.mka',
};

/// Thrown when a server says the (time-boxed) link is gone.
class LinkExpiredException implements Exception {
  LinkExpiredException(this.detail);
  final String detail;
  @override
  String toString() => 'Link expired ($detail)';
}

/// Downloads, resumes, extracts and indexes (AP §3.8, §5.8; TP §5.9).
///
/// * Transfers are resumable (HTTP Range) and survive leaving the screen
///   because this object lives in an app-scoped provider, not in a widget.
/// * Listing-mode albums re-fetch the album page **immediately before** each
///   attempt and retry once on an expired link (TP §5.9.2): a zip320 URL is
///   never cached across attempts or sessions.
/// * Zips are extracted with path-traversal protection; only audio entries are
///   kept. New files are handed to MediaStore and an incremental rescan runs.
class DownloadManager {
  DownloadManager({
    required this._db,
    required this._dio,
    required this._settings,
    required this._tempDir,
    required this._indexFiles,
    required this._onLibraryChanged,
    this._isMetered,
    Future<String?> Function(String url)? fetchHtml,
    this.maxConcurrent = 2,
    DateTime Function()? clock,
  })  : _fetchHtmlOverride = fetchHtml,
        _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Dio _dio;
  final AppSettings Function() _settings;
  final Directory _tempDir;
  final Future<void> Function(List<String> paths) _indexFiles;
  final Future<void> Function() _onLibraryChanged;
  final Future<bool> Function()? _isMetered;
  final Future<String?> Function(String url)? _fetchHtmlOverride;
  final int maxConcurrent;
  final DateTime Function() _clock;

  final Map<int, CancelToken> _tokens = {};
  final Map<int, String> _stopReason = {}; // 'pause' | 'cancel'
  final Map<int, CatalogueSite> _sites = {};
  final Set<int> _active = {};
  final StreamController<DownloadRecord> _completed = StreamController.broadcast();

  /// Emits when a download finishes successfully (drives the "Added N songs"
  /// toast).
  Stream<DownloadRecord> get completed => _completed.stream;

  // --- queries ------------------------------------------------------------

  Stream<List<DownloadRecord>> watchAll() => (_db.select(_db.downloadHistory)
        ..orderBy([(t) => OrderingTerm.desc(t.id)]))
      .watch();

  Future<DownloadRecord?> byId(int id) =>
      (_db.select(_db.downloadHistory)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Call once at startup: anything left "running" by a killed process becomes
  /// resumable.
  Future<void> recover() async {
    await (_db.update(_db.downloadHistory)..where((t) => t.status.equals(DownloadStatus.running)))
        .write(const DownloadHistoryCompanion(status: Value(DownloadStatus.paused)));
  }

  // --- enqueue ------------------------------------------------------------------

  /// A direct file/zip URL (browse-mode interception, or any link).
  Future<int> enqueueFile({
    required String siteId,
    required String title,
    required String url,
    Map<String, String> headers = const {},
    String? pageUrl,
  }) async {
    final id = await _insert(
      siteId: siteId,
      title: title,
      url: url,
      kind: 'file',
      pageUrl: pageUrl,
      headers: headers,
    );
    _pump();
    return id;
  }

  /// One-tap "Download all" for a listing-mode card: the zip link is fetched
  /// fresh when the transfer actually starts.
  Future<int> enqueueAlbum(CatalogueSite site, ListingItem item) async {
    final id = await _insert(
      siteId: site.id,
      title: item.title,
      url: item.albumUrl, // placeholder until the zip URL is resolved
      kind: 'album',
      pageUrl: item.albumUrl,
    );
    _sites[id] = site;
    _pump();
    return id;
  }

  Future<int> _insert({
    required String siteId,
    required String title,
    required String url,
    required String kind,
    String? pageUrl,
    Map<String, String> headers = const {},
  }) =>
      _db.into(_db.downloadHistory).insert(DownloadHistoryCompanion.insert(
            siteId: siteId,
            title: title,
            sourceUrl: url,
            status: DownloadStatus.queued,
            startedAt: _clock(),
            kind: Value(kind),
            pageUrl: Value(pageUrl),
            headersJson: Value(headers.isEmpty ? null : jsonEncode(headers)),
          ));

  // --- controls ---------------------------------------------------------------------

  Future<void> pause(int id) async {
    _stopReason[id] = 'pause';
    _tokens[id]?.cancel('pause');
    final r = await byId(id);
    if (r != null && r.status == DownloadStatus.queued) await _setStatus(id, DownloadStatus.paused);
  }

  Future<void> resume(int id) async {
    final r = await byId(id);
    if (r == null || r.status == DownloadStatus.running || r.status == DownloadStatus.done) return;
    await _setStatus(id, DownloadStatus.queued, error: null);
    _pump();
  }

  /// Cancel = stop and discard the partial file; the row stays as a failed
  /// entry so it can be re-downloaded from history.
  Future<void> cancel(int id) async {
    _stopReason[id] = 'cancel';
    _tokens[id]?.cancel('cancel');
    if (!_active.contains(id)) {
      await _deletePart(id);
      await _setStatus(id, DownloadStatus.failed, error: 'Cancelled');
    }
  }

  /// Re-download from history (fresh start).
  Future<void> retry(int id) async {
    await _deletePart(id);
    await (_db.update(_db.downloadHistory)..where((t) => t.id.equals(id))).write(DownloadHistoryCompanion(
      status: const Value(DownloadStatus.queued),
      bytesDone: const Value(0),
      bytesTotal: const Value(0),
      error: const Value(null),
      completedAt: const Value(null),
      startedAt: Value(_clock()),
    ));
    _pump();
  }

  // --- scheduling -------------------------------------------------------------------------

  void _pump() {
    unawaited(_pumpAsync());
  }

  bool _pumping = false;
  Future<void> _pumpAsync() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (_active.length < maxConcurrent) {
        final next = await (_db.select(_db.downloadHistory)
              ..where((t) => t.status.equals(DownloadStatus.queued))
              ..orderBy([(t) => OrderingTerm.asc(t.id)])
              ..limit(1))
            .getSingleOrNull();
        if (next == null || _active.contains(next.id)) break;
        _active.add(next.id);
        await _setStatus(next.id, DownloadStatus.running, error: null);
        unawaited(_run(next.id).whenComplete(() {
          _active.remove(next.id);
          _pump();
        }));
      }
    } finally {
      _pumping = false;
    }
  }

  Future<void> _run(int id) async {
    _stopReason.remove(id);
    final token = _tokens[id] = CancelToken();
    try {
      if (_settings().downloadWifiOnly && await (_isMetered?.call() ?? Future.value(false))) {
        await _setStatus(id, DownloadStatus.paused, error: 'Waiting for Wi-Fi (Wi-Fi only is on)');
        return;
      }
      var attempt = 0;
      while (true) {
        attempt++;
        final row = (await byId(id))!;
        try {
          final url = row.kind == 'album' ? await _freshZipUrl(id, row) : row.sourceUrl;
          final done = await _transfer(id, row, url, token);
          final added = await _finalize(id, row, done);
          await _markDone(id, done, added);
          return;
        } on LinkExpiredException catch (e) {
          // One transparent retry with a freshly fetched page (TP §5.9.2).
          if (row.kind != 'album' || attempt >= 2) {
            await _setStatus(id, DownloadStatus.failed, error: 'Download link expired. ${e.detail}');
            return;
          }
          await _deletePart(id);
        }
      }
    } on DioException catch (e) {
      final reason = _stopReason[id];
      if (CancelToken.isCancel(e) || reason != null) {
        if (reason == 'cancel') {
          await _deletePart(id);
          await _setStatus(id, DownloadStatus.failed, error: 'Cancelled');
        } else {
          await _setStatus(id, DownloadStatus.paused);
        }
      } else {
        await _setStatus(id, DownloadStatus.failed, error: _describe(e));
      }
    } catch (e) {
      await _setStatus(id, DownloadStatus.failed, error: e.toString());
    } finally {
      _tokens.remove(id);
      _stopReason.remove(id);
    }
  }

  String _describe(DioException e) {
    final code = e.response?.statusCode;
    if (code != null) return 'Server responded $code';
    return e.message ?? e.type.name;
  }

  // --- album link (expires!) --------------------------------------------------------------------

  Future<String> _freshZipUrl(int id, DownloadRecord row) async {
    final site = _sites[id] ?? await _siteFor(row);
    final cfg = site?.listing;
    if (cfg == null || row.pageUrl == null) {
      throw StateError('Album download needs its listing configuration');
    }
    final pageUri = Uri.parse(row.pageUrl!);
    final html = await _fetchHtml(row.pageUrl!);
    if (html == null) throw StateError('Could not load the album page');
    final album = ListingParser(cfg).parseAlbumPage(html, pageUri);
    final zip = album.bestZip;
    if (zip == null) throw StateError('No zip link found on the album page');
    // Never persisted beyond this attempt's row update; a retry re-fetches.
    await (_db.update(_db.downloadHistory)..where((t) => t.id.equals(id)))
        .write(DownloadHistoryCompanion(sourceUrl: Value(zip)));
    return zip;
  }

  /// Albums re-queued after an app restart have no in-memory site; rebuild the
  /// listing config from the cached catalogue via [siteResolver].
  Future<CatalogueSite?> Function(String siteId)? siteResolver;
  Future<CatalogueSite?> _siteFor(DownloadRecord row) async => siteResolver?.call(row.siteId);

  Future<String?> _fetchHtml(String url) async {
    if (_fetchHtmlOverride != null) return _fetchHtmlOverride(url);
    final res = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain, headers: {'User-Agent': appUserAgent}),
    );
    return res.data;
  }

  // --- transfer -------------------------------------------------------------------------------------

  File _partFile(int id) => File(p.join(_tempDir.path, 'dl_$id.part'));

  Future<void> _deletePart(int id) async {
    final f = _partFile(id);
    if (await f.exists()) await f.delete(); // app-private temp file, not library media
  }

  Future<_Transferred> _transfer(int id, DownloadRecord row, String url, CancelToken token) async {
    await _tempDir.create(recursive: true);
    final part = _partFile(id);
    var have = await part.exists() ? await part.length() : 0;
    final headers = <String, dynamic>{
      'User-Agent': appUserAgent,
      if (row.headersJson != null) ...(jsonDecode(row.headersJson!) as Map).cast<String, dynamic>(),
      if (have > 0) 'Range': 'bytes=$have-',
    };

    final res = await _dio.get<ResponseBody>(
      url,
      cancelToken: token,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        validateStatus: (s) => s != null && (s == 200 || s == 206 || s == 416 || s == 403 || s == 404 || s == 410),
      ),
    );
    final status = res.statusCode ?? 0;
    final contentType = res.headers.value(Headers.contentTypeHeader) ?? '';
    final disposition = res.headers.value('content-disposition');

    if (status == 403 || status == 404 || status == 410) {
      throw LinkExpiredException('HTTP $status');
    }
    if (status == 416 && have > 0) {
      // Range beyond the end: the part file is already the whole thing.
      return _Transferred(part, have, contentType, disposition);
    }
    if (status == 200 && contentType.toLowerCase().contains('text/html')) {
      // Expired/invalid links often answer 200 with an HTML error page.
      throw LinkExpiredException('server returned a web page instead of a file');
    }

    int? total;
    if (status == 206) {
      final cr = res.headers.value('content-range'); // bytes a-b/total
      total = int.tryParse(cr?.split('/').last ?? '');
    } else {
      have = 0; // server ignored Range → restart from scratch
      total = int.tryParse(res.headers.value(Headers.contentLengthHeader) ?? '');
    }
    if (total != null) {
      await (_db.update(_db.downloadHistory)..where((t) => t.id.equals(id)))
          .write(DownloadHistoryCompanion(bytesTotal: Value(total)));
    }

    final sink = part.openWrite(mode: status == 206 ? FileMode.append : FileMode.write);
    var written = have;
    var lastWrite = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      await for (final chunk in res.data!.stream) {
        sink.add(chunk);
        written += chunk.length;
        final now = DateTime.now();
        if (now.difference(lastWrite) >= const Duration(milliseconds: 400)) {
          lastWrite = now;
          unawaited((_db.update(_db.downloadHistory)..where((t) => t.id.equals(id)))
              .write(DownloadHistoryCompanion(bytesDone: Value(written))));
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
    if (total != null && written < total) {
      throw StateError('Incomplete download ($written of $total bytes) — resume to continue');
    }
    await (_db.update(_db.downloadHistory)..where((t) => t.id.equals(id)))
        .write(DownloadHistoryCompanion(bytesDone: Value(written), bytesTotal: Value(total ?? written)));
    return _Transferred(part, written, contentType, disposition);
  }

  // --- finishing --------------------------------------------------------------------------------------------

  Future<int> _finalize(int id, DownloadRecord row, _Transferred t) async {
    final root = _settings().downloadFolderPath;
    await Directory(root).create(recursive: true);

    final fileName = _fileNameFor(row, t);
    final isZip = await _looksLikeZip(t, fileName);

    final written = <String>[];
    if (isZip) {
      final albumName = sanitizeFileName(
        row.kind == 'album' ? row.title : p.basenameWithoutExtension(fileName),
        fallback: 'Album',
      );
      // Re-downloading an album merges into its folder; files inside are
      // de-duplicated individually so nothing is overwritten.
      final outDir = Directory(p.join(root, albumName));
      written.addAll(await extractZipAudio(t.file.path, outDir.path));
      if (written.isEmpty) {
        // Nothing playable inside: don't leave an empty folder behind.
        if (await outDir.exists() && (await outDir.list().isEmpty)) await outDir.delete();
        throw StateError('The zip contained no audio files');
      }
      await _setLocalPath(id, outDir.path);
    } else {
      final ext = p.extension(fileName).toLowerCase();
      if (!audioExtensions.contains(ext)) {
        throw StateError('Not an audio file ($fileName)');
      }
      final dest = _uniqueFile(root, fileName);
      await t.file.copy(dest);
      written.add(dest);
      await _setLocalPath(id, dest);
    }

    await _deletePart(id); // temp artefact
    await _indexFiles(written);
    await _onLibraryChanged();
    return written.length;
  }

  Future<void> _setLocalPath(int id, String path) =>
      (_db.update(_db.downloadHistory)..where((t) => t.id.equals(id)))
          .write(DownloadHistoryCompanion(localPath: Value(path)));

  Future<void> _markDone(int id, _Transferred t, int added) async {
    await (_db.update(_db.downloadHistory)..where((t0) => t0.id.equals(id))).write(DownloadHistoryCompanion(
      status: const Value(DownloadStatus.done),
      completedAt: Value(_clock()),
      itemsAdded: Value(added),
      error: const Value(null),
    ));
    final row = await byId(id);
    if (row != null) _completed.add(row);
  }

  Future<void> _setStatus(int id, String status, {Object? error = _keep}) =>
      (_db.update(_db.downloadHistory)..where((t) => t.id.equals(id))).write(DownloadHistoryCompanion(
        status: Value(status),
        error: identical(error, _keep) ? const Value.absent() : Value(error as String?),
      ));

  static const Object _keep = Object();

  Future<bool> _looksLikeZip(_Transferred t, String fileName) async {
    if (p.extension(fileName).toLowerCase() == '.zip') return true;
    if (t.contentType.toLowerCase().contains('zip')) return true;
    final raf = await t.file.open();
    try {
      final head = await raf.read(4);
      return head.length == 4 && head[0] == 0x50 && head[1] == 0x4B && head[2] == 0x03 && head[3] == 0x04;
    } finally {
      await raf.close();
    }
  }

  String _fileNameFor(DownloadRecord row, _Transferred t) {
    final fromHeader = filenameFromContentDisposition(t.disposition);
    var name = fromHeader;
    if (name == null || name.isEmpty) {
      final seg = Uri.tryParse(row.sourceUrl)?.pathSegments.where((s) => s.isNotEmpty).lastOrNull;
      if (seg != null && p.extension(seg).isNotEmpty) name = Uri.decodeComponent(seg);
    }
    name = sanitizeFileName(name ?? row.title, fallback: 'download');
    if (p.extension(name).isEmpty) {
      final ext = extensionForContentType(t.contentType);
      if (ext != null) name += ext;
    }
    return name;
  }

  String _uniqueFile(String dir, String name) {
    final base = p.basenameWithoutExtension(name), ext = p.extension(name);
    var candidate = p.join(dir, name);
    for (var i = 1; File(candidate).existsSync(); i++) {
      candidate = p.join(dir, '$base ($i)$ext');
    }
    return candidate;
  }

  void dispose() {
    for (final t in _tokens.values) {
      t.cancel('dispose');
    }
    _completed.close();
  }
}

class _Transferred {
  _Transferred(this.file, this.bytes, this.contentType, this.disposition);
  final File file;
  final int bytes;
  final String contentType;
  final String? disposition;
}

// --- helpers (pure, unit-tested) ------------------------------------------------------------------------------

/// Makes a string safe as a single path segment (no separators, reserved
/// characters or control chars; bounded length).
String sanitizeFileName(String name, {String fallback = 'file'}) {
  var s = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_').trim();
  s = s.replaceAll(RegExp(r'^\.+'), '').replaceAll(RegExp(r'[. ]+$'), '');
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  if (s.length > 120) {
    final ext = p.extension(s);
    s = s.substring(0, 120 - ext.length) + ext;
  }
  return s.isEmpty ? fallback : s;
}

/// `attachment; filename="a b.mp3"` / `filename*=UTF-8''a%20b.mp3`.
String? filenameFromContentDisposition(String? header) {
  if (header == null) return null;
  final star = RegExp(r"filename\*\s*=\s*([^']*)'[^']*'([^;]+)", caseSensitive: false).firstMatch(header);
  if (star != null) {
    try {
      return Uri.decodeComponent(star.group(2)!.trim());
    } catch (_) {}
  }
  final plain = RegExp(r'filename\s*=\s*"([^"]+)"', caseSensitive: false).firstMatch(header) ??
      RegExp(r'filename\s*=\s*([^;]+)', caseSensitive: false).firstMatch(header);
  return plain?.group(1)?.trim();
}

String? extensionForContentType(String contentType) {
  final t = contentType.split(';').first.trim().toLowerCase();
  return const {
    'audio/mpeg': '.mp3',
    'audio/mp3': '.mp3',
    'audio/mp4': '.m4a',
    'audio/x-m4a': '.m4a',
    'audio/aac': '.aac',
    'audio/flac': '.flac',
    'audio/x-flac': '.flac',
    'audio/wav': '.wav',
    'audio/x-wav': '.wav',
    'audio/ogg': '.ogg',
    'audio/opus': '.opus',
    'application/zip': '.zip',
    'application/x-zip-compressed': '.zip',
  }[t];
}

/// Extracts only audio entries of [zipPath] into [outDir], flattening any
/// nested folders and rejecting path traversal (zip-slip). Existing files are
/// never overwritten. Returns the files written.
Future<List<String>> extractZipAudio(String zipPath, String outDir) async {
  await Directory(outDir).create(recursive: true);
  final input = InputFileStream(zipPath);
  final written = <String>[];
  try {
    final archive = ZipDecoder().decodeStream(input);
    for (final entry in archive) {
      if (!entry.isFile) continue;
      // Only the base name is used, so `../../evil.mp3` can never escape.
      final raw = entry.name.replaceAll('\\', '/').split('/').last;
      final name = sanitizeFileName(raw, fallback: '');
      if (name.isEmpty || !audioExtensions.contains(p.extension(name).toLowerCase())) continue;
      var dest = p.join(outDir, name);
      final base = p.basenameWithoutExtension(name), ext = p.extension(name);
      for (var i = 1; File(dest).existsSync(); i++) {
        dest = p.join(outDir, '$base ($i)$ext');
      }
      final out = OutputFileStream(dest);
      try {
        entry.writeContent(out);
      } finally {
        await out.close();
      }
      written.add(dest);
    }
  } finally {
    await input.close();
  }
  return written;
}
