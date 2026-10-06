import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Keys of the four built-in smart groups (AP §3.3, §11.18).
class BuiltinGroupKeys {
  static const favourites = 'favourites';
  static const recentlyAdded = 'recently_added';
  static const recentlyPlayed = 'recently_played';
  static const mostPlayed = 'most_played';

  static const all = [favourites, recentlyAdded, recentlyPlayed, mostPlayed];

  static const names = {
    favourites: 'Favourites',
    recentlyAdded: 'Recently added',
    recentlyPlayed: 'Recently played',
    mostPlayed: 'Most played',
  };
}

@DriftDatabase(
  tables: [
    Songs,
    ExcludedFolders,
    Groups,
    GroupConditions,
    GroupStaticItems,
    GroupRefs,
    GroupOverrides,
    QueueItems,
    QueuePointer,
    PlaybackStates,
    PlayStats,
    LyricsCache,
    SongAudioFeaturesTable,
    RemoteCatalogueCache,
    DownloadHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for unit tests (TP §8).
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// On-disk database in the app's documents directory. WAL journal mode keeps
  /// every queue mutation durable across abrupt process kills (TP §5.3).
  factory AppDatabase.onDisk() {
    return AppDatabase(
      LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 'paattufy.sqlite'));
        return NativeDatabase.createInBackground(
          file,
          setup: (db) {
            db.execute('PRAGMA journal_mode = WAL;');
            db.execute('PRAGMA synchronous = NORMAL;');
          },
        );
      }),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seed();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  Future<void> _seed() async {
    final now = DateTime.now();
    await into(playbackStates).insert(
      PlaybackStatesCompanion.insert(updatedAt: now),
      mode: InsertMode.insertOrIgnore,
    );
    await into(queuePointer).insert(
      QueuePointerCompanion.insert(),
      mode: InsertMode.insertOrIgnore,
    );
    // Built-ins are plain smart groups with seeded rule rows (AP §3.3, §11.18),
    // so they go through exactly the same compiler as user groups.
    const rules = {
      BuiltinGroupKeys.favourites: ('favourite', 'isTrue', 'true', 'title', true),
      BuiltinGroupKeys.recentlyAdded: ('dateAdded', 'inLastDays', '30', 'dateAdded', false),
      BuiltinGroupKeys.recentlyPlayed: ('lastPlayed', 'inLastDays', '30', 'lastPlayed', false),
      BuiltinGroupKeys.mostPlayed: ('playCount', 'atLeast', '1', 'playCount', false),
    };
    for (final key in BuiltinGroupKeys.all) {
      final (field, op, valueJson, sort, asc) = rules[key]!;
      final id = await into(groups).insert(
        GroupsCompanion.insert(
          name: BuiltinGroupKeys.names[key]!,
          type: 'smart',
          isBuiltin: const Value(true),
          builtinKey: Value(key),
          defaultSort: Value(sort),
          defaultSortAscending: Value(asc),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await into(groupConditions).insert(
        GroupConditionsCompanion.insert(
          groupId: id,
          field: field,
          operator: op,
          valueJson: valueJson,
        ),
      );
    }
  }
}
