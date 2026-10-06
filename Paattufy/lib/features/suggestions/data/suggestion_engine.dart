import '../../../core/constants.dart';
import '../../../core/entities/entities.dart';
import '../../../core/settings/app_settings.dart';
import '../../library/data/library_repository.dart';
import '../../playback/data/play_stats_repository.dart';
import '../../queue/data/queue_repository.dart';
import '../domain/scoring.dart';
import 'feature_repository.dart';

/// Tops the queue up to 10 upcoming songs (AP §3.4, TP §5.3).
///
/// Suggestions derive from **all songs currently in the queue** (not a single
/// seed) and the candidate pool is the **whole library**, never just the
/// playing group (AP §11.15).
class SuggestionEngine {
  SuggestionEngine({
    required this._library,
    required this._queue,
    required this._features,
    required this._stats,
    required this._settings,
    this._scorer = const SuggestionScorer(),
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now;

  final LibraryRepository _library;
  final QueueRepository _queue;
  final FeatureRepository _features;
  final PlayStatsRepository _stats;
  final AppSettings Function() _settings;
  final SuggestionScorer _scorer;
  final DateTime Function() _clock;

  bool _running = false;

  /// Ranked suggestions for the current queue (best first).
  Future<List<ScoredSong>> rank() async {
    final snap = await _queue.snapshot();
    final candidates = await _library.allVisibleSongs();
    final stats = await _stats.allStats();
    final history = {
      for (final e in stats.entries)
        e.key: SongHistory(
          playCount: e.value.playCount,
          skipCount: e.value.skipCount,
          lastPlayedAt: e.value.lastPlayedAt,
        ),
    };
    final mode = _settings().suggestionMode;
    final features = mode == SuggestionMode.mood ? await _features.loadVectors() : <String, SongFeatureVector>{};
    return _scorer.rank(
      mode: mode,
      queue: [for (final e in snap.entries) e.song],
      candidates: candidates,
      features: features,
      history: history,
      now: _clock(),
    );
  }

  /// Appends enough `suggested` songs to reach [queueTopUpTarget] upcoming.
  /// Safe to call repeatedly / concurrently.
  Future<List<Song>> topUp() async {
    if (_running) return const [];
    _running = true;
    try {
      final snap = await _queue.snapshot();
      if (snap.isEmpty) return const []; // nothing to base suggestions on
      final need = queueTopUpTarget - snap.upcomingCount;
      if (need <= 0) return const [];
      final ranked = await rank();
      final picks = [for (final s in ranked.take(need)) s.song];
      if (picks.isNotEmpty) await _queue.appendSuggested(picks);
      return picks;
    } finally {
      _running = false;
    }
  }
}
