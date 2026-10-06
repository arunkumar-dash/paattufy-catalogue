import 'dart:math';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/queue_models.dart';
import '../domain/queue_sequence.dart';

/// The deque, persisted (TP §5.3).
///
/// Every mutation is one Drift transaction against `queue_items` /
/// `queue_pointer`. There is no separate in-memory queue that could diverge,
/// so an abrupt process kill loses nothing (AP §8.16): on relaunch the queue
/// is simply re-read from the tables.
class QueueRepository {
  QueueRepository(this._db);

  final AppDatabase _db;

  // --- reading -----------------------------------------------------------

  Stream<QueueSnapshot> watch() {
    final trigger = _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.queueItems, _db.queuePointer, _db.songs]),
    );
    return Stream<void>.multi((c) {
      c.add(null);
      final sub = trigger.listen((_) => c.add(null), onError: c.addError);
      c.onCancel = sub.cancel;
    }).asyncMap((_) => snapshot());
  }

  Future<QueueSnapshot> snapshot() async {
    final join = _db.select(_db.queueItems).join([
      innerJoin(_db.songs, _db.songs.id.equalsExp(_db.queueItems.songId)),
    ])
      ..orderBy([OrderingTerm.asc(_db.queueItems.sequence), OrderingTerm.asc(_db.queueItems.id)]);
    final rows = await join.get();
    final pointer = await _pointer();
    return QueueSnapshot(
      entries: [
        for (final r in rows) QueueEntry(r.readTable(_db.queueItems), r.readTable(_db.songs)),
      ],
      currentItemId: pointer.currentItemId,
      sourceDescription: pointer.sourceDescription,
    );
  }

  Future<QueuePointerRow> _pointer() =>
      (_db.select(_db.queuePointer)..where((t) => t.id.equals(1))).getSingle();

  Future<List<QueueItem>> _ordered() => (_db.select(_db.queueItems)
        ..orderBy([(t) => OrderingTerm.asc(t.sequence), (t) => OrderingTerm.asc(t.id)]))
      .get();

  // --- verbs (AP §3.4) ---------------------------------------------------

  /// Play a single song: the queue is **cleared** and contains only it.
  Future<QueueSnapshot> playSingle(Song song, {String description = 'Song'}) =>
      replaceWith([song], description: description);

  /// Play a group / list: its songs become the queue, playback starts at
  /// [startIndex] (the head by default).
  Future<QueueSnapshot> replaceWith(
    List<Song> songs, {
    int startIndex = 0,
    String description = '',
    String source = 'manual',
  }) async {
    await _db.transaction(() async {
      await _db.delete(_db.queueItems).go();
      final now = DateTime.now();
      final seqs = QueueSequence.renumber(songs.length);
      int? startId;
      for (var i = 0; i < songs.length; i++) {
        final id = await _db.into(_db.queueItems).insert(QueueItemsCompanion.insert(
              sequence: seqs[i],
              songId: songs[i].id,
              source: Value(source),
              addedAt: now,
            ));
        if (i == startIndex) startId = id;
      }
      await _setPointer(startId, description);
    });
    return snapshot();
  }

  /// Play a new song while something plays: inserted at the **front**
  /// (immediately before the current item) and becomes current. The item it
  /// displaced plays next.
  Future<QueueSnapshot> playNow(Song song) async {
    await _db.transaction(() async {
      var items = await _ordered();
      if (items.isEmpty) {
        await _insertSongs([song], before: null, after: null);
        final only = (await _ordered()).single;
        await _setPointer(only.id, 'Song');
        return;
      }
      final pointer = await _pointer();
      final curIdx = items.indexWhere((i) => i.id == pointer.currentItemId);
      final cur = curIdx < 0 ? 0 : curIdx;
      items = await _ensureRoom(items, 1);
      final before = cur > 0 ? items[cur - 1].sequence : null;
      final after = items[cur].sequence;
      final ids = await _insertSongs([song], before: before, after: after);
      await _setPointer(ids.single, pointer.sourceDescription);
    });
    return snapshot();
  }

  /// Play next: inserted **immediately after** the current item, in order.
  Future<QueueSnapshot> playNext(List<Song> songs) async {
    if (songs.isEmpty) return snapshot();
    await _db.transaction(() async {
      var items = await _ordered();
      final pointer = await _pointer();
      final curIdx = items.indexWhere((i) => i.id == pointer.currentItemId);
      if (items.isEmpty || curIdx < 0) {
        await _appendSongs(songs, items);
        return;
      }
      items = await _ensureRoom(items, songs.length);
      final before = items[curIdx].sequence;
      final after = curIdx + 1 < items.length ? items[curIdx + 1].sequence : null;
      await _insertSongs(songs, before: before, after: after);
    });
    return snapshot();
  }

  /// Add to queue: appended to the **tail**.
  Future<QueueSnapshot> addToQueue(List<Song> songs) async {
    if (songs.isEmpty) return snapshot();
    await _db.transaction(() async {
      await _appendSongs(songs, await _ordered());
    });
    return snapshot();
  }

  Future<void> _appendSongs(List<Song> songs, List<QueueItem> items) async {
    final last = items.isEmpty ? null : items.last.sequence;
    await _insertSongs(songs, before: last, after: null);
  }

  /// Drag-reorder: moves [itemId] so it ends up at [toIndex] of the final list.
  Future<QueueSnapshot> move(int itemId, int toIndex) async {
    await _db.transaction(() async {
      var items = await _ordered();
      final from = items.indexWhere((i) => i.id == itemId);
      if (from < 0) return;
      final rest = [...items]..removeAt(from);
      final idx = toIndex.clamp(0, rest.length);
      if (QueueSequence.needsCompaction(rest.map((i) => i.sequence).toList())) {
        items = await _compact(items);
      }
      final restNow = [...items]..removeAt(from);
      final before = idx > 0 ? restNow[idx - 1].sequence : null;
      final after = idx < restNow.length ? restNow[idx].sequence : null;
      final seq = QueueSequence.between(before, after, 1).single;
      await (_db.update(_db.queueItems)..where((t) => t.id.equals(itemId)))
          .write(QueueItemsCompanion(sequence: Value(seq)));
    });
    return snapshot();
  }

  /// Swipe-to-remove. If the current item is removed the pointer moves to the
  /// next item (or previous, if it was last) and the new current id is
  /// reported through the returned snapshot.
  Future<QueueSnapshot> remove(int itemId) async {
    await _db.transaction(() async {
      final items = await _ordered();
      final idx = items.indexWhere((i) => i.id == itemId);
      if (idx < 0) return;
      final pointer = await _pointer();
      await (_db.delete(_db.queueItems)..where((t) => t.id.equals(itemId))).go();
      if (pointer.currentItemId == itemId) {
        final remaining = [...items]..removeAt(idx);
        final next = remaining.isEmpty
            ? null
            : remaining[idx < remaining.length ? idx : remaining.length - 1].id;
        await _setPointer(next, pointer.sourceDescription);
      }
    });
    return snapshot();
  }

  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.queueItems).go();
      await _setPointer(null, '');
    });
  }

  Future<void> setPointer(int? itemId, {String? description}) async {
    final p = await _pointer();
    await _setPointer(itemId, description ?? p.sourceDescription);
  }

  /// Randomises the order of everything after the current item (shuffle).
  Future<QueueSnapshot> shuffleUpcoming(Random random) async {
    await _db.transaction(() async {
      final items = await _ordered();
      final pointer = await _pointer();
      final curIdx = items.indexWhere((i) => i.id == pointer.currentItemId);
      final upcoming = items.sublist(curIdx + 1)..shuffle(random);
      final base = curIdx >= 0 ? items[curIdx].sequence : 0.0;
      for (var i = 0; i < upcoming.length; i++) {
        await (_db.update(_db.queueItems)..where((t) => t.id.equals(upcoming[i].id)))
            .write(QueueItemsCompanion(sequence: Value(base + (i + 1) * QueueSequence.step)));
      }
    });
    return snapshot();
  }

  // --- suggestions (AP §3.4, §5.7) ---------------------------------------

  /// Appends engine suggestions to the tail, tagged `suggested`.
  Future<QueueSnapshot> appendSuggested(List<Song> songs) async {
    if (songs.isEmpty) return snapshot();
    await _db.transaction(() async {
      final items = await _ordered();
      final last = items.isEmpty ? null : items.last.sequence;
      await _insertSongs(songs, before: last, after: null, source: 'suggested');
    });
    return snapshot();
  }

  /// Drops suggested items after the pointer ("recomputed when the user
  /// changes the queue meaningfully").
  Future<void> dropUpcomingSuggested() async {
    final snap = await snapshot();
    final ids = snap.upcoming.where((e) => e.isSuggested).map((e) => e.id).toList();
    if (ids.isEmpty) return;
    await (_db.delete(_db.queueItems)..where((t) => t.id.isIn(ids))).go();
  }

  /// "Keep": a suggested item becomes a manual one.
  Future<void> keepSuggested(int itemId) =>
      (_db.update(_db.queueItems)..where((t) => t.id.equals(itemId)))
          .write(const QueueItemsCompanion(source: Value('manual')));

  /// Songs currently queued (hard-reject set for suggestions).
  Future<Set<String>> queuedSongIds() async =>
      (await _ordered()).map((i) => i.songId).toSet();

  // --- internals ---------------------------------------------------------

  Future<List<int>> _insertSongs(
    List<Song> songs, {
    required double? before,
    required double? after,
    String source = 'manual',
  }) async {
    final seqs = QueueSequence.between(before, after, songs.length);
    final now = DateTime.now();
    final ids = <int>[];
    for (var i = 0; i < songs.length; i++) {
      ids.add(await _db.into(_db.queueItems).insert(QueueItemsCompanion.insert(
            sequence: seqs[i],
            songId: songs[i].id,
            source: Value(source),
            addedAt: now,
          )));
    }
    return ids;
  }

  /// Compacts first if inserting [count] more items would fall below the gap floor.
  Future<List<QueueItem>> _ensureRoom(List<QueueItem> items, int count) async {
    if (QueueSequence.needsCompaction(items.map((i) => i.sequence).toList(), pending: count)) {
      return _compact(items);
    }
    return items;
  }

  Future<List<QueueItem>> _compact(List<QueueItem> items) async {
    final seqs = QueueSequence.renumber(items.length);
    for (var i = 0; i < items.length; i++) {
      await (_db.update(_db.queueItems)..where((t) => t.id.equals(items[i].id)))
          .write(QueueItemsCompanion(sequence: Value(seqs[i])));
    }
    return _ordered();
  }

  /// Periodic compaction entry point (TP §5.3).
  Future<void> compactIfNeeded() async {
    final items = await _ordered();
    if (QueueSequence.needsCompaction(items.map((i) => i.sequence).toList())) {
      await _db.transaction(() => _compact(items));
    }
  }

  Future<void> _setPointer(int? itemId, String description) =>
      (_db.update(_db.queuePointer)..where((t) => t.id.equals(1))).write(
        QueuePointerCompanion(
          currentItemId: Value(itemId),
          sourceDescription: Value(description),
        ),
      );
}
