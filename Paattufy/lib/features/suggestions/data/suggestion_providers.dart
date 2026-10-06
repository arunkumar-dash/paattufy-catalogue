import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/settings/app_settings.dart';
import '../../library/data/library_providers.dart';
import '../../playback/data/playback_controller.dart';
import 'embedder.dart';
import 'feature_extractor.dart';
import 'feature_repository.dart';
import 'pcm_decoder.dart';
import 'suggestion_engine.dart';

final featureRepositoryProvider =
    Provider<FeatureRepository>((ref) => FeatureRepository(ref.watch(databaseProvider)));

final suggestionEngineProvider = Provider<SuggestionEngine>((ref) => SuggestionEngine(
      library: ref.watch(libraryRepositoryProvider),
      queue: ref.watch(queueRepositoryProvider),
      features: ref.watch(featureRepositoryProvider),
      stats: ref.watch(playStatsRepositoryProvider),
      settings: () => ref.read(settingsProvider),
    ));

/// Overrides the (null) default top-up hook of the playback controller.
final suggestionTopUpOverride = queueTopUpProvider.overrideWith((ref) {
  final engine = ref.watch(suggestionEngineProvider);
  return () async {
    await engine.topUp();
  };
});

/// The embedder is optional (model asset may be absent) — resolved once.
final embedderProvider = FutureProvider<AudioEmbedder?>((ref) async {
  final e = await YamnetEmbedder.tryLoad();
  if (e != null) ref.onDispose(e.close);
  return e;
});

final featureExtractorProvider = FutureProvider<FeatureExtractor>((ref) async {
  return FeatureExtractor(
    decoder: NativePcmDecoder(),
    repository: ref.watch(featureRepositoryProvider),
    embedder: await ref.watch(embedderProvider.future),
  );
});

/// `analysed / total` for Settings → Suggestions.
class AnalysisProgress {
  const AnalysisProgress({this.analysed = 0, this.total = 0, this.running = false});
  final int analysed;
  final int total;
  final bool running;
}

class AnalysisController extends Notifier<AnalysisProgress> {
  bool _cancel = false;

  @override
  AnalysisProgress build() => const AnalysisProgress();

  Future<void> refresh() async {
    final repo = ref.read(featureRepositoryProvider);
    final p = await repo.progress('');
    state = AnalysisProgress(analysed: p.analysed, total: p.total, running: state.running);
  }

  /// User-initiated foreground analysis ("Analyse now"), in small batches so it
  /// stays responsive and can be cancelled. The background scheduler does the
  /// same work opportunistically while charging.
  Future<void> runNow({int batch = 3}) async {
    if (state.running) return;
    _cancel = false;
    state = AnalysisProgress(analysed: state.analysed, total: state.total, running: true);
    try {
      final extractor = await ref.read(featureExtractorProvider.future);
      final library = ref.read(libraryRepositoryProvider);
      while (!_cancel) {
        final excluded = await library.excludedFolders();
        final n = await extractor.runBatch(limit: batch, excludedFolders: excluded, shouldContinue: () => !_cancel);
        await refresh();
        if (n == 0) break;
      }
    } finally {
      state = AnalysisProgress(analysed: state.analysed, total: state.total);
    }
  }

  void cancel() => _cancel = true;
}

final analysisControllerProvider =
    NotifierProvider<AnalysisController, AnalysisProgress>(AnalysisController.new);
