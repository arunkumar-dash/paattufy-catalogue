import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/database/app_database.dart';
import '../../library/data/library_repository.dart';
import 'embedder.dart';
import 'feature_extractor.dart';
import 'feature_repository.dart';
import 'pcm_decoder.dart';

const analysisTaskName = 'paattufy.audio-analysis';
const analysisUniqueName = 'paattufy.audio-analysis.periodic';

/// Songs analysed per background wake (TP §5.7: "capped, e.g. 5 songs per wake").
const analysisBatchPerWake = 5;

/// Entry point run by workmanager in a background engine. Because the native
/// channels live in the `paattufy_native` plugin, `audio_decode` exists here.
@pragma('vm:entry-point')
void analysisCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != analysisTaskName) return true;
    final db = AppDatabase.onDisk(); // WAL: safe alongside the UI's connection
    YamnetEmbedder? embedder;
    try {
      embedder = await YamnetEmbedder.tryLoad();
      final excluded = await LibraryRepository(db).excludedFolders();
      final extractor = FeatureExtractor(
        decoder: NativePcmDecoder(),
        repository: FeatureRepository(db),
        embedder: embedder,
      );
      await extractor.runBatch(limit: analysisBatchPerWake, excludedFolders: excluded);
      return true;
    } catch (e) {
      debugPrint('analysis task failed: $e');
      return false; // let WorkManager back off and retry
    } finally {
      embedder?.close();
      await db.close();
    }
  });
}

/// Schedules opportunistic analysis: only while charging (AP §3.7a "never
/// during playback on battery"), in small batches, so it costs nothing at play
/// time.
class AnalysisScheduler {
  static Future<void> register() async {
    await Workmanager().initialize(analysisCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      analysisUniqueName,
      analysisTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresCharging: true,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> cancel() => Workmanager().cancelByUniqueName(analysisUniqueName);
}
