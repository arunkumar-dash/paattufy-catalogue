import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/features/playback/data/playback_controller.dart';
import 'package:paattufy/features/playback/domain/audio_engine.dart';
import 'package:paattufy/features/queue/data/queue_repository.dart';

import '../support/container.dart';
import '../support/fake_audio_engine.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late List<Song> songs;
  late FakeAudioEngine engine;
  late ProviderContainer c;
  late PlaybackController ctl;
  late QueueRepository queue;

  Future<void> boot({Map<String, Object> prefs = const {}}) async {
    c = await makeContainer(db, engine, prefs: prefs);
    ctl = c.read(playbackControllerProvider.notifier);
    queue = c.read(queueRepositoryProvider);
    await ctl.init();
  }

  setUp(() async {
    (db, songs) = await seededDb();
    engine = FakeAudioEngine();
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  test('playSongs loads the group in order and starts playing at the head', () async {
    await boot();
    await ctl.playSongs(songs.take(4).toList(), description: 'Grp');
    expect(engine.tracks.map((t) => t.song.title), songs.take(4).map((s) => s.title));
    expect(engine.playing, isTrue);
    final st = c.read(playbackControllerProvider);
    expect(st.current!.id, songs[0].id);
    expect((await queue.snapshot()).sourceDescription, 'Grp');
  });

  test('playSong clears the queue (single song)', () async {
    await boot();
    await ctl.playSongs(songs.take(4).toList());
    await ctl.playSong(songs[9]);
    expect(engine.tracks, hasLength(1));
    expect((await queue.snapshot()).entries, hasLength(1));
  });

  test('playNext/addToQueue edit the loaded queue in place (no reload, gapless)',
      () async {
    await boot();
    await ctl.playSongs(songs.take(3).toList());
    final loadsBefore = engine.setTracksCalls;
    await ctl.playNext([songs[8]]);
    await ctl.addToQueue([songs[9]]);
    expect(engine.setTracksCalls, loadsBefore, reason: 'no full reload');
    expect(engine.tracks.map((t) => t.song.title), [
      songs[0].title, songs[8].title, songs[1].title, songs[2].title, songs[9].title,
    ]);
    expect(engine.playing, isTrue);
    expect(c.read(playbackControllerProvider).current!.id, songs[0].id);
  });

  test('reorder and remove keep the engine in step with the DB', () async {
    await boot();
    await ctl.playSongs(songs.take(4).toList());
    final snap = await queue.snapshot();
    await ctl.reorder(snap.entries[3].id, 1);
    await ctl.removeFromQueue(snap.entries[2].id);
    final db2 = await queue.snapshot();
    expect(engine.loadedQueueItemIds, db2.entries.map((e) => e.id).toList());
  });

  test('skipNext advances the persisted pointer', () async {
    await boot();
    await ctl.playSongs(songs.take(3).toList());
    await ctl.skipNext();
    expect(c.read(playbackControllerProvider).current!.id, songs[1].id);
    expect((await queue.snapshot()).current!.song.id, songs[1].id);
    expect(engine.currentIndex, 1);
  });

  group('skip-back rule (AP §3.4)', () {
    test('more than 3 s in: restart the current song', () async {
      await boot();
      await ctl.playSongs(songs.take(3).toList());
      await ctl.skipNext();
      engine.emitPosition(const Duration(seconds: 5));
      await ctl.skipPrevious();
      expect(engine.currentIndex, 1, reason: 'still on the same song');
      expect(engine.position, Duration.zero);
    });

    test('under 3 s in: go back exactly one song', () async {
      await boot();
      await ctl.playSongs(songs.take(4).toList());
      await ctl.skipNext();
      await ctl.skipNext(); // on index 2
      engine.emitPosition(const Duration(seconds: 1));
      await ctl.skipPrevious();
      expect(engine.currentIndex, 1, reason: 'one back, never two');
      expect((await queue.snapshot()).current!.song.id, songs[1].id);
    });

    test('at the first item it just restarts', () async {
      await boot();
      await ctl.playSongs(songs.take(3).toList());
      engine.emitPosition(const Duration(seconds: 1));
      await ctl.skipPrevious();
      expect(engine.currentIndex, 0);
      expect(engine.position, Duration.zero);
    });

    test('window comes from settings', () async {
      await boot(prefs: {'skip_back_window_ms': 500});
      await ctl.playSongs(songs.take(3).toList());
      await ctl.skipNext();
      engine.emitPosition(const Duration(seconds: 1)); // > 500 ms → restart
      await ctl.skipPrevious();
      expect(engine.currentIndex, 1);
    });
  });

  test('natural advance moves the DB pointer and UI state', () async {
    await boot();
    await ctl.playSongs(songs.take(3).toList());
    engine.advanceNaturally();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(c.read(playbackControllerProvider).current!.id, songs[1].id);
    expect((await queue.snapshot()).current!.song.id, songs[1].id);
  });

  test('stats: listened ≥ threshold counts a play; early skip counts a skip',
      () async {
    await boot();
    await ctl.playSongs(songs.take(3).toList());
    engine.emitPosition(const Duration(seconds: 2)); // song0 is 4 s → threshold 2 s
    await ctl.skipNext();
    await ctl.skipNext(); // song1 (3.5 s) left at 0 s → skip
    final stats = c.read(playStatsRepositoryProvider);
    final a = await stats.statFor(songs[0].id);
    final b = await stats.statFor(songs[1].id);
    expect(a!.playCount, 1);
    expect(a.skipCount, 0);
    expect(b!.playCount, 0);
    expect(b.skipCount, 1);
    expect(a.lastPlayedAt, isNotNull);
  });

  test('speed/pitch: preserve-pitch off drifts pitch with speed; on holds 1.0',
      () async {
    await boot();
    await ctl.setSpeed(1.5);
    expect(engine.speed, 1.5);
    expect(engine.pitch, 1.5);
    await ctl.setPreservePitch(true);
    expect(engine.pitch, 1.0);
    await ctl.setSpeed(0.75);
    expect(engine.pitch, 1.0);
    await ctl.setPreservePitch(false);
    expect(engine.pitch, 0.75);
  });

  test('repeat cycles off → queue → one → off', () async {
    await boot();
    expect(c.read(playbackControllerProvider).repeat, RepeatMode.off);
    await ctl.cycleRepeat();
    expect(engine.repeat, RepeatMode.all);
    await ctl.cycleRepeat();
    expect(engine.repeat, RepeatMode.one);
    await ctl.cycleRepeat();
    expect(engine.repeat, RepeatMode.off);
  });

  test('every route change STOPS playback and preserves queue + position',
      () async {
    await boot();
    await ctl.playSongs(songs.take(4).toList());
    await ctl.skipNext();
    engine.emitPosition(const Duration(seconds: 2));
    await ctl.handleRouteChange('bluetooth:Buds');
    expect(engine.stopCalls, 1);
    expect(engine.playing, isFalse);
    final st = c.read(playbackControllerProvider);
    expect(st.stoppedByRouteChange, isTrue);
    expect(st.route, 'bluetooth:Buds');
    final snap = await queue.snapshot();
    expect(snap.entries, hasLength(4));
    expect(snap.current!.song.id, songs[1].id);

    // One tap on play resumes exactly there.
    await ctl.play();
    expect(engine.playing, isTrue);
    expect(engine.currentIndex, 1);
    expect(engine.lastSetTracksPosition, const Duration(seconds: 2));
    expect(c.read(playbackControllerProvider).stoppedByRouteChange, isFalse);
  });

  test('resume after process death: queue, pointer, position, modes restored',
      () async {
    await boot();
    await ctl.playSongs(songs.take(4).toList(), description: 'Resume me');
    await ctl.skipNext();
    await ctl.setSpeed(1.25);
    await ctl.cycleRepeat();
    engine.emitPosition(const Duration(seconds: 3));
    await ctl.flushState();
    c.dispose();

    // "Relaunch": fresh container + fresh engine over the same database.
    engine = FakeAudioEngine();
    await boot();
    expect(engine.tracks, hasLength(4));
    expect(engine.currentIndex, 1);
    expect(engine.lastSetTracksPosition, const Duration(seconds: 3));
    expect(engine.speed, 1.25);
    expect(engine.repeat, RepeatMode.all);
    expect(engine.playing, isFalse, reason: 'restore never auto-plays');
    final st = c.read(playbackControllerProvider);
    expect(st.current!.id, songs[1].id);
    expect(st.ready, isTrue);
  });

  test('resumeOnLaunch=false starts empty', () async {
    await boot();
    await ctl.playSongs(songs.take(2).toList());
    c.dispose();
    engine = FakeAudioEngine();
    await boot(prefs: {'resume_on_launch': false});
    expect(engine.tracks, isEmpty);
    expect(c.read(playbackControllerProvider).current, isNull);
  });

  test('playNow puts the song at the front and plays it immediately', () async {
    await boot();
    await ctl.playSongs(songs.take(3).toList());
    await ctl.playNow(songs[11]);
    expect(engine.currentIndex, 0);
    expect(engine.tracks.first.song.id, songs[11].id);
    expect(c.read(playbackControllerProvider).current!.id, songs[11].id);
    expect(engine.playing, isTrue);
  });

  test('toggleShuffle reorders upcoming only, current stays put', () async {
    await boot();
    await ctl.playSongs(songs);
    await ctl.toggleShuffle();
    expect(c.read(playbackControllerProvider).shuffle, isTrue);
    expect(engine.tracks.first.song.id, songs[0].id);
    expect(engine.tracks.map((t) => t.song.id).toSet(), songs.map((s) => s.id).toSet());
    expect(engine.loadedQueueItemIds,
        (await queue.snapshot()).entries.map((e) => e.id).toList());
  });

  test('queue top-up hook runs when fewer than 10 songs are upcoming', () async {
    var calls = 0;
    c = await makeContainer(db, engine, extra: [
      queueTopUpProvider.overrideWithValue(() async {
        calls++;
        final q = c.read(queueRepositoryProvider);
        final snap = await q.snapshot();
        if (snap.upcomingCount < 10) {
          await q.appendSuggested(songs.skip(3).take(10 - snap.upcomingCount).toList());
        }
      }),
    ]);
    ctl = c.read(playbackControllerProvider.notifier);
    queue = c.read(queueRepositoryProvider);
    await ctl.init();
    await ctl.playSongs(songs.take(3).toList());
    expect(calls, greaterThan(0));
    final snap = await queue.snapshot();
    expect(snap.upcomingCount, 10);
    expect(snap.upcoming.where((e) => e.isSuggested), hasLength(8));
    expect(engine.loadedQueueItemIds, snap.entries.map((e) => e.id).toList(),
        reason: 'engine synced with topped-up queue');
  });

  test('persisted modes round-trip through playback_state', () async {
    await boot();
    await ctl.setSpeed(1.75);
    await ctl.setPreservePitch(true);
    final row = await db.select(db.playbackStates).getSingle();
    expect(row.speed, 1.75);
    expect(row.preservePitch, isTrue);
  });
}
