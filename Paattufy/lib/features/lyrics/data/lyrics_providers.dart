import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/http_providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../playback/data/playback_controller.dart';
import '../../library/data/tag_service.dart';
import '../domain/lyrics_models.dart';
import 'declarative_provider.dart';
import 'lyrics_catalogue.dart';
import 'lyrics_repository.dart';

final lyricsCatalogueProvider =
    Provider<LyricsCatalogue>((ref) => LyricsCatalogue(ref.watch(remoteCatalogueProvider)));

/// Built-in LRCLIB merged with the remote catalogue (refreshed at most daily,
/// or on demand from Settings).
final lyricsProviderSpecsProvider = FutureProvider<List<ProviderSpec>>((ref) {
  final url = ref.watch(settingsProvider.select((s) => s.lyricsCatalogueUrl));
  return ref.watch(lyricsCatalogueProvider).providers(url);
});

final lyricsProvidersProvider = FutureProvider<List<LyricsProvider>>((ref) async {
  final specs = await ref.watch(lyricsProviderSpecsProvider.future);
  final dio = ref.watch(dioProvider);
  return [for (final s in specs) DeclarativeLyricsProvider(s, dio)];
});

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  return LyricsRepository(
    ref.watch(databaseProvider),
    providers: () => ref.read(lyricsProvidersProvider.future),
    settings: () => ref.read(settingsProvider),
    localSources: [const SidecarLyricsSource(), TagLyricsSource(ref.read(tagServiceProvider))],
  );
});

/// Lyrics for the currently playing song, re-resolved when the song or its
/// cached row (pick / offset) changes. Triggers the auto-fetch when enabled.
final currentLyricsProvider = StreamProvider<ResolvedLyrics?>((ref) async* {
  final song = ref.watch(playbackControllerProvider.select((s) => s.current));
  if (song == null) {
    yield null;
    return;
  }
  final repo = ref.watch(lyricsRepositoryProvider);
  final auto = ref.read(settingsProvider).autoFetchLyrics;
  yield await repo.resolveLocal(song);
  if (auto) {
    try {
      final out = await repo.fetchAndCache(song);
      yield out.resolved;
    } on DioException {
      // Offline: local/cached lyrics (already yielded) stay on screen.
    }
  }
  await for (final _ in repo.watchRow(song.id)) {
    yield await repo.resolveLocal(song);
  }
});

/// Picker search state (AP §5.6): editable query → candidates.
final lyricsSearchProvider =
    FutureProvider.autoDispose.family<List<LyricsCandidate>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  return ref.watch(lyricsRepositoryProvider).search(query);
});

String defaultLyricsQuery(Song s) =>
    '${s.title} ${s.artist == 'Unknown artist' ? '' : s.artist}'.trim();
