import 'package:drift/drift.dart';

// Drift schema (TP §4.1). The generated row classes double as the domain
// entities re-exported from `core/entities/entities.dart`.

@DataClassName('Song')
@TableIndex(name: 'idx_songs_artist', columns: {#artist})
@TableIndex(name: 'idx_songs_album', columns: {#album})
@TableIndex(name: 'idx_songs_album_artist', columns: {#albumArtist})
@TableIndex(name: 'idx_songs_genre', columns: {#genre})
@TableIndex(name: 'idx_songs_year', columns: {#year})
@TableIndex(name: 'idx_songs_date_added', columns: {#dateAdded})
@TableIndex(name: 'idx_songs_folder', columns: {#folderPath})
@TableIndex(name: 'idx_songs_media_store_id', columns: {#mediaStoreId})
class Songs extends Table {
  /// Stable hash of media_store_id + file_path (see `songIdFor`).
  TextColumn get id => text()();
  IntColumn get mediaStoreId => integer()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown artist'))();
  TextColumn get album => text().withDefault(const Constant('Unknown album'))();
  TextColumn get albumArtist => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get filePath => text()();
  TextColumn get contentUri => text()();
  TextColumn get folderPath => text()();

  /// Epoch seconds, as reported by MediaStore.
  IntColumn get dateAdded => integer().withDefault(const Constant(0))();

  /// Epoch seconds; drives the incremental-scan watermark.
  IntColumn get dateModified => integer().withDefault(const Constant(0))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  IntColumn get bitrate => integer().nullable()();
  IntColumn get sampleRate => integer().nullable()();
  TextColumn get format => text().withDefault(const Constant(''))();
  TextColumn get embeddedLrcPath => text().nullable()();
  IntColumn get lastSeenScanAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExcludedFolder')
class ExcludedFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get folderPath => text().unique()();
}

@DataClassName('SongGroup')
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// 'static' | 'smart'
  TextColumn get type => text()();
  TextColumn get coverUri => text().nullable()();
  TextColumn get defaultSort => text().withDefault(const Constant('title'))();
  BoolColumn get defaultSortAscending =>
      boolean().withDefault(const Constant(true))();

  /// 'ordered' | 'shuffle'
  TextColumn get defaultPlayMode =>
      text().withDefault(const Constant('ordered'))();

  /// 'all' | 'any' (smart only)
  TextColumn get matchMode => text().withDefault(const Constant('all'))();

  /// Non-null for built-in smart groups: 'favourites', 'recently_added',
  /// 'recently_played', 'most_played'.
  TextColumn get builtinKey => text().nullable().unique()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('GroupCondition')
class GroupConditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get field => text()();
  TextColumn get operator => text()();
  TextColumn get valueJson => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

@DataClassName('GroupStaticItem')
class GroupStaticItems extends Table {
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {groupId, songId};
}

@DataClassName('GroupRef')
class GroupRefs extends Table {
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('referencedByGroupRefs')
  IntColumn get refGroupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();

  /// 'include' | 'exclude'
  TextColumn get kind => text()();

  @override
  Set<Column> get primaryKey => {groupId, refGroupId};
}

@DataClassName('GroupOverride')
class GroupOverrides extends Table {
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();

  /// 'pin' | 'exclude'
  TextColumn get kind => text()();

  @override
  Set<Column> get primaryKey => {groupId, songId};
}

@DataClassName('QueueItem')
@TableIndex(name: 'idx_queue_sequence', columns: {#sequence})
class QueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Sparse REAL ordering key — see TP §5.3 (insert-in-the-gap).
  RealColumn get sequence => real()();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();

  /// 'manual' | 'suggested'
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get addedAt => dateTime()();
}

/// Singleton (id = 1): "now playing" pointer into [QueueItems].
@DataClassName('QueuePointerRow')
class QueuePointer extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get currentItemId => integer().nullable()();
  TextColumn get sourceDescription =>
      text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Singleton (id = 1).
@DataClassName('PlaybackStateRow')
class PlaybackStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get isPlaying => boolean().withDefault(const Constant(false))();
  RealColumn get speed => real().withDefault(const Constant(1.0))();
  BoolColumn get preservePitch =>
      boolean().withDefault(const Constant(false))();

  /// 0 = off, 1 = repeat queue, 2 = repeat one.
  IntColumn get repeatMode => integer().withDefault(const Constant(0))();
  BoolColumn get shuffleEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get outputRoute => text().withDefault(const Constant('speaker'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlayStat')
class PlayStats extends Table {
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get skipCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  BoolColumn get favourite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {songId};
}

@DataClassName('LyricsRecord')
class LyricsCache extends Table {
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  TextColumn get providerId => text()();
  TextColumn get syncedLrc => text().nullable()();
  TextColumn get plainText => text().nullable()();

  /// 'embedded' | 'remote'
  TextColumn get source => text()();
  IntColumn get offsetMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {songId};
}

@DataClassName('SongAudioFeatures')
class SongAudioFeaturesTable extends Table {
  @override
  String get tableName => 'song_audio_features';

  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  RealColumn get tempoBpm => real()();
  IntColumn get keyIndex => integer()();

  /// 0 = minor, 1 = major.
  IntColumn get keyMode => integer()();
  RealColumn get energy => real()();
  RealColumn get acousticness => real()();
  RealColumn get brightness => real()();
  RealColumn get danceability => real()();

  /// Packed Float32List bytes.
  BlobColumn get embeddingBlob => blob()();
  TextColumn get modelVersion => text()();
  DateTimeColumn get analyzedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {songId};
}

@DataClassName('RemoteCatalogueEntry')
class RemoteCatalogueCache extends Table {
  /// 'download_catalogue' | 'lyrics_providers'
  TextColumn get key => text()();
  TextColumn get jsonBlob => text()();
  TextColumn get etag => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('DownloadRecord')
class DownloadHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get siteId => text()();
  TextColumn get title => text()();
  TextColumn get sourceUrl => text()();
  TextColumn get localPath => text().nullable()();

  /// 'queued' | 'running' | 'paused' | 'done' | 'failed'
  TextColumn get status => text()();
  IntColumn get bytesTotal => integer().withDefault(const Constant(0))();
  IntColumn get bytesDone => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get error => text().nullable()();

  /// 'file' (direct link / browse mode) | 'album' (listing mode: the zip URL
  /// is re-fetched from [pageUrl] right before each attempt, since it expires).
  TextColumn get kind => text().withDefault(const Constant('file'))();

  /// Album page (listing mode) or the page a browse-mode download came from.
  TextColumn get pageUrl => text().nullable()();

  /// Request headers needed to repeat the download (cookies, referer, UA).
  TextColumn get headersJson => text().nullable()();

  /// Songs added to the library by this download (AP §5.8 "Added 12 songs").
  IntColumn get itemsAdded => integer().withDefault(const Constant(0))();
}
