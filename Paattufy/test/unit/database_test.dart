import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting());
  tearDown(() => db.close());

  test('seeds singleton rows and the four built-in groups', () async {
    final playback = await db.select(db.playbackStates).get();
    expect(playback, hasLength(1));
    expect(playback.single.speed, 1.0);
    expect(playback.single.preservePitch, isFalse);

    final pointer = await db.select(db.queuePointer).get();
    expect(pointer, hasLength(1));
    expect(pointer.single.currentItemId, isNull);

    final builtins = await (db.select(db.groups)
          ..where((g) => g.isBuiltin.equals(true)))
        .get();
    expect(builtins.map((g) => g.builtinKey).toSet(), {
      'favourites',
      'recently_added',
      'recently_played',
      'most_played',
    });
    expect(builtins.every((g) => g.type == 'smart'), isTrue);
  });

  test('foreign keys cascade: deleting a song removes its queue items',
      () async {
    await db.into(db.songs).insert(SongsCompanion.insert(
          id: 's1',
          mediaStoreId: 1,
          title: 'T',
          filePath: '/a/T.mp3',
          contentUri: 'content://x/1',
          folderPath: '/a',
        ));
    await db.into(db.queueItems).insert(QueueItemsCompanion.insert(
          sequence: 1000,
          songId: 's1',
          addedAt: DateTime.now(),
        ));
    expect(await db.select(db.queueItems).get(), hasLength(1));
    await (db.delete(db.songs)..where((s) => s.id.equals('s1'))).go();
    expect(await db.select(db.queueItems).get(), isEmpty);
  });

  test('excluded folder paths are unique', () async {
    await db
        .into(db.excludedFolders)
        .insert(ExcludedFoldersCompanion.insert(folderPath: '/x'));
    expect(
      () => db
          .into(db.excludedFolders)
          .insert(ExcludedFoldersCompanion.insert(folderPath: '/x')),
      throwsA(isA<Exception>()),
    );
  });

  test('Value helper sanity', () {
    expect(const Value(3).value, 3);
  });
}
