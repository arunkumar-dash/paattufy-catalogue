import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/library/data/library_repository.dart';
import 'package:paattufy/features/playback/data/play_stats_repository.dart';
import 'package:paattufy/features/playback/data/playback_controller.dart';
import 'package:paattufy/features/queue/data/queue_repository.dart';
import 'package:paattufy/features/suggestions/data/embedder.dart';
import 'package:paattufy/features/suggestions/data/feature_extractor.dart';
import 'package:paattufy/features/suggestions/data/feature_repository.dart';
import 'package:paattufy/features/suggestions/data/suggestion_engine.dart';
import 'package:paattufy/features/suggestions/data/suggestion_providers.dart';
import 'package:paattufy/features/suggestions/domain/audio_features.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/container.dart';
import '../support/fake_audio_engine.dart';
import '../support/fake_pcm_decoder.dart';
import '../support/test_db.dart';

class FakeEmbedder implements AudioEmbedder {
  int calls = 0;
  int lastFrameCount = 0;
  @override
  String get version => 'fake-v1';
  @override
  Future<Float32List?> embed(List<Float32List> frames16k) async {
    calls++;
    lastFrameCount = frames16k.length;
    return Float32List.fromList([for (var i = 0; i < 64; i++) i == 5 ? 1.0 : 0.0]);
  }

  @override
  void close() {}
}

void main() {
  late AppDatabase db;
  late List<Song> songs;
  late FeatureRepository repo;

  setUp(() async {
    (db, songs) = await seededDb();
    repo = FeatureRepository(db);
  });
  tearDown(() => db.close());

  group('FeatureExtractor', () {
    test('analyses songs, persists features, skips already-analysed ones', () async {
      final decoder = FakePcmDecoder({for (final s in songs) s.contentUri: synthTone(440)});
      final x = FeatureExtractor(decoder: decoder, repository: repo);
      expect(x.version, 'heuristic-v1');

      expect(await x.runBatch(limit: 5), 5);
      expect((await repo.progress(x.version)).analysed, 5);
      expect(await x.runBatch(limit: 100), 7, reason: 'only the remaining songs');
      expect(await x.runBatch(limit: 5), 0, reason: 'idempotent: nothing left to do');

      final f = await repo.featuresFor(songs.first.id);
      expect(f, isNotNull);
      expect(f!.tempoBpm, inInclusiveRange(60, 180));
      expect(f.hasEmbedding, isFalse, reason: 'no model bundled → heuristics only');
      expect(decoder.decoded.toSet().length, 12);
    });

    test('unanalysable files are marked failed and never retried', () async {
      final decoder = FakePcmDecoder({}); // nothing decodes
      final x = FeatureExtractor(decoder: decoder, repository: repo);
      expect(await x.runBatch(limit: 3), 0);
      final calls = decoder.decoded.length;
      expect(calls, 3);
      await x.runBatch(limit: 3); // next batch → different songs, not the failed 3
      expect(decoder.decoded.toSet().length, 6);
      expect(await repo.featuresFor(songs.first.id), isNull, reason: 'failed markers are not features');
      expect((await repo.loadVectors()), isEmpty);
    });

    test('excerpt is a centred 60 s window for long songs, whole file for short', () async {
      final decoder = FakePcmDecoder({});
      final x = FeatureExtractor(decoder: decoder, repository: repo);
      final long = songs.first.copyWith(durationMs: 300000);
      await x.extract(long);
      expect(decoder.lastWindow, (startMs: 120000, durationMs: 60000));
      await x.extract(songs.first.copyWith(durationMs: 40000));
      expect(decoder.lastWindow, (startMs: 0, durationMs: 60000));
    });

    test('with an embedder: 3 frames, embedding stored, version bump triggers re-analysis',
        () async {
      final signals = {for (final s in songs) s.contentUri: synthTone(330, seconds: 8)};
      final plain = FeatureExtractor(decoder: FakePcmDecoder(signals), repository: repo);
      await plain.runBatch(limit: 100);
      expect(await plain.runBatch(limit: 100), 0);

      final emb = FakeEmbedder();
      final upgraded = FeatureExtractor(decoder: FakePcmDecoder(signals), repository: repo, embedder: emb);
      expect(upgraded.version, 'heuristic-v1+fake-v1');
      expect(await upgraded.runBatch(limit: 4), 4, reason: 'older rows are re-analysed');
      expect(emb.lastFrameCount, 3);
      final vectors = await repo.loadVectors();
      expect(vectors.values.where((v) => v.embedding != null), hasLength(4),
          reason: 'exactly the 4 re-analysed songs now carry an embedding');
      expect(vectors.values.where((v) => v.embedding == null), hasLength(8));
    });

    test('too-short audio counts as failed', () async {
      final x = FeatureExtractor(
        decoder: FakePcmDecoder({songs.first.contentUri: Float32List(100)}),
        repository: repo,
      );
      expect(await x.analyse(songs.first), isFalse);
    });

    test('excluded folders are not analysed', () async {
      final decoder = FakePcmDecoder({for (final s in songs) s.contentUri: synthTone(440)});
      final x = FeatureExtractor(decoder: decoder, repository: repo);
      await x.runBatch(limit: 100, excludedFolders: ['/storage/emulated/0/Music/Ilaiyaraaja']);
      expect(decoder.decoded.length, 8);
    });
  });

  test('RandomProjection is deterministic and roughly preserves angles', () {
    final a = RandomProjection();
    final b = RandomProjection();
    final v = Float32List.fromList([for (var i = 0; i < 1024; i++) (i % 7) - 3.0]);
    expect(a.project(v), b.project(v));
    final w = Float32List.fromList([for (var i = 0; i < 1024; i++) (i % 7) - 3.0 + (i % 2 == 0 ? 0.2 : -0.2)]);
    final u = Float32List.fromList([for (var i = 0; i < 1024; i++) ((i * 13) % 11) - 5.0]);
    double cos(Float32List x, Float32List y) {
      var d = 0.0, nx = 0.0, ny = 0.0;
      for (var i = 0; i < x.length; i++) {
        d += x[i] * y[i];
        nx += x[i] * x[i];
        ny += y[i] * y[i];
      }
      return d / (nx.sqrt() * ny.sqrt());
    }

    expect(cos(a.project(v), a.project(w)), greaterThan(cos(a.project(v), a.project(u))));
  });

  group('SuggestionEngine top-up', () {
    late LibraryRepository lib;
    late QueueRepository queue;
    late SuggestionEngine engine;
    var mode = SuggestionMode.metadata;

    setUp(() {
      lib = LibraryRepository(db);
      queue = QueueRepository(db);
      mode = SuggestionMode.metadata;
      engine = SuggestionEngine(
        library: lib,
        queue: queue,
        features: repo,
        stats: PlayStatsRepository(db),
        settings: () => AppSettings(suggestionMode: mode),
      );
    });

    test('tops up to exactly 10 upcoming, tagged suggested, never duplicating the queue',
        () async {
      await queue.replaceWith([songs[0], songs[1]]); // 1 upcoming
      final added = await engine.topUp();
      expect(added, hasLength(9));
      final snap = await queue.snapshot();
      expect(snap.upcomingCount, 10);
      expect(snap.upcoming.where((e) => e.isSuggested), hasLength(9));
      expect(snap.entries.map((e) => e.song.id).toSet(), hasLength(11), reason: 'no duplicates');
    });

    test('draws from the whole library, not just the playing artist/group', () async {
      await queue.replaceWith([songs[0]]); // Ilaiyaraaja only
      await engine.topUp();
      final artists = (await queue.snapshot()).entries.map((e) => e.song.artist).toSet();
      expect(artists.length, greaterThan(1));
    });

    test('Metadata mode: same artist songs come first', () async {
      await queue.replaceWith([songs[0]]); // Ilaiyaraaja
      await engine.topUp();
      final firstThree = (await queue.snapshot()).upcoming.take(3).map((e) => e.song.artist);
      expect(firstThree.every((a) => a == 'Ilaiyaraaja'), isTrue);
    });

    test('does nothing when 10+ are already upcoming or the queue is empty', () async {
      expect(await engine.topUp(), isEmpty);
      await queue.replaceWith(songs); // 11 upcoming
      expect(await engine.topUp(), isEmpty);
    });

    test('Mood mode uses audio features; songs without them fall back to metadata', () async {
      mode = SuggestionMode.mood;
      // Analyse only two songs: one calm/low, one loud/bright.
      await repo.save(
          songs[0].id,
          const AudioFeatures(tempoBpm: 70, keyIndex: 9, keyMode: 0, energy: 0.2, acousticness: 0.9, brightness: 0.2, danceability: 0.2),
          'heuristic-v1');
      await repo.save(
          songs[5].id,
          const AudioFeatures(tempoBpm: 75, keyIndex: 9, keyMode: 0, energy: 0.22, acousticness: 0.88, brightness: 0.22, danceability: 0.22),
          'heuristic-v1');
      await repo.save(
          songs[6].id,
          const AudioFeatures(tempoBpm: 175, keyIndex: 2, keyMode: 1, energy: 0.95, acousticness: 0.1, brightness: 0.9, danceability: 0.9),
          'heuristic-v1');
      await queue.replaceWith([songs[0]]);
      final ranked = await engine.rank();
      final pos = {for (var i = 0; i < ranked.length; i++) ranked[i].song.id: i};
      expect(pos[songs[5].id]!, lessThan(pos[songs[6].id]!), reason: 'mood-similar beats mood-dissimilar');
      expect(ranked.firstWhere((s) => s.song.id == songs[5].id).usedMood, isTrue);
      expect(ranked.firstWhere((s) => s.song.id == songs[1].id).usedMood, isFalse);
    });

    test('recently played songs are pushed down', () async {
      final stats = PlayStatsRepository(db);
      await queue.replaceWith([songs[0]]);
      await stats.recordPlayStarted(songs[1].id, DateTime.now()); // same artist, just played
      final ranked = await engine.rank();
      final pos = {for (var i = 0; i < ranked.length; i++) ranked[i].song.id: i};
      expect(pos[songs[2].id]!, lessThan(pos[songs[1].id]!));
    });
  });

  group('controller integration', () {
    test('playing a group auto-tops-up the queue and keeps the engine in sync', () async {
      final engine = FakeAudioEngine();
      SharedPreferences.setMockInitialValues({'suggestion_mode': 'metadata'});
      final c = await makeContainer(db, engine,
          prefs: {'suggestion_mode': 'metadata'}, extra: [suggestionTopUpOverride]);
      addTearDown(c.dispose);
      final ctl = c.read(playbackControllerProvider.notifier);
      await ctl.init();
      await ctl.playSongs(songs.take(3).toList());
      final snap = await c.read(queueRepositoryProvider).snapshot();
      expect(snap.upcomingCount, 10);
      expect(engine.loadedQueueItemIds, snap.entries.map((e) => e.id).toList());
    });

    test('manual edits drop and recompute suggestions; "keep" survives', () async {
      final engine = FakeAudioEngine();
      final c = await makeContainer(db, engine,
          prefs: {'suggestion_mode': 'metadata'}, extra: [suggestionTopUpOverride]);
      addTearDown(c.dispose);
      final ctl = c.read(playbackControllerProvider.notifier);
      final q = c.read(queueRepositoryProvider);
      await ctl.init();
      await ctl.playSongs([songs[0], songs[4]]);
      var snap = await q.snapshot();
      final kept = snap.upcoming.firstWhere((e) => e.isSuggested);
      await ctl.keepSuggested(kept.id);

      await ctl.playNext([songs[11]]);
      snap = await q.snapshot();
      expect(snap.upcoming.first.song.id, songs[11].id, reason: 'play next goes immediately after current');
      expect(snap.entries.any((e) => e.id == kept.id && !e.isSuggested), isTrue, reason: 'kept item survived');
      expect(snap.upcomingCount, 10, reason: 'topped back up');
      expect(engine.loadedQueueItemIds, snap.entries.map((e) => e.id).toList());
    });

    test('dismissing a suggestion removes it and counts a skip', () async {
      final engine = FakeAudioEngine();
      final c = await makeContainer(db, engine,
          prefs: {'suggestion_mode': 'metadata'}, extra: [suggestionTopUpOverride]);
      addTearDown(c.dispose);
      final ctl = c.read(playbackControllerProvider.notifier);
      await ctl.init();
      await ctl.playSongs([songs[0]]);
      final snap = await c.read(queueRepositoryProvider).snapshot();
      final victim = snap.upcoming.first;
      await ctl.dismissSuggested(victim.id);
      final stat = await c.read(playStatsRepositoryProvider).statFor(victim.song.id);
      expect(stat!.skipCount, 1);
    });
  });
}

extension on double {
  double sqrt() => this <= 0 ? 0 : _sqrt(this);
}

double _sqrt(double x) {
  var g = x / 2;
  for (var i = 0; i < 30; i++) {
    g = (g + x / g) / 2;
  }
  return g;
}
