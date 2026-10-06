import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings.dart';
import '../domain/lrc.dart';
import '../domain/lyrics_models.dart';

/// Reads lyrics that ship with the file: a sidecar `.lrc`, and (once the tag
/// reader lands in phase 9) embedded USLT/SYLT frames. Abstracted so tests and
/// the tag editor can plug in.
abstract class LocalLyricsSource {
  Future<({String? synced, String? plain})?> read(Song song);
}

class SidecarLyricsSource implements LocalLyricsSource {
  const SidecarLyricsSource();

  @override
  Future<({String? synced, String? plain})?> read(Song song) async {
    final path = song.embeddedLrcPath;
    if (path == null) return null;
    try {
      final text = await File(path).readAsString();
      final parsed = Lrc.parse(text);
      if (parsed.isSynced) return (synced: text, plain: Lrc.toPlain(parsed.lines));
      return text.trim().isEmpty ? null : (synced: null, plain: text);
    } catch (_) {
      return null;
    }
  }
}

class LyricsFetchOutcome {
  const LyricsFetchOutcome(this.resolved, {this.providerErrors = const {}});
  final ResolvedLyrics? resolved;
  final Map<String, String> providerErrors;
}

/// Lyrics resolution, caching and offsets (TP §5.6).
///
/// Resolution order (AP §11.17): embedded/sidecar synced lyrics always win;
/// remote providers are only consulted when nothing local exists. A remote
/// pick is cached forever in `lyrics_cache`.
class LyricsRepository {
  LyricsRepository(
    this._db, {
    required this._providers,
    required this._settings,
    List<LocalLyricsSource> localSources = const [SidecarLyricsSource()],
    DateTime Function()? clock,
    this.noResultTtl = const Duration(days: 7),
  })  : _local = localSources,
        _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Future<List<LyricsProvider>> Function() _providers;
  final AppSettings Function() _settings;
  final List<LocalLyricsSource> _local;
  final DateTime Function() _clock;

  /// How long a "provider had nothing" answer is remembered, so auto-fetch
  /// doesn't hammer the API for songs that simply have no lyrics.
  final Duration noResultTtl;

  static const noneProvider = 'none';

  Future<LyricsRecord?> _row(String songId) =>
      (_db.select(_db.lyricsCache)..where((t) => t.songId.equals(songId))).getSingleOrNull();

  Stream<LyricsRecord?> watchRow(String songId) =>
      (_db.select(_db.lyricsCache)..where((t) => t.songId.equals(songId))).watchSingleOrNull();

  Future<List<LyricsProvider>> orderedProviders() async {
    final all = await _providers();
    final s = _settings();
    final enabled = all.where((p) => !s.disabledLyricsProviders.contains(p.id)).toList();
    final order = s.lyricsProviderOrder;
    enabled.sort((a, b) {
      final ia = order.indexOf(a.id), ib = order.indexOf(b.id);
      return (ia < 0 ? 1 << 20 : ia).compareTo(ib < 0 ? 1 << 20 : ib);
    });
    return enabled;
  }

  /// What to show for [song] right now, without touching the network.
  Future<ResolvedLyrics?> resolveLocal(Song song) async {
    final row = await _row(song.id);
    final offset = row?.offsetMs ?? 0;

    // 1. Embedded / sidecar synced lyrics always win.
    for (final src in _local) {
      final local = await src.read(song);
      if (local != null && local.synced != null) {
        return ResolvedLyrics(
            source: 'embedded', providerId: 'embedded', synced: local.synced, plain: local.plain, offsetMs: offset);
      }
    }
    // 2. A cached remote pick.
    if (row != null && row.providerId != noneProvider && (row.syncedLrc != null || row.plainText != null)) {
      return ResolvedLyrics(
          source: row.source, providerId: row.providerId, synced: row.syncedLrc, plain: row.plainText, offsetMs: offset);
    }
    // 3. Local plain-only lyrics are better than nothing.
    for (final src in _local) {
      final local = await src.read(song);
      if (local != null && local.plain != null) {
        return ResolvedLyrics(source: 'embedded', providerId: 'embedded', plain: local.plain, offsetMs: offset);
      }
    }
    return null;
  }

  /// Auto-fetch path: tries each enabled provider in order ("try next provider
  /// on no-result" if enabled), caches the first hit, and remembers misses.
  Future<LyricsFetchOutcome> fetchAndCache(Song song, {bool ignoreNegativeCache = false}) async {
    final existing = await resolveLocal(song);
    if (existing != null && existing.hasSynced) return LyricsFetchOutcome(existing);

    final row = await _row(song.id);
    if (!ignoreNegativeCache &&
        row != null &&
        row.providerId == noneProvider &&
        _clock().difference(row.fetchedAt) < noResultTtl) {
      return LyricsFetchOutcome(existing);
    }

    final errors = <String, String>{};
    final tryAll = _settings().tryNextLyricsProvider;
    for (final p in await orderedProviders()) {
      try {
        final c = await p.fetchBest(
          title: song.title,
          artist: song.artist,
          album: song.album == 'Unknown album' ? null : song.album,
          durationSec: song.durationMs / 1000,
        );
        if (c != null && c.hasAnyLyrics) {
          await pick(song, c);
          return LyricsFetchOutcome(await resolveLocal(song), providerErrors: errors);
        }
      } catch (e) {
        errors[p.id] = e.toString();
      }
      if (!tryAll) break;
    }
    // Remember the miss, preserving any offset the user already set.
    await _db.into(_db.lyricsCache).insertOnConflictUpdate(LyricsCacheCompanion.insert(
          songId: song.id,
          providerId: noneProvider,
          source: 'remote',
          offsetMs: Value(row?.offsetMs ?? 0),
          fetchedAt: _clock(),
        ));
    return LyricsFetchOutcome(existing, providerErrors: errors);
  }

  /// The user's choice in the picker: cached and pinned to the song forever.
  Future<void> pick(Song song, LyricsCandidate c) async {
    final row = await _row(song.id);
    await _db.into(_db.lyricsCache).insertOnConflictUpdate(LyricsCacheCompanion.insert(
          songId: song.id,
          providerId: c.providerId,
          syncedLrc: Value(c.synced),
          plainText: Value(c.plain),
          source: 'remote',
          offsetMs: Value(row?.offsetMs ?? 0),
          fetchedAt: _clock(),
        ));
  }

  /// Picker search across providers (merged, synced results first).
  Future<List<LyricsCandidate>> search(String query) async {
    final out = <LyricsCandidate>[];
    for (final p in await orderedProviders()) {
      try {
        out.addAll(await p.search(query));
      } catch (_) {
        // A dead provider must not break the picker.
      }
    }
    out.sort((a, b) => (b.hasSynced ? 1 : 0).compareTo(a.hasSynced ? 1 : 0));
    return out;
  }

  /// ±200 ms nudge, saved per song, applied at render time only.
  Future<int> adjustOffset(Song song, int deltaMs) async {
    final row = await _row(song.id);
    final next = ((row?.offsetMs ?? 0) + deltaMs).clamp(-10000, 10000);
    await setOffset(song, next);
    return next;
  }

  Future<void> setOffset(Song song, int offsetMs) async {
    final row = await _row(song.id);
    if (row == null) {
      await _db.into(_db.lyricsCache).insert(LyricsCacheCompanion.insert(
            songId: song.id,
            providerId: noneProvider,
            source: 'remote',
            offsetMs: Value(offsetMs),
            fetchedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ));
    } else {
      await (_db.update(_db.lyricsCache)..where((t) => t.songId.equals(song.id)))
          .write(LyricsCacheCompanion(offsetMs: Value(offsetMs)));
    }
  }

  /// Settings → Lyrics → clear cache. Keeps per-song offsets.
  Future<void> clearCache() async {
    final rows = await _db.select(_db.lyricsCache).get();
    for (final r in rows) {
      if (r.offsetMs == 0) {
        await (_db.delete(_db.lyricsCache)..where((t) => t.songId.equals(r.songId))).go();
      } else {
        await (_db.update(_db.lyricsCache)..where((t) => t.songId.equals(r.songId))).write(
          const LyricsCacheCompanion(
            providerId: Value(noneProvider),
            syncedLrc: Value(null),
            plainText: Value(null),
          ),
        );
      }
    }
  }

  Future<int> cacheSize() async =>
      (await (_db.select(_db.lyricsCache)..where((t) => t.providerId.equals(noneProvider).not())).get()).length;
}
