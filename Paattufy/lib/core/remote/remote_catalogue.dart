import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../constants.dart';
import '../database/app_database.dart';

class CatalogueResult {
  const CatalogueResult(this.json, this.fetchedAt, {this.fromCache = false, this.error});

  /// Parsed JSON document, or null if nothing could be fetched or cached.
  final Map<String, Object?>? json;
  final DateTime? fetchedAt;

  /// True when served from the local cache (304 Not Modified, or offline).
  final bool fromCache;

  /// Set when a refresh failed and stale cache (if any) is being served.
  final String? error;
}

/// Fetches and caches the GitHub-hosted catalogue JSON files (TP §7.8).
///
/// Uses a conditional GET with the previous response's ETag (stored in
/// `remote_catalogue_cache`), so unchanged files cost almost nothing. Offline,
/// the last good copy is served — the app never depends on the network
/// (AP §2 "Offline is the default").
class RemoteCatalogue {
  RemoteCatalogue(this._db, this._dio, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Dio _dio;
  final DateTime Function() _clock;

  static const downloadKey = 'download_catalogue';
  static const lyricsKey = 'lyrics_providers';

  Future<RemoteCatalogueEntry?> _cached(String key) =>
      (_db.select(_db.remoteCatalogueCache)..where((t) => t.key.equals(key))).getSingleOrNull();

  /// Cached copy only (no network).
  Future<CatalogueResult> cached(String key) async {
    final row = await _cached(key);
    if (row == null) return const CatalogueResult(null, null);
    return CatalogueResult(_decode(row.jsonBlob), row.fetchedAt, fromCache: true);
  }

  /// Returns the cached copy if it is younger than [maxAge]; otherwise
  /// refreshes. [force] skips the freshness check (manual "Refresh" tap).
  Future<CatalogueResult> get(
    String key,
    String url, {
    Duration maxAge = const Duration(hours: 24),
    bool force = false,
  }) async {
    final row = await _cached(key);
    if (!force && row != null && _clock().difference(row.fetchedAt) < maxAge) {
      return CatalogueResult(_decode(row.jsonBlob), row.fetchedAt, fromCache: true);
    }
    try {
      final res = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'User-Agent': appUserAgent,
            if (row?.etag != null) 'If-None-Match': row!.etag,
          },
          validateStatus: (s) => s != null && (s == 304 || (s >= 200 && s < 300)),
        ),
      );
      if (res.statusCode == 304 && row != null) {
        await _touch(key);
        return CatalogueResult(_decode(row.jsonBlob), _clock(), fromCache: true);
      }
      final body = res.data ?? '';
      final parsed = _decode(body);
      if (parsed == null) {
        return CatalogueResult(row == null ? null : _decode(row.jsonBlob), row?.fetchedAt,
            fromCache: row != null, error: 'Catalogue is not valid JSON');
      }
      final now = _clock();
      await _db.into(_db.remoteCatalogueCache).insertOnConflictUpdate(
            RemoteCatalogueCacheCompanion.insert(
              key: key,
              jsonBlob: body,
              etag: Value(res.headers.value('etag')),
              fetchedAt: now,
            ),
          );
      return CatalogueResult(parsed, now);
    } on DioException catch (e) {
      // Offline or server error: fall back to the last good copy.
      return CatalogueResult(row == null ? null : _decode(row.jsonBlob), row?.fetchedAt,
          fromCache: row != null, error: e.message ?? e.type.name);
    }
  }

  Future<void> _touch(String key) => (_db.update(_db.remoteCatalogueCache)..where((t) => t.key.equals(key)))
      .write(RemoteCatalogueCacheCompanion(fetchedAt: Value(_clock())));

  Map<String, Object?>? _decode(String body) {
    try {
      final v = jsonDecode(body);
      return v is Map ? v.cast<String, Object?>() : null;
    } catch (_) {
      return null;
    }
  }
}
