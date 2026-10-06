import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/features/queue/data/queue_repository.dart';
import 'package:paattufy/features/queue/domain/queue_models.dart';
import 'package:paattufy/features/queue/domain/queue_sequence.dart';

import '../support/test_db.dart';

List<String> titles(QueueSnapshot s) => s.entries.map((e) => e.song.title).toList();

void main() {
  late AppDatabase db;
  late List<Song> songs; // [0]=Kanavugal [1]=Megam [2]=Poove [3]=Thendral ...
  late QueueRepository q;

  setUp(() async {
    (db, songs) = await seededDb();
    q = QueueRepository(db);
  });
  tearDown(() => db.close());

  group('QueueSequence', () {
    test('between: midpoint, open ends, multiple', () {
      expect(QueueSequence.between(1000, 2000, 1), [1500]);
      expect(QueueSequence.between(1000, 2000, 3), [1250, 1500, 1750]);
      expect(QueueSequence.between(3000, null, 2), [4000, 5000]);
      expect(QueueSequence.between(null, 3000, 2), [1000, 2000]);
      expect(QueueSequence.between(null, null, 2), [1000, 2000]);
    });

    test('needsCompaction only when the smallest gap gets tiny', () {
      expect(QueueSequence.needsCompaction([1000, 2000, 3000]), isFalse);
      expect(QueueSequence.needsCompaction([1000, 1000.0000001, 3000]), isTrue);
    });
  });

  test('playSingle clears the queue and leaves only that song', () async {
    await q.replaceWith(songs.take(5).toList(), description: 'Group');
    final s = await q.playSingle(songs[7]);
    expect(titles(s), [songs[7].title]);
    expect(s.current!.song.id, songs[7].id);
    expect(s.upcomingCount, 0);
  });

  test('playGroup (replaceWith) keeps group order and starts at the head',
      () async {
    final s = await q.replaceWith(songs.take(4).toList(), description: 'My group');
    expect(titles(s), songs.take(4).map((e) => e.title).toList());
    expect(s.currentIndex, 0);
    expect(s.sourceDescription, 'My group');
    expect(s.upcomingCount, 3);
  });

  test('playNext inserts immediately after current, preserving order', () async {
    await q.replaceWith(songs.take(3).toList()); // A B C, current A
    final s = await q.playNext([songs[8], songs[9]]);
    expect(titles(s), [
      songs[0].title,
      songs[8].title,
      songs[9].title,
      songs[1].title,
      songs[2].title,
    ]);
    expect(s.current!.song.id, songs[0].id); // current unchanged
  });

  test('playNext twice stacks newest first-after-current', () async {
    await q.replaceWith(songs.take(2).toList());
    await q.playNext([songs[5]]);
    final s = await q.playNext([songs[6]]);
    expect(titles(s), [songs[0].title, songs[6].title, songs[5].title, songs[1].title]);
  });

  test('addToQueue appends to the tail', () async {
    await q.replaceWith(songs.take(2).toList());
    final s = await q.addToQueue([songs[9], songs[10]]);
    expect(titles(s).skip(2), [songs[9].title, songs[10].title]);
  });

  test('playNow inserts at the front and becomes current; displaced song is next',
      () async {
    await q.replaceWith(songs.take(3).toList());
    await q.setPointer((await q.snapshot()).entries[1].id); // playing B
    final s = await q.playNow(songs[11]);
    expect(titles(s), [songs[0].title, songs[11].title, songs[1].title, songs[2].title]);
    expect(s.current!.song.id, songs[11].id);
    expect(s.upcoming.first.song.id, songs[1].id);
  });

  test('playNow on an empty queue just plays the song', () async {
    final s = await q.playNow(songs[3]);
    expect(titles(s), [songs[3].title]);
    expect(s.current!.song.id, songs[3].id);
  });

  test('reorder: drag to an index', () async {
    final start = await q.replaceWith(songs.take(5).toList());
    final ids = start.entries.map((e) => e.id).toList();
    var s = await q.move(ids[4], 1); // E -> index 1
    expect(titles(s), [songs[0], songs[4], songs[1], songs[2], songs[3]].map((e) => e.title));
    s = await q.move(ids[0], 4); // A -> end
    expect(titles(s).last, songs[0].title);
    s = await q.move(ids[0], 0); // and back to front
    expect(titles(s).first, songs[0].title);
  });

  test('remove: non-current, and current moves the pointer forward', () async {
    final start = await q.replaceWith(songs.take(3).toList());
    final ids = start.entries.map((e) => e.id).toList();
    var s = await q.remove(ids[1]);
    expect(titles(s), [songs[0].title, songs[2].title]);
    expect(s.current!.id, ids[0]);
    s = await q.remove(ids[0]); // removing current
    expect(s.current!.id, ids[2]);
    s = await q.remove(ids[2]);
    expect(s.isEmpty, isTrue);
    expect(s.currentItemId, isNull);
  });

  test('pointer and queue survive "process death" (re-read from tables)', () async {
    final start = await q.replaceWith(songs.take(4).toList(), description: 'Resume me');
    await q.setPointer(start.entries[2].id);
    await q.playNext([songs[9]]);

    final reborn = QueueRepository(db); // fresh repository over the same DB
    final s = await reborn.snapshot();
    expect(s.current!.song.id, songs[2].id);
    expect(s.sourceDescription, 'Resume me');
    expect(s.upcoming.first.song.id, songs[9].id);
  });

  test('suggested items: append, keep, drop', () async {
    await q.replaceWith(songs.take(2).toList());
    var s = await q.appendSuggested([songs[5], songs[6]]);
    expect(s.upcoming.where((e) => e.isSuggested), hasLength(2));
    await q.keepSuggested(s.upcoming.last.id);
    await q.dropUpcomingSuggested();
    s = await q.snapshot();
    expect(titles(s), [songs[0].title, songs[1].title, songs[6].title]);
    expect(s.entries.last.isSuggested, isFalse);
  });

  test('queuedSongIds is the hard-reject set', () async {
    await q.replaceWith([songs[0], songs[1]]);
    expect(await q.queuedSongIds(), {songs[0].id, songs[1].id});
  });

  test('shuffleUpcoming keeps current first and only permutes the rest', () async {
    await q.replaceWith(songs);
    final s = await q.shuffleUpcoming(Random(7));
    expect(s.current!.song.id, songs[0].id);
    expect(s.entries.first.song.id, songs[0].id);
    expect(s.entries.map((e) => e.song.id).toSet(), songs.map((e) => e.id).toSet());
    expect(titles(s), isNot(songs.map((e) => e.title).toList()));
  });

  test('many play-next insertions in the same gap trigger compaction, order holds',
      () async {
    await q.replaceWith(songs.take(2).toList()); // A B
    // 60 successive play-nexts after A each halve the gap; without compaction
    // this would exhaust double precision.
    for (var i = 0; i < 60; i++) {
      await q.playNext([songs[2 + i % 9]]);
    }
    final s = await q.snapshot();
    expect(s.entries, hasLength(62));
    expect(s.entries.first.song.id, songs[0].id);
    expect(s.entries.last.song.id, songs[1].id);
    final seqs = s.entries.map((e) => e.item.sequence).toList();
    expect([...seqs]..sort(), seqs, reason: 'snapshot order follows sequence');
    expect(seqs.toSet(), hasLength(62), reason: 'all sequences distinct');
  });

  test('watch() emits on mutation', () async {
    final stream = q.watch();
    final expectation = expectLater(
      stream.map((s) => s.entries.length),
      emitsInOrder([0, 2]),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await q.replaceWith(songs.take(2).toList());
    await expectation;
  });
}
