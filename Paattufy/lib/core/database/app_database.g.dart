// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaStoreIdMeta = const VerificationMeta(
    'mediaStoreId',
  );
  @override
  late final GeneratedColumn<int> mediaStoreId = GeneratedColumn<int>(
    'media_store_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown artist'),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown album'),
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentUriMeta = const VerificationMeta(
    'contentUri',
  );
  @override
  late final GeneratedColumn<String> contentUri = GeneratedColumn<String>(
    'content_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderPathMeta = const VerificationMeta(
    'folderPath',
  );
  @override
  late final GeneratedColumn<String> folderPath = GeneratedColumn<String>(
    'folder_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<int> dateAdded = GeneratedColumn<int>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateModifiedMeta = const VerificationMeta(
    'dateModified',
  );
  @override
  late final GeneratedColumn<int> dateModified = GeneratedColumn<int>(
    'date_modified',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bitrateMeta = const VerificationMeta(
    'bitrate',
  );
  @override
  late final GeneratedColumn<int> bitrate = GeneratedColumn<int>(
    'bitrate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleRateMeta = const VerificationMeta(
    'sampleRate',
  );
  @override
  late final GeneratedColumn<int> sampleRate = GeneratedColumn<int>(
    'sample_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _embeddedLrcPathMeta = const VerificationMeta(
    'embeddedLrcPath',
  );
  @override
  late final GeneratedColumn<String> embeddedLrcPath = GeneratedColumn<String>(
    'embedded_lrc_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenScanAtMeta = const VerificationMeta(
    'lastSeenScanAt',
  );
  @override
  late final GeneratedColumn<int> lastSeenScanAt = GeneratedColumn<int>(
    'last_seen_scan_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaStoreId,
    title,
    artist,
    album,
    albumArtist,
    genre,
    year,
    trackNumber,
    durationMs,
    filePath,
    contentUri,
    folderPath,
    dateAdded,
    dateModified,
    sizeBytes,
    bitrate,
    sampleRate,
    format,
    embeddedLrcPath,
    lastSeenScanAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Song> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_store_id')) {
      context.handle(
        _mediaStoreIdMeta,
        mediaStoreId.isAcceptableOrUnknown(
          data['media_store_id']!,
          _mediaStoreIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaStoreIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('content_uri')) {
      context.handle(
        _contentUriMeta,
        contentUri.isAcceptableOrUnknown(data['content_uri']!, _contentUriMeta),
      );
    } else if (isInserting) {
      context.missing(_contentUriMeta);
    }
    if (data.containsKey('folder_path')) {
      context.handle(
        _folderPathMeta,
        folderPath.isAcceptableOrUnknown(data['folder_path']!, _folderPathMeta),
      );
    } else if (isInserting) {
      context.missing(_folderPathMeta);
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    if (data.containsKey('date_modified')) {
      context.handle(
        _dateModifiedMeta,
        dateModified.isAcceptableOrUnknown(
          data['date_modified']!,
          _dateModifiedMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('bitrate')) {
      context.handle(
        _bitrateMeta,
        bitrate.isAcceptableOrUnknown(data['bitrate']!, _bitrateMeta),
      );
    }
    if (data.containsKey('sample_rate')) {
      context.handle(
        _sampleRateMeta,
        sampleRate.isAcceptableOrUnknown(data['sample_rate']!, _sampleRateMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('embedded_lrc_path')) {
      context.handle(
        _embeddedLrcPathMeta,
        embeddedLrcPath.isAcceptableOrUnknown(
          data['embedded_lrc_path']!,
          _embeddedLrcPathMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_scan_at')) {
      context.handle(
        _lastSeenScanAtMeta,
        lastSeenScanAt.isAcceptableOrUnknown(
          data['last_seen_scan_at']!,
          _lastSeenScanAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaStoreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_store_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      contentUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_uri'],
      )!,
      folderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_path'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_added'],
      )!,
      dateModified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_modified'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      bitrate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bitrate'],
      ),
      sampleRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_rate'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      embeddedLrcPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedded_lrc_path'],
      ),
      lastSeenScanAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_scan_at'],
      )!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  /// Stable hash of media_store_id + file_path (see `songIdFor`).
  final String id;
  final int mediaStoreId;
  final String title;
  final String artist;
  final String album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int durationMs;
  final String filePath;
  final String contentUri;
  final String folderPath;

  /// Epoch seconds, as reported by MediaStore.
  final int dateAdded;

  /// Epoch seconds; drives the incremental-scan watermark.
  final int dateModified;
  final int sizeBytes;
  final int? bitrate;
  final int? sampleRate;
  final String format;
  final String? embeddedLrcPath;
  final int lastSeenScanAt;
  const Song({
    required this.id,
    required this.mediaStoreId,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    required this.durationMs,
    required this.filePath,
    required this.contentUri,
    required this.folderPath,
    required this.dateAdded,
    required this.dateModified,
    required this.sizeBytes,
    this.bitrate,
    this.sampleRate,
    required this.format,
    this.embeddedLrcPath,
    required this.lastSeenScanAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_store_id'] = Variable<int>(mediaStoreId);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || albumArtist != null) {
      map['album_artist'] = Variable<String>(albumArtist);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_path'] = Variable<String>(filePath);
    map['content_uri'] = Variable<String>(contentUri);
    map['folder_path'] = Variable<String>(folderPath);
    map['date_added'] = Variable<int>(dateAdded);
    map['date_modified'] = Variable<int>(dateModified);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || bitrate != null) {
      map['bitrate'] = Variable<int>(bitrate);
    }
    if (!nullToAbsent || sampleRate != null) {
      map['sample_rate'] = Variable<int>(sampleRate);
    }
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || embeddedLrcPath != null) {
      map['embedded_lrc_path'] = Variable<String>(embeddedLrcPath);
    }
    map['last_seen_scan_at'] = Variable<int>(lastSeenScanAt);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      mediaStoreId: Value(mediaStoreId),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      albumArtist: albumArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtist),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      durationMs: Value(durationMs),
      filePath: Value(filePath),
      contentUri: Value(contentUri),
      folderPath: Value(folderPath),
      dateAdded: Value(dateAdded),
      dateModified: Value(dateModified),
      sizeBytes: Value(sizeBytes),
      bitrate: bitrate == null && nullToAbsent
          ? const Value.absent()
          : Value(bitrate),
      sampleRate: sampleRate == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleRate),
      format: Value(format),
      embeddedLrcPath: embeddedLrcPath == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddedLrcPath),
      lastSeenScanAt: Value(lastSeenScanAt),
    );
  }

  factory Song.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<String>(json['id']),
      mediaStoreId: serializer.fromJson<int>(json['mediaStoreId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      albumArtist: serializer.fromJson<String?>(json['albumArtist']),
      genre: serializer.fromJson<String?>(json['genre']),
      year: serializer.fromJson<int?>(json['year']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      filePath: serializer.fromJson<String>(json['filePath']),
      contentUri: serializer.fromJson<String>(json['contentUri']),
      folderPath: serializer.fromJson<String>(json['folderPath']),
      dateAdded: serializer.fromJson<int>(json['dateAdded']),
      dateModified: serializer.fromJson<int>(json['dateModified']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      bitrate: serializer.fromJson<int?>(json['bitrate']),
      sampleRate: serializer.fromJson<int?>(json['sampleRate']),
      format: serializer.fromJson<String>(json['format']),
      embeddedLrcPath: serializer.fromJson<String?>(json['embeddedLrcPath']),
      lastSeenScanAt: serializer.fromJson<int>(json['lastSeenScanAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaStoreId': serializer.toJson<int>(mediaStoreId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'albumArtist': serializer.toJson<String?>(albumArtist),
      'genre': serializer.toJson<String?>(genre),
      'year': serializer.toJson<int?>(year),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'durationMs': serializer.toJson<int>(durationMs),
      'filePath': serializer.toJson<String>(filePath),
      'contentUri': serializer.toJson<String>(contentUri),
      'folderPath': serializer.toJson<String>(folderPath),
      'dateAdded': serializer.toJson<int>(dateAdded),
      'dateModified': serializer.toJson<int>(dateModified),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'bitrate': serializer.toJson<int?>(bitrate),
      'sampleRate': serializer.toJson<int?>(sampleRate),
      'format': serializer.toJson<String>(format),
      'embeddedLrcPath': serializer.toJson<String?>(embeddedLrcPath),
      'lastSeenScanAt': serializer.toJson<int>(lastSeenScanAt),
    };
  }

  Song copyWith({
    String? id,
    int? mediaStoreId,
    String? title,
    String? artist,
    String? album,
    Value<String?> albumArtist = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    int? durationMs,
    String? filePath,
    String? contentUri,
    String? folderPath,
    int? dateAdded,
    int? dateModified,
    int? sizeBytes,
    Value<int?> bitrate = const Value.absent(),
    Value<int?> sampleRate = const Value.absent(),
    String? format,
    Value<String?> embeddedLrcPath = const Value.absent(),
    int? lastSeenScanAt,
  }) => Song(
    id: id ?? this.id,
    mediaStoreId: mediaStoreId ?? this.mediaStoreId,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    albumArtist: albumArtist.present ? albumArtist.value : this.albumArtist,
    genre: genre.present ? genre.value : this.genre,
    year: year.present ? year.value : this.year,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    durationMs: durationMs ?? this.durationMs,
    filePath: filePath ?? this.filePath,
    contentUri: contentUri ?? this.contentUri,
    folderPath: folderPath ?? this.folderPath,
    dateAdded: dateAdded ?? this.dateAdded,
    dateModified: dateModified ?? this.dateModified,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    bitrate: bitrate.present ? bitrate.value : this.bitrate,
    sampleRate: sampleRate.present ? sampleRate.value : this.sampleRate,
    format: format ?? this.format,
    embeddedLrcPath: embeddedLrcPath.present
        ? embeddedLrcPath.value
        : this.embeddedLrcPath,
    lastSeenScanAt: lastSeenScanAt ?? this.lastSeenScanAt,
  );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      mediaStoreId: data.mediaStoreId.present
          ? data.mediaStoreId.value
          : this.mediaStoreId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      contentUri: data.contentUri.present
          ? data.contentUri.value
          : this.contentUri,
      folderPath: data.folderPath.present
          ? data.folderPath.value
          : this.folderPath,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateModified: data.dateModified.present
          ? data.dateModified.value
          : this.dateModified,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      bitrate: data.bitrate.present ? data.bitrate.value : this.bitrate,
      sampleRate: data.sampleRate.present
          ? data.sampleRate.value
          : this.sampleRate,
      format: data.format.present ? data.format.value : this.format,
      embeddedLrcPath: data.embeddedLrcPath.present
          ? data.embeddedLrcPath.value
          : this.embeddedLrcPath,
      lastSeenScanAt: data.lastSeenScanAt.present
          ? data.lastSeenScanAt.value
          : this.lastSeenScanAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('mediaStoreId: $mediaStoreId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('filePath: $filePath, ')
          ..write('contentUri: $contentUri, ')
          ..write('folderPath: $folderPath, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('bitrate: $bitrate, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('format: $format, ')
          ..write('embeddedLrcPath: $embeddedLrcPath, ')
          ..write('lastSeenScanAt: $lastSeenScanAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    mediaStoreId,
    title,
    artist,
    album,
    albumArtist,
    genre,
    year,
    trackNumber,
    durationMs,
    filePath,
    contentUri,
    folderPath,
    dateAdded,
    dateModified,
    sizeBytes,
    bitrate,
    sampleRate,
    format,
    embeddedLrcPath,
    lastSeenScanAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.mediaStoreId == this.mediaStoreId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.genre == this.genre &&
          other.year == this.year &&
          other.trackNumber == this.trackNumber &&
          other.durationMs == this.durationMs &&
          other.filePath == this.filePath &&
          other.contentUri == this.contentUri &&
          other.folderPath == this.folderPath &&
          other.dateAdded == this.dateAdded &&
          other.dateModified == this.dateModified &&
          other.sizeBytes == this.sizeBytes &&
          other.bitrate == this.bitrate &&
          other.sampleRate == this.sampleRate &&
          other.format == this.format &&
          other.embeddedLrcPath == this.embeddedLrcPath &&
          other.lastSeenScanAt == this.lastSeenScanAt);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<String> id;
  final Value<int> mediaStoreId;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<String?> albumArtist;
  final Value<String?> genre;
  final Value<int?> year;
  final Value<int?> trackNumber;
  final Value<int> durationMs;
  final Value<String> filePath;
  final Value<String> contentUri;
  final Value<String> folderPath;
  final Value<int> dateAdded;
  final Value<int> dateModified;
  final Value<int> sizeBytes;
  final Value<int?> bitrate;
  final Value<int?> sampleRate;
  final Value<String> format;
  final Value<String?> embeddedLrcPath;
  final Value<int> lastSeenScanAt;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.mediaStoreId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.filePath = const Value.absent(),
    this.contentUri = const Value.absent(),
    this.folderPath = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.bitrate = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.format = const Value.absent(),
    this.embeddedLrcPath = const Value.absent(),
    this.lastSeenScanAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required int mediaStoreId,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String filePath,
    required String contentUri,
    required String folderPath,
    this.dateAdded = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.bitrate = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.format = const Value.absent(),
    this.embeddedLrcPath = const Value.absent(),
    this.lastSeenScanAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaStoreId = Value(mediaStoreId),
       title = Value(title),
       filePath = Value(filePath),
       contentUri = Value(contentUri),
       folderPath = Value(folderPath);
  static Insertable<Song> custom({
    Expression<String>? id,
    Expression<int>? mediaStoreId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<int>? trackNumber,
    Expression<int>? durationMs,
    Expression<String>? filePath,
    Expression<String>? contentUri,
    Expression<String>? folderPath,
    Expression<int>? dateAdded,
    Expression<int>? dateModified,
    Expression<int>? sizeBytes,
    Expression<int>? bitrate,
    Expression<int>? sampleRate,
    Expression<String>? format,
    Expression<String>? embeddedLrcPath,
    Expression<int>? lastSeenScanAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaStoreId != null) 'media_store_id': mediaStoreId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (trackNumber != null) 'track_number': trackNumber,
      if (durationMs != null) 'duration_ms': durationMs,
      if (filePath != null) 'file_path': filePath,
      if (contentUri != null) 'content_uri': contentUri,
      if (folderPath != null) 'folder_path': folderPath,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateModified != null) 'date_modified': dateModified,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (bitrate != null) 'bitrate': bitrate,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (format != null) 'format': format,
      if (embeddedLrcPath != null) 'embedded_lrc_path': embeddedLrcPath,
      if (lastSeenScanAt != null) 'last_seen_scan_at': lastSeenScanAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<int>? mediaStoreId,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<String?>? albumArtist,
    Value<String?>? genre,
    Value<int?>? year,
    Value<int?>? trackNumber,
    Value<int>? durationMs,
    Value<String>? filePath,
    Value<String>? contentUri,
    Value<String>? folderPath,
    Value<int>? dateAdded,
    Value<int>? dateModified,
    Value<int>? sizeBytes,
    Value<int?>? bitrate,
    Value<int?>? sampleRate,
    Value<String>? format,
    Value<String?>? embeddedLrcPath,
    Value<int>? lastSeenScanAt,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      mediaStoreId: mediaStoreId ?? this.mediaStoreId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      durationMs: durationMs ?? this.durationMs,
      filePath: filePath ?? this.filePath,
      contentUri: contentUri ?? this.contentUri,
      folderPath: folderPath ?? this.folderPath,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      format: format ?? this.format,
      embeddedLrcPath: embeddedLrcPath ?? this.embeddedLrcPath,
      lastSeenScanAt: lastSeenScanAt ?? this.lastSeenScanAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaStoreId.present) {
      map['media_store_id'] = Variable<int>(mediaStoreId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (contentUri.present) {
      map['content_uri'] = Variable<String>(contentUri.value);
    }
    if (folderPath.present) {
      map['folder_path'] = Variable<String>(folderPath.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<int>(dateAdded.value);
    }
    if (dateModified.present) {
      map['date_modified'] = Variable<int>(dateModified.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (bitrate.present) {
      map['bitrate'] = Variable<int>(bitrate.value);
    }
    if (sampleRate.present) {
      map['sample_rate'] = Variable<int>(sampleRate.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (embeddedLrcPath.present) {
      map['embedded_lrc_path'] = Variable<String>(embeddedLrcPath.value);
    }
    if (lastSeenScanAt.present) {
      map['last_seen_scan_at'] = Variable<int>(lastSeenScanAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('mediaStoreId: $mediaStoreId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('filePath: $filePath, ')
          ..write('contentUri: $contentUri, ')
          ..write('folderPath: $folderPath, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateModified: $dateModified, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('bitrate: $bitrate, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('format: $format, ')
          ..write('embeddedLrcPath: $embeddedLrcPath, ')
          ..write('lastSeenScanAt: $lastSeenScanAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExcludedFoldersTable extends ExcludedFolders
    with TableInfo<$ExcludedFoldersTable, ExcludedFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExcludedFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _folderPathMeta = const VerificationMeta(
    'folderPath',
  );
  @override
  late final GeneratedColumn<String> folderPath = GeneratedColumn<String>(
    'folder_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, folderPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'excluded_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExcludedFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_path')) {
      context.handle(
        _folderPathMeta,
        folderPath.isAcceptableOrUnknown(data['folder_path']!, _folderPathMeta),
      );
    } else if (isInserting) {
      context.missing(_folderPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExcludedFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExcludedFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_path'],
      )!,
    );
  }

  @override
  $ExcludedFoldersTable createAlias(String alias) {
    return $ExcludedFoldersTable(attachedDatabase, alias);
  }
}

class ExcludedFolder extends DataClass implements Insertable<ExcludedFolder> {
  final int id;
  final String folderPath;
  const ExcludedFolder({required this.id, required this.folderPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_path'] = Variable<String>(folderPath);
    return map;
  }

  ExcludedFoldersCompanion toCompanion(bool nullToAbsent) {
    return ExcludedFoldersCompanion(
      id: Value(id),
      folderPath: Value(folderPath),
    );
  }

  factory ExcludedFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExcludedFolder(
      id: serializer.fromJson<int>(json['id']),
      folderPath: serializer.fromJson<String>(json['folderPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderPath': serializer.toJson<String>(folderPath),
    };
  }

  ExcludedFolder copyWith({int? id, String? folderPath}) => ExcludedFolder(
    id: id ?? this.id,
    folderPath: folderPath ?? this.folderPath,
  );
  ExcludedFolder copyWithCompanion(ExcludedFoldersCompanion data) {
    return ExcludedFolder(
      id: data.id.present ? data.id.value : this.id,
      folderPath: data.folderPath.present
          ? data.folderPath.value
          : this.folderPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExcludedFolder(')
          ..write('id: $id, ')
          ..write('folderPath: $folderPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, folderPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExcludedFolder &&
          other.id == this.id &&
          other.folderPath == this.folderPath);
}

class ExcludedFoldersCompanion extends UpdateCompanion<ExcludedFolder> {
  final Value<int> id;
  final Value<String> folderPath;
  const ExcludedFoldersCompanion({
    this.id = const Value.absent(),
    this.folderPath = const Value.absent(),
  });
  ExcludedFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String folderPath,
  }) : folderPath = Value(folderPath);
  static Insertable<ExcludedFolder> custom({
    Expression<int>? id,
    Expression<String>? folderPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderPath != null) 'folder_path': folderPath,
    });
  }

  ExcludedFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? folderPath,
  }) {
    return ExcludedFoldersCompanion(
      id: id ?? this.id,
      folderPath: folderPath ?? this.folderPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderPath.present) {
      map['folder_path'] = Variable<String>(folderPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExcludedFoldersCompanion(')
          ..write('id: $id, ')
          ..write('folderPath: $folderPath')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, SongGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUriMeta = const VerificationMeta(
    'coverUri',
  );
  @override
  late final GeneratedColumn<String> coverUri = GeneratedColumn<String>(
    'cover_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultSortMeta = const VerificationMeta(
    'defaultSort',
  );
  @override
  late final GeneratedColumn<String> defaultSort = GeneratedColumn<String>(
    'default_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('title'),
  );
  static const VerificationMeta _defaultSortAscendingMeta =
      const VerificationMeta('defaultSortAscending');
  @override
  late final GeneratedColumn<bool> defaultSortAscending = GeneratedColumn<bool>(
    'default_sort_ascending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("default_sort_ascending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _defaultPlayModeMeta = const VerificationMeta(
    'defaultPlayMode',
  );
  @override
  late final GeneratedColumn<String> defaultPlayMode = GeneratedColumn<String>(
    'default_play_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ordered'),
  );
  static const VerificationMeta _matchModeMeta = const VerificationMeta(
    'matchMode',
  );
  @override
  late final GeneratedColumn<String> matchMode = GeneratedColumn<String>(
    'match_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _builtinKeyMeta = const VerificationMeta(
    'builtinKey',
  );
  @override
  late final GeneratedColumn<String> builtinKey = GeneratedColumn<String>(
    'builtin_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    coverUri,
    defaultSort,
    defaultSortAscending,
    defaultPlayMode,
    matchMode,
    builtinKey,
    isBuiltin,
    isHidden,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('cover_uri')) {
      context.handle(
        _coverUriMeta,
        coverUri.isAcceptableOrUnknown(data['cover_uri']!, _coverUriMeta),
      );
    }
    if (data.containsKey('default_sort')) {
      context.handle(
        _defaultSortMeta,
        defaultSort.isAcceptableOrUnknown(
          data['default_sort']!,
          _defaultSortMeta,
        ),
      );
    }
    if (data.containsKey('default_sort_ascending')) {
      context.handle(
        _defaultSortAscendingMeta,
        defaultSortAscending.isAcceptableOrUnknown(
          data['default_sort_ascending']!,
          _defaultSortAscendingMeta,
        ),
      );
    }
    if (data.containsKey('default_play_mode')) {
      context.handle(
        _defaultPlayModeMeta,
        defaultPlayMode.isAcceptableOrUnknown(
          data['default_play_mode']!,
          _defaultPlayModeMeta,
        ),
      );
    }
    if (data.containsKey('match_mode')) {
      context.handle(
        _matchModeMeta,
        matchMode.isAcceptableOrUnknown(data['match_mode']!, _matchModeMeta),
      );
    }
    if (data.containsKey('builtin_key')) {
      context.handle(
        _builtinKeyMeta,
        builtinKey.isAcceptableOrUnknown(data['builtin_key']!, _builtinKeyMeta),
      );
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      coverUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_uri'],
      ),
      defaultSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_sort'],
      )!,
      defaultSortAscending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}default_sort_ascending'],
      )!,
      defaultPlayMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_play_mode'],
      )!,
      matchMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_mode'],
      )!,
      builtinKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}builtin_key'],
      ),
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class SongGroup extends DataClass implements Insertable<SongGroup> {
  final int id;
  final String name;

  /// 'static' | 'smart'
  final String type;
  final String? coverUri;
  final String defaultSort;
  final bool defaultSortAscending;

  /// 'ordered' | 'shuffle'
  final String defaultPlayMode;

  /// 'all' | 'any' (smart only)
  final String matchMode;

  /// Non-null for built-in smart groups: 'favourites', 'recently_added',
  /// 'recently_played', 'most_played'.
  final String? builtinKey;
  final bool isBuiltin;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SongGroup({
    required this.id,
    required this.name,
    required this.type,
    this.coverUri,
    required this.defaultSort,
    required this.defaultSortAscending,
    required this.defaultPlayMode,
    required this.matchMode,
    this.builtinKey,
    required this.isBuiltin,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || coverUri != null) {
      map['cover_uri'] = Variable<String>(coverUri);
    }
    map['default_sort'] = Variable<String>(defaultSort);
    map['default_sort_ascending'] = Variable<bool>(defaultSortAscending);
    map['default_play_mode'] = Variable<String>(defaultPlayMode);
    map['match_mode'] = Variable<String>(matchMode);
    if (!nullToAbsent || builtinKey != null) {
      map['builtin_key'] = Variable<String>(builtinKey);
    }
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      coverUri: coverUri == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUri),
      defaultSort: Value(defaultSort),
      defaultSortAscending: Value(defaultSortAscending),
      defaultPlayMode: Value(defaultPlayMode),
      matchMode: Value(matchMode),
      builtinKey: builtinKey == null && nullToAbsent
          ? const Value.absent()
          : Value(builtinKey),
      isBuiltin: Value(isBuiltin),
      isHidden: Value(isHidden),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SongGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongGroup(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      coverUri: serializer.fromJson<String?>(json['coverUri']),
      defaultSort: serializer.fromJson<String>(json['defaultSort']),
      defaultSortAscending: serializer.fromJson<bool>(
        json['defaultSortAscending'],
      ),
      defaultPlayMode: serializer.fromJson<String>(json['defaultPlayMode']),
      matchMode: serializer.fromJson<String>(json['matchMode']),
      builtinKey: serializer.fromJson<String?>(json['builtinKey']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'coverUri': serializer.toJson<String?>(coverUri),
      'defaultSort': serializer.toJson<String>(defaultSort),
      'defaultSortAscending': serializer.toJson<bool>(defaultSortAscending),
      'defaultPlayMode': serializer.toJson<String>(defaultPlayMode),
      'matchMode': serializer.toJson<String>(matchMode),
      'builtinKey': serializer.toJson<String?>(builtinKey),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'isHidden': serializer.toJson<bool>(isHidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SongGroup copyWith({
    int? id,
    String? name,
    String? type,
    Value<String?> coverUri = const Value.absent(),
    String? defaultSort,
    bool? defaultSortAscending,
    String? defaultPlayMode,
    String? matchMode,
    Value<String?> builtinKey = const Value.absent(),
    bool? isBuiltin,
    bool? isHidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SongGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    coverUri: coverUri.present ? coverUri.value : this.coverUri,
    defaultSort: defaultSort ?? this.defaultSort,
    defaultSortAscending: defaultSortAscending ?? this.defaultSortAscending,
    defaultPlayMode: defaultPlayMode ?? this.defaultPlayMode,
    matchMode: matchMode ?? this.matchMode,
    builtinKey: builtinKey.present ? builtinKey.value : this.builtinKey,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    isHidden: isHidden ?? this.isHidden,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SongGroup copyWithCompanion(GroupsCompanion data) {
    return SongGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      coverUri: data.coverUri.present ? data.coverUri.value : this.coverUri,
      defaultSort: data.defaultSort.present
          ? data.defaultSort.value
          : this.defaultSort,
      defaultSortAscending: data.defaultSortAscending.present
          ? data.defaultSortAscending.value
          : this.defaultSortAscending,
      defaultPlayMode: data.defaultPlayMode.present
          ? data.defaultPlayMode.value
          : this.defaultPlayMode,
      matchMode: data.matchMode.present ? data.matchMode.value : this.matchMode,
      builtinKey: data.builtinKey.present
          ? data.builtinKey.value
          : this.builtinKey,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('coverUri: $coverUri, ')
          ..write('defaultSort: $defaultSort, ')
          ..write('defaultSortAscending: $defaultSortAscending, ')
          ..write('defaultPlayMode: $defaultPlayMode, ')
          ..write('matchMode: $matchMode, ')
          ..write('builtinKey: $builtinKey, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    coverUri,
    defaultSort,
    defaultSortAscending,
    defaultPlayMode,
    matchMode,
    builtinKey,
    isBuiltin,
    isHidden,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.coverUri == this.coverUri &&
          other.defaultSort == this.defaultSort &&
          other.defaultSortAscending == this.defaultSortAscending &&
          other.defaultPlayMode == this.defaultPlayMode &&
          other.matchMode == this.matchMode &&
          other.builtinKey == this.builtinKey &&
          other.isBuiltin == this.isBuiltin &&
          other.isHidden == this.isHidden &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupsCompanion extends UpdateCompanion<SongGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> coverUri;
  final Value<String> defaultSort;
  final Value<bool> defaultSortAscending;
  final Value<String> defaultPlayMode;
  final Value<String> matchMode;
  final Value<String?> builtinKey;
  final Value<bool> isBuiltin;
  final Value<bool> isHidden;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.coverUri = const Value.absent(),
    this.defaultSort = const Value.absent(),
    this.defaultSortAscending = const Value.absent(),
    this.defaultPlayMode = const Value.absent(),
    this.matchMode = const Value.absent(),
    this.builtinKey = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.coverUri = const Value.absent(),
    this.defaultSort = const Value.absent(),
    this.defaultSortAscending = const Value.absent(),
    this.defaultPlayMode = const Value.absent(),
    this.matchMode = const Value.absent(),
    this.builtinKey = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isHidden = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SongGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? coverUri,
    Expression<String>? defaultSort,
    Expression<bool>? defaultSortAscending,
    Expression<String>? defaultPlayMode,
    Expression<String>? matchMode,
    Expression<String>? builtinKey,
    Expression<bool>? isBuiltin,
    Expression<bool>? isHidden,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (coverUri != null) 'cover_uri': coverUri,
      if (defaultSort != null) 'default_sort': defaultSort,
      if (defaultSortAscending != null)
        'default_sort_ascending': defaultSortAscending,
      if (defaultPlayMode != null) 'default_play_mode': defaultPlayMode,
      if (matchMode != null) 'match_mode': matchMode,
      if (builtinKey != null) 'builtin_key': builtinKey,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (isHidden != null) 'is_hidden': isHidden,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? coverUri,
    Value<String>? defaultSort,
    Value<bool>? defaultSortAscending,
    Value<String>? defaultPlayMode,
    Value<String>? matchMode,
    Value<String?>? builtinKey,
    Value<bool>? isBuiltin,
    Value<bool>? isHidden,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      coverUri: coverUri ?? this.coverUri,
      defaultSort: defaultSort ?? this.defaultSort,
      defaultSortAscending: defaultSortAscending ?? this.defaultSortAscending,
      defaultPlayMode: defaultPlayMode ?? this.defaultPlayMode,
      matchMode: matchMode ?? this.matchMode,
      builtinKey: builtinKey ?? this.builtinKey,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (coverUri.present) {
      map['cover_uri'] = Variable<String>(coverUri.value);
    }
    if (defaultSort.present) {
      map['default_sort'] = Variable<String>(defaultSort.value);
    }
    if (defaultSortAscending.present) {
      map['default_sort_ascending'] = Variable<bool>(
        defaultSortAscending.value,
      );
    }
    if (defaultPlayMode.present) {
      map['default_play_mode'] = Variable<String>(defaultPlayMode.value);
    }
    if (matchMode.present) {
      map['match_mode'] = Variable<String>(matchMode.value);
    }
    if (builtinKey.present) {
      map['builtin_key'] = Variable<String>(builtinKey.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('coverUri: $coverUri, ')
          ..write('defaultSort: $defaultSort, ')
          ..write('defaultSortAscending: $defaultSortAscending, ')
          ..write('defaultPlayMode: $defaultPlayMode, ')
          ..write('matchMode: $matchMode, ')
          ..write('builtinKey: $builtinKey, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GroupConditionsTable extends GroupConditions
    with TableInfo<$GroupConditionsTable, GroupCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorMeta = const VerificationMeta(
    'operator',
  );
  @override
  late final GeneratedColumn<String> operator = GeneratedColumn<String>(
    'operator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    field,
    operator,
    valueJson,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_conditions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupCondition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('operator')) {
      context.handle(
        _operatorMeta,
        operator.isAcceptableOrUnknown(data['operator']!, _operatorMeta),
      );
    } else if (isInserting) {
      context.missing(_operatorMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupCondition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupCondition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      operator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $GroupConditionsTable createAlias(String alias) {
    return $GroupConditionsTable(attachedDatabase, alias);
  }
}

class GroupCondition extends DataClass implements Insertable<GroupCondition> {
  final int id;
  final int groupId;
  final String field;
  final String operator;
  final String valueJson;
  final int position;
  const GroupCondition({
    required this.id,
    required this.groupId,
    required this.field,
    required this.operator,
    required this.valueJson,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['field'] = Variable<String>(field);
    map['operator'] = Variable<String>(operator);
    map['value_json'] = Variable<String>(valueJson);
    map['position'] = Variable<int>(position);
    return map;
  }

  GroupConditionsCompanion toCompanion(bool nullToAbsent) {
    return GroupConditionsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      field: Value(field),
      operator: Value(operator),
      valueJson: Value(valueJson),
      position: Value(position),
    );
  }

  factory GroupCondition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupCondition(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      field: serializer.fromJson<String>(json['field']),
      operator: serializer.fromJson<String>(json['operator']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'field': serializer.toJson<String>(field),
      'operator': serializer.toJson<String>(operator),
      'valueJson': serializer.toJson<String>(valueJson),
      'position': serializer.toJson<int>(position),
    };
  }

  GroupCondition copyWith({
    int? id,
    int? groupId,
    String? field,
    String? operator,
    String? valueJson,
    int? position,
  }) => GroupCondition(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    field: field ?? this.field,
    operator: operator ?? this.operator,
    valueJson: valueJson ?? this.valueJson,
    position: position ?? this.position,
  );
  GroupCondition copyWithCompanion(GroupConditionsCompanion data) {
    return GroupCondition(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      field: data.field.present ? data.field.value : this.field,
      operator: data.operator.present ? data.operator.value : this.operator,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupCondition(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('field: $field, ')
          ..write('operator: $operator, ')
          ..write('valueJson: $valueJson, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, field, operator, valueJson, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupCondition &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.field == this.field &&
          other.operator == this.operator &&
          other.valueJson == this.valueJson &&
          other.position == this.position);
}

class GroupConditionsCompanion extends UpdateCompanion<GroupCondition> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String> field;
  final Value<String> operator;
  final Value<String> valueJson;
  final Value<int> position;
  const GroupConditionsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.field = const Value.absent(),
    this.operator = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.position = const Value.absent(),
  });
  GroupConditionsCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    required String field,
    required String operator,
    required String valueJson,
    this.position = const Value.absent(),
  }) : groupId = Value(groupId),
       field = Value(field),
       operator = Value(operator),
       valueJson = Value(valueJson);
  static Insertable<GroupCondition> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? field,
    Expression<String>? operator,
    Expression<String>? valueJson,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (field != null) 'field': field,
      if (operator != null) 'operator': operator,
      if (valueJson != null) 'value_json': valueJson,
      if (position != null) 'position': position,
    });
  }

  GroupConditionsCompanion copyWith({
    Value<int>? id,
    Value<int>? groupId,
    Value<String>? field,
    Value<String>? operator,
    Value<String>? valueJson,
    Value<int>? position,
  }) {
    return GroupConditionsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      field: field ?? this.field,
      operator: operator ?? this.operator,
      valueJson: valueJson ?? this.valueJson,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (operator.present) {
      map['operator'] = Variable<String>(operator.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupConditionsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('field: $field, ')
          ..write('operator: $operator, ')
          ..write('valueJson: $valueJson, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $GroupStaticItemsTable extends GroupStaticItems
    with TableInfo<$GroupStaticItemsTable, GroupStaticItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupStaticItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_static_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupStaticItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, songId};
  @override
  GroupStaticItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupStaticItem(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $GroupStaticItemsTable createAlias(String alias) {
    return $GroupStaticItemsTable(attachedDatabase, alias);
  }
}

class GroupStaticItem extends DataClass implements Insertable<GroupStaticItem> {
  final int groupId;
  final String songId;
  final int position;
  const GroupStaticItem({
    required this.groupId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<int>(groupId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  GroupStaticItemsCompanion toCompanion(bool nullToAbsent) {
    return GroupStaticItemsCompanion(
      groupId: Value(groupId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory GroupStaticItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupStaticItem(
      groupId: serializer.fromJson<int>(json['groupId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  GroupStaticItem copyWith({int? groupId, String? songId, int? position}) =>
      GroupStaticItem(
        groupId: groupId ?? this.groupId,
        songId: songId ?? this.songId,
        position: position ?? this.position,
      );
  GroupStaticItem copyWithCompanion(GroupStaticItemsCompanion data) {
    return GroupStaticItem(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupStaticItem(')
          ..write('groupId: $groupId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupStaticItem &&
          other.groupId == this.groupId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class GroupStaticItemsCompanion extends UpdateCompanion<GroupStaticItem> {
  final Value<int> groupId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const GroupStaticItemsCompanion({
    this.groupId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupStaticItemsCompanion.insert({
    required int groupId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<GroupStaticItem> custom({
    Expression<int>? groupId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupStaticItemsCompanion copyWith({
    Value<int>? groupId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return GroupStaticItemsCompanion(
      groupId: groupId ?? this.groupId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupStaticItemsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupRefsTable extends GroupRefs
    with TableInfo<$GroupRefsTable, GroupRef> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupRefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _refGroupIdMeta = const VerificationMeta(
    'refGroupId',
  );
  @override
  late final GeneratedColumn<int> refGroupId = GeneratedColumn<int>(
    'ref_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, refGroupId, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_refs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupRef> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('ref_group_id')) {
      context.handle(
        _refGroupIdMeta,
        refGroupId.isAcceptableOrUnknown(
          data['ref_group_id']!,
          _refGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refGroupIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, refGroupId};
  @override
  GroupRef map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRef(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      refGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_group_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $GroupRefsTable createAlias(String alias) {
    return $GroupRefsTable(attachedDatabase, alias);
  }
}

class GroupRef extends DataClass implements Insertable<GroupRef> {
  final int groupId;
  final int refGroupId;

  /// 'include' | 'exclude'
  final String kind;
  const GroupRef({
    required this.groupId,
    required this.refGroupId,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<int>(groupId);
    map['ref_group_id'] = Variable<int>(refGroupId);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  GroupRefsCompanion toCompanion(bool nullToAbsent) {
    return GroupRefsCompanion(
      groupId: Value(groupId),
      refGroupId: Value(refGroupId),
      kind: Value(kind),
    );
  }

  factory GroupRef.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRef(
      groupId: serializer.fromJson<int>(json['groupId']),
      refGroupId: serializer.fromJson<int>(json['refGroupId']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'refGroupId': serializer.toJson<int>(refGroupId),
      'kind': serializer.toJson<String>(kind),
    };
  }

  GroupRef copyWith({int? groupId, int? refGroupId, String? kind}) => GroupRef(
    groupId: groupId ?? this.groupId,
    refGroupId: refGroupId ?? this.refGroupId,
    kind: kind ?? this.kind,
  );
  GroupRef copyWithCompanion(GroupRefsCompanion data) {
    return GroupRef(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      refGroupId: data.refGroupId.present
          ? data.refGroupId.value
          : this.refGroupId,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRef(')
          ..write('groupId: $groupId, ')
          ..write('refGroupId: $refGroupId, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, refGroupId, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRef &&
          other.groupId == this.groupId &&
          other.refGroupId == this.refGroupId &&
          other.kind == this.kind);
}

class GroupRefsCompanion extends UpdateCompanion<GroupRef> {
  final Value<int> groupId;
  final Value<int> refGroupId;
  final Value<String> kind;
  final Value<int> rowid;
  const GroupRefsCompanion({
    this.groupId = const Value.absent(),
    this.refGroupId = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupRefsCompanion.insert({
    required int groupId,
    required int refGroupId,
    required String kind,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       refGroupId = Value(refGroupId),
       kind = Value(kind);
  static Insertable<GroupRef> custom({
    Expression<int>? groupId,
    Expression<int>? refGroupId,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (refGroupId != null) 'ref_group_id': refGroupId,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupRefsCompanion copyWith({
    Value<int>? groupId,
    Value<int>? refGroupId,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return GroupRefsCompanion(
      groupId: groupId ?? this.groupId,
      refGroupId: refGroupId ?? this.refGroupId,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (refGroupId.present) {
      map['ref_group_id'] = Variable<int>(refGroupId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupRefsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('refGroupId: $refGroupId, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupOverridesTable extends GroupOverrides
    with TableInfo<$GroupOverridesTable, GroupOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupId, songId, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, songId};
  @override
  GroupOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupOverride(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $GroupOverridesTable createAlias(String alias) {
    return $GroupOverridesTable(attachedDatabase, alias);
  }
}

class GroupOverride extends DataClass implements Insertable<GroupOverride> {
  final int groupId;
  final String songId;

  /// 'pin' | 'exclude'
  final String kind;
  const GroupOverride({
    required this.groupId,
    required this.songId,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<int>(groupId);
    map['song_id'] = Variable<String>(songId);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  GroupOverridesCompanion toCompanion(bool nullToAbsent) {
    return GroupOverridesCompanion(
      groupId: Value(groupId),
      songId: Value(songId),
      kind: Value(kind),
    );
  }

  factory GroupOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupOverride(
      groupId: serializer.fromJson<int>(json['groupId']),
      songId: serializer.fromJson<String>(json['songId']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<int>(groupId),
      'songId': serializer.toJson<String>(songId),
      'kind': serializer.toJson<String>(kind),
    };
  }

  GroupOverride copyWith({int? groupId, String? songId, String? kind}) =>
      GroupOverride(
        groupId: groupId ?? this.groupId,
        songId: songId ?? this.songId,
        kind: kind ?? this.kind,
      );
  GroupOverride copyWithCompanion(GroupOverridesCompanion data) {
    return GroupOverride(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      songId: data.songId.present ? data.songId.value : this.songId,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupOverride(')
          ..write('groupId: $groupId, ')
          ..write('songId: $songId, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, songId, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupOverride &&
          other.groupId == this.groupId &&
          other.songId == this.songId &&
          other.kind == this.kind);
}

class GroupOverridesCompanion extends UpdateCompanion<GroupOverride> {
  final Value<int> groupId;
  final Value<String> songId;
  final Value<String> kind;
  final Value<int> rowid;
  const GroupOverridesCompanion({
    this.groupId = const Value.absent(),
    this.songId = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupOverridesCompanion.insert({
    required int groupId,
    required String songId,
    required String kind,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       songId = Value(songId),
       kind = Value(kind);
  static Insertable<GroupOverride> custom({
    Expression<int>? groupId,
    Expression<String>? songId,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (songId != null) 'song_id': songId,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupOverridesCompanion copyWith({
    Value<int>? groupId,
    Value<String>? songId,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return GroupOverridesCompanion(
      groupId: groupId ?? this.groupId,
      songId: songId ?? this.songId,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupOverridesCompanion(')
          ..write('groupId: $groupId, ')
          ..write('songId: $songId, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, QueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<double> sequence = GeneratedColumn<double>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sequence, songId, source, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sequence'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class QueueItem extends DataClass implements Insertable<QueueItem> {
  final int id;

  /// Sparse REAL ordering key — see TP §5.3 (insert-in-the-gap).
  final double sequence;
  final String songId;

  /// 'manual' | 'suggested'
  final String source;
  final DateTime addedAt;
  const QueueItem({
    required this.id,
    required this.sequence,
    required this.songId,
    required this.source,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sequence'] = Variable<double>(sequence);
    map['song_id'] = Variable<String>(songId);
    map['source'] = Variable<String>(source);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      sequence: Value(sequence),
      songId: Value(songId),
      source: Value(source),
      addedAt: Value(addedAt),
    );
  }

  factory QueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueItem(
      id: serializer.fromJson<int>(json['id']),
      sequence: serializer.fromJson<double>(json['sequence']),
      songId: serializer.fromJson<String>(json['songId']),
      source: serializer.fromJson<String>(json['source']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sequence': serializer.toJson<double>(sequence),
      'songId': serializer.toJson<String>(songId),
      'source': serializer.toJson<String>(source),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  QueueItem copyWith({
    int? id,
    double? sequence,
    String? songId,
    String? source,
    DateTime? addedAt,
  }) => QueueItem(
    id: id ?? this.id,
    sequence: sequence ?? this.sequence,
    songId: songId ?? this.songId,
    source: source ?? this.source,
    addedAt: addedAt ?? this.addedAt,
  );
  QueueItem copyWithCompanion(QueueItemsCompanion data) {
    return QueueItem(
      id: data.id.present ? data.id.value : this.id,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      songId: data.songId.present ? data.songId.value : this.songId,
      source: data.source.present ? data.source.value : this.source,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueItem(')
          ..write('id: $id, ')
          ..write('sequence: $sequence, ')
          ..write('songId: $songId, ')
          ..write('source: $source, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sequence, songId, source, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItem &&
          other.id == this.id &&
          other.sequence == this.sequence &&
          other.songId == this.songId &&
          other.source == this.source &&
          other.addedAt == this.addedAt);
}

class QueueItemsCompanion extends UpdateCompanion<QueueItem> {
  final Value<int> id;
  final Value<double> sequence;
  final Value<String> songId;
  final Value<String> source;
  final Value<DateTime> addedAt;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.sequence = const Value.absent(),
    this.songId = const Value.absent(),
    this.source = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required double sequence,
    required String songId,
    this.source = const Value.absent(),
    required DateTime addedAt,
  }) : sequence = Value(sequence),
       songId = Value(songId),
       addedAt = Value(addedAt);
  static Insertable<QueueItem> custom({
    Expression<int>? id,
    Expression<double>? sequence,
    Expression<String>? songId,
    Expression<String>? source,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sequence != null) 'sequence': sequence,
      if (songId != null) 'song_id': songId,
      if (source != null) 'source': source,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  QueueItemsCompanion copyWith({
    Value<int>? id,
    Value<double>? sequence,
    Value<String>? songId,
    Value<String>? source,
    Value<DateTime>? addedAt,
  }) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      sequence: sequence ?? this.sequence,
      songId: songId ?? this.songId,
      source: source ?? this.source,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<double>(sequence.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('sequence: $sequence, ')
          ..write('songId: $songId, ')
          ..write('source: $source, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $QueuePointerTable extends QueuePointer
    with TableInfo<$QueuePointerTable, QueuePointerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueuePointerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentItemIdMeta = const VerificationMeta(
    'currentItemId',
  );
  @override
  late final GeneratedColumn<int> currentItemId = GeneratedColumn<int>(
    'current_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDescriptionMeta = const VerificationMeta(
    'sourceDescription',
  );
  @override
  late final GeneratedColumn<String> sourceDescription =
      GeneratedColumn<String>(
        'source_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [id, currentItemId, sourceDescription];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_pointer';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueuePointerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_item_id')) {
      context.handle(
        _currentItemIdMeta,
        currentItemId.isAcceptableOrUnknown(
          data['current_item_id']!,
          _currentItemIdMeta,
        ),
      );
    }
    if (data.containsKey('source_description')) {
      context.handle(
        _sourceDescriptionMeta,
        sourceDescription.isAcceptableOrUnknown(
          data['source_description']!,
          _sourceDescriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuePointerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuePointerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_item_id'],
      ),
      sourceDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_description'],
      )!,
    );
  }

  @override
  $QueuePointerTable createAlias(String alias) {
    return $QueuePointerTable(attachedDatabase, alias);
  }
}

class QueuePointerRow extends DataClass implements Insertable<QueuePointerRow> {
  final int id;
  final int? currentItemId;
  final String sourceDescription;
  const QueuePointerRow({
    required this.id,
    this.currentItemId,
    required this.sourceDescription,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || currentItemId != null) {
      map['current_item_id'] = Variable<int>(currentItemId);
    }
    map['source_description'] = Variable<String>(sourceDescription);
    return map;
  }

  QueuePointerCompanion toCompanion(bool nullToAbsent) {
    return QueuePointerCompanion(
      id: Value(id),
      currentItemId: currentItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentItemId),
      sourceDescription: Value(sourceDescription),
    );
  }

  factory QueuePointerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuePointerRow(
      id: serializer.fromJson<int>(json['id']),
      currentItemId: serializer.fromJson<int?>(json['currentItemId']),
      sourceDescription: serializer.fromJson<String>(json['sourceDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentItemId': serializer.toJson<int?>(currentItemId),
      'sourceDescription': serializer.toJson<String>(sourceDescription),
    };
  }

  QueuePointerRow copyWith({
    int? id,
    Value<int?> currentItemId = const Value.absent(),
    String? sourceDescription,
  }) => QueuePointerRow(
    id: id ?? this.id,
    currentItemId: currentItemId.present
        ? currentItemId.value
        : this.currentItemId,
    sourceDescription: sourceDescription ?? this.sourceDescription,
  );
  QueuePointerRow copyWithCompanion(QueuePointerCompanion data) {
    return QueuePointerRow(
      id: data.id.present ? data.id.value : this.id,
      currentItemId: data.currentItemId.present
          ? data.currentItemId.value
          : this.currentItemId,
      sourceDescription: data.sourceDescription.present
          ? data.sourceDescription.value
          : this.sourceDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuePointerRow(')
          ..write('id: $id, ')
          ..write('currentItemId: $currentItemId, ')
          ..write('sourceDescription: $sourceDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currentItemId, sourceDescription);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuePointerRow &&
          other.id == this.id &&
          other.currentItemId == this.currentItemId &&
          other.sourceDescription == this.sourceDescription);
}

class QueuePointerCompanion extends UpdateCompanion<QueuePointerRow> {
  final Value<int> id;
  final Value<int?> currentItemId;
  final Value<String> sourceDescription;
  const QueuePointerCompanion({
    this.id = const Value.absent(),
    this.currentItemId = const Value.absent(),
    this.sourceDescription = const Value.absent(),
  });
  QueuePointerCompanion.insert({
    this.id = const Value.absent(),
    this.currentItemId = const Value.absent(),
    this.sourceDescription = const Value.absent(),
  });
  static Insertable<QueuePointerRow> custom({
    Expression<int>? id,
    Expression<int>? currentItemId,
    Expression<String>? sourceDescription,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentItemId != null) 'current_item_id': currentItemId,
      if (sourceDescription != null) 'source_description': sourceDescription,
    });
  }

  QueuePointerCompanion copyWith({
    Value<int>? id,
    Value<int?>? currentItemId,
    Value<String>? sourceDescription,
  }) {
    return QueuePointerCompanion(
      id: id ?? this.id,
      currentItemId: currentItemId ?? this.currentItemId,
      sourceDescription: sourceDescription ?? this.sourceDescription,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentItemId.present) {
      map['current_item_id'] = Variable<int>(currentItemId.value);
    }
    if (sourceDescription.present) {
      map['source_description'] = Variable<String>(sourceDescription.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueuePointerCompanion(')
          ..write('id: $id, ')
          ..write('currentItemId: $currentItemId, ')
          ..write('sourceDescription: $sourceDescription')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStatesTable extends PlaybackStates
    with TableInfo<$PlaybackStatesTable, PlaybackStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPlayingMeta = const VerificationMeta(
    'isPlaying',
  );
  @override
  late final GeneratedColumn<bool> isPlaying = GeneratedColumn<bool>(
    'is_playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_playing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _preservePitchMeta = const VerificationMeta(
    'preservePitch',
  );
  @override
  late final GeneratedColumn<bool> preservePitch = GeneratedColumn<bool>(
    'preserve_pitch',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("preserve_pitch" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<int> repeatMode = GeneratedColumn<int>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shuffleEnabledMeta = const VerificationMeta(
    'shuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> shuffleEnabled = GeneratedColumn<bool>(
    'shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _outputRouteMeta = const VerificationMeta(
    'outputRoute',
  );
  @override
  late final GeneratedColumn<String> outputRoute = GeneratedColumn<String>(
    'output_route',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('speaker'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    positionMs,
    isPlaying,
    speed,
    preservePitch,
    repeatMode,
    shuffleEnabled,
    outputRoute,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('is_playing')) {
      context.handle(
        _isPlayingMeta,
        isPlaying.isAcceptableOrUnknown(data['is_playing']!, _isPlayingMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('preserve_pitch')) {
      context.handle(
        _preservePitchMeta,
        preservePitch.isAcceptableOrUnknown(
          data['preserve_pitch']!,
          _preservePitchMeta,
        ),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('shuffle_enabled')) {
      context.handle(
        _shuffleEnabledMeta,
        shuffleEnabled.isAcceptableOrUnknown(
          data['shuffle_enabled']!,
          _shuffleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('output_route')) {
      context.handle(
        _outputRouteMeta,
        outputRoute.isAcceptableOrUnknown(
          data['output_route']!,
          _outputRouteMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      isPlaying: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_playing'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      preservePitch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}preserve_pitch'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_mode'],
      )!,
      shuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_enabled'],
      )!,
      outputRoute: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_route'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaybackStatesTable createAlias(String alias) {
    return $PlaybackStatesTable(attachedDatabase, alias);
  }
}

class PlaybackStateRow extends DataClass
    implements Insertable<PlaybackStateRow> {
  final int id;
  final int positionMs;
  final bool isPlaying;
  final double speed;
  final bool preservePitch;

  /// 0 = off, 1 = repeat queue, 2 = repeat one.
  final int repeatMode;
  final bool shuffleEnabled;
  final String outputRoute;
  final DateTime updatedAt;
  const PlaybackStateRow({
    required this.id,
    required this.positionMs,
    required this.isPlaying,
    required this.speed,
    required this.preservePitch,
    required this.repeatMode,
    required this.shuffleEnabled,
    required this.outputRoute,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['position_ms'] = Variable<int>(positionMs);
    map['is_playing'] = Variable<bool>(isPlaying);
    map['speed'] = Variable<double>(speed);
    map['preserve_pitch'] = Variable<bool>(preservePitch);
    map['repeat_mode'] = Variable<int>(repeatMode);
    map['shuffle_enabled'] = Variable<bool>(shuffleEnabled);
    map['output_route'] = Variable<String>(outputRoute);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackStatesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStatesCompanion(
      id: Value(id),
      positionMs: Value(positionMs),
      isPlaying: Value(isPlaying),
      speed: Value(speed),
      preservePitch: Value(preservePitch),
      repeatMode: Value(repeatMode),
      shuffleEnabled: Value(shuffleEnabled),
      outputRoute: Value(outputRoute),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackStateRow(
      id: serializer.fromJson<int>(json['id']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      isPlaying: serializer.fromJson<bool>(json['isPlaying']),
      speed: serializer.fromJson<double>(json['speed']),
      preservePitch: serializer.fromJson<bool>(json['preservePitch']),
      repeatMode: serializer.fromJson<int>(json['repeatMode']),
      shuffleEnabled: serializer.fromJson<bool>(json['shuffleEnabled']),
      outputRoute: serializer.fromJson<String>(json['outputRoute']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'positionMs': serializer.toJson<int>(positionMs),
      'isPlaying': serializer.toJson<bool>(isPlaying),
      'speed': serializer.toJson<double>(speed),
      'preservePitch': serializer.toJson<bool>(preservePitch),
      'repeatMode': serializer.toJson<int>(repeatMode),
      'shuffleEnabled': serializer.toJson<bool>(shuffleEnabled),
      'outputRoute': serializer.toJson<String>(outputRoute),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackStateRow copyWith({
    int? id,
    int? positionMs,
    bool? isPlaying,
    double? speed,
    bool? preservePitch,
    int? repeatMode,
    bool? shuffleEnabled,
    String? outputRoute,
    DateTime? updatedAt,
  }) => PlaybackStateRow(
    id: id ?? this.id,
    positionMs: positionMs ?? this.positionMs,
    isPlaying: isPlaying ?? this.isPlaying,
    speed: speed ?? this.speed,
    preservePitch: preservePitch ?? this.preservePitch,
    repeatMode: repeatMode ?? this.repeatMode,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    outputRoute: outputRoute ?? this.outputRoute,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaybackStateRow copyWithCompanion(PlaybackStatesCompanion data) {
    return PlaybackStateRow(
      id: data.id.present ? data.id.value : this.id,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      isPlaying: data.isPlaying.present ? data.isPlaying.value : this.isPlaying,
      speed: data.speed.present ? data.speed.value : this.speed,
      preservePitch: data.preservePitch.present
          ? data.preservePitch.value
          : this.preservePitch,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      shuffleEnabled: data.shuffleEnabled.present
          ? data.shuffleEnabled.value
          : this.shuffleEnabled,
      outputRoute: data.outputRoute.present
          ? data.outputRoute.value
          : this.outputRoute,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStateRow(')
          ..write('id: $id, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('speed: $speed, ')
          ..write('preservePitch: $preservePitch, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('outputRoute: $outputRoute, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    positionMs,
    isPlaying,
    speed,
    preservePitch,
    repeatMode,
    shuffleEnabled,
    outputRoute,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackStateRow &&
          other.id == this.id &&
          other.positionMs == this.positionMs &&
          other.isPlaying == this.isPlaying &&
          other.speed == this.speed &&
          other.preservePitch == this.preservePitch &&
          other.repeatMode == this.repeatMode &&
          other.shuffleEnabled == this.shuffleEnabled &&
          other.outputRoute == this.outputRoute &&
          other.updatedAt == this.updatedAt);
}

class PlaybackStatesCompanion extends UpdateCompanion<PlaybackStateRow> {
  final Value<int> id;
  final Value<int> positionMs;
  final Value<bool> isPlaying;
  final Value<double> speed;
  final Value<bool> preservePitch;
  final Value<int> repeatMode;
  final Value<bool> shuffleEnabled;
  final Value<String> outputRoute;
  final Value<DateTime> updatedAt;
  const PlaybackStatesCompanion({
    this.id = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.speed = const Value.absent(),
    this.preservePitch = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.outputRoute = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaybackStatesCompanion.insert({
    this.id = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.speed = const Value.absent(),
    this.preservePitch = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.outputRoute = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<PlaybackStateRow> custom({
    Expression<int>? id,
    Expression<int>? positionMs,
    Expression<bool>? isPlaying,
    Expression<double>? speed,
    Expression<bool>? preservePitch,
    Expression<int>? repeatMode,
    Expression<bool>? shuffleEnabled,
    Expression<String>? outputRoute,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (positionMs != null) 'position_ms': positionMs,
      if (isPlaying != null) 'is_playing': isPlaying,
      if (speed != null) 'speed': speed,
      if (preservePitch != null) 'preserve_pitch': preservePitch,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (shuffleEnabled != null) 'shuffle_enabled': shuffleEnabled,
      if (outputRoute != null) 'output_route': outputRoute,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaybackStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? positionMs,
    Value<bool>? isPlaying,
    Value<double>? speed,
    Value<bool>? preservePitch,
    Value<int>? repeatMode,
    Value<bool>? shuffleEnabled,
    Value<String>? outputRoute,
    Value<DateTime>? updatedAt,
  }) {
    return PlaybackStatesCompanion(
      id: id ?? this.id,
      positionMs: positionMs ?? this.positionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      preservePitch: preservePitch ?? this.preservePitch,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      outputRoute: outputRoute ?? this.outputRoute,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (isPlaying.present) {
      map['is_playing'] = Variable<bool>(isPlaying.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (preservePitch.present) {
      map['preserve_pitch'] = Variable<bool>(preservePitch.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<int>(repeatMode.value);
    }
    if (shuffleEnabled.present) {
      map['shuffle_enabled'] = Variable<bool>(shuffleEnabled.value);
    }
    if (outputRoute.present) {
      map['output_route'] = Variable<String>(outputRoute.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStatesCompanion(')
          ..write('id: $id, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('speed: $speed, ')
          ..write('preservePitch: $preservePitch, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('outputRoute: $outputRoute, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayStatsTable extends PlayStats
    with TableInfo<$PlayStatsTable, PlayStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favouriteMeta = const VerificationMeta(
    'favourite',
  );
  @override
  late final GeneratedColumn<bool> favourite = GeneratedColumn<bool>(
    'favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    playCount,
    skipCount,
    lastPlayedAt,
    favourite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('favourite')) {
      context.handle(
        _favouriteMeta,
        favourite.isAcceptableOrUnknown(data['favourite']!, _favouriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  PlayStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayStat(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      favourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favourite'],
      )!,
    );
  }

  @override
  $PlayStatsTable createAlias(String alias) {
    return $PlayStatsTable(attachedDatabase, alias);
  }
}

class PlayStat extends DataClass implements Insertable<PlayStat> {
  final String songId;
  final int playCount;
  final int skipCount;
  final DateTime? lastPlayedAt;
  final bool favourite;
  const PlayStat({
    required this.songId,
    required this.playCount,
    required this.skipCount,
    this.lastPlayedAt,
    required this.favourite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['play_count'] = Variable<int>(playCount);
    map['skip_count'] = Variable<int>(skipCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['favourite'] = Variable<bool>(favourite);
    return map;
  }

  PlayStatsCompanion toCompanion(bool nullToAbsent) {
    return PlayStatsCompanion(
      songId: Value(songId),
      playCount: Value(playCount),
      skipCount: Value(skipCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      favourite: Value(favourite),
    );
  }

  factory PlayStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayStat(
      songId: serializer.fromJson<String>(json['songId']),
      playCount: serializer.fromJson<int>(json['playCount']),
      skipCount: serializer.fromJson<int>(json['skipCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      favourite: serializer.fromJson<bool>(json['favourite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'playCount': serializer.toJson<int>(playCount),
      'skipCount': serializer.toJson<int>(skipCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'favourite': serializer.toJson<bool>(favourite),
    };
  }

  PlayStat copyWith({
    String? songId,
    int? playCount,
    int? skipCount,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    bool? favourite,
  }) => PlayStat(
    songId: songId ?? this.songId,
    playCount: playCount ?? this.playCount,
    skipCount: skipCount ?? this.skipCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    favourite: favourite ?? this.favourite,
  );
  PlayStat copyWithCompanion(PlayStatsCompanion data) {
    return PlayStat(
      songId: data.songId.present ? data.songId.value : this.songId,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      favourite: data.favourite.present ? data.favourite.value : this.favourite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayStat(')
          ..write('songId: $songId, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('favourite: $favourite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(songId, playCount, skipCount, lastPlayedAt, favourite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayStat &&
          other.songId == this.songId &&
          other.playCount == this.playCount &&
          other.skipCount == this.skipCount &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.favourite == this.favourite);
}

class PlayStatsCompanion extends UpdateCompanion<PlayStat> {
  final Value<String> songId;
  final Value<int> playCount;
  final Value<int> skipCount;
  final Value<DateTime?> lastPlayedAt;
  final Value<bool> favourite;
  final Value<int> rowid;
  const PlayStatsCompanion({
    this.songId = const Value.absent(),
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.favourite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayStatsCompanion.insert({
    required String songId,
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.favourite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : songId = Value(songId);
  static Insertable<PlayStat> custom({
    Expression<String>? songId,
    Expression<int>? playCount,
    Expression<int>? skipCount,
    Expression<DateTime>? lastPlayedAt,
    Expression<bool>? favourite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (playCount != null) 'play_count': playCount,
      if (skipCount != null) 'skip_count': skipCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (favourite != null) 'favourite': favourite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayStatsCompanion copyWith({
    Value<String>? songId,
    Value<int>? playCount,
    Value<int>? skipCount,
    Value<DateTime?>? lastPlayedAt,
    Value<bool>? favourite,
    Value<int>? rowid,
  }) {
    return PlayStatsCompanion(
      songId: songId ?? this.songId,
      playCount: playCount ?? this.playCount,
      skipCount: skipCount ?? this.skipCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      favourite: favourite ?? this.favourite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (favourite.present) {
      map['favourite'] = Variable<bool>(favourite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayStatsCompanion(')
          ..write('songId: $songId, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('favourite: $favourite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LyricsCacheTable extends LyricsCache
    with TableInfo<$LyricsCacheTable, LyricsRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedLrcMeta = const VerificationMeta(
    'syncedLrc',
  );
  @override
  late final GeneratedColumn<String> syncedLrc = GeneratedColumn<String>(
    'synced_lrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offsetMsMeta = const VerificationMeta(
    'offsetMs',
  );
  @override
  late final GeneratedColumn<int> offsetMs = GeneratedColumn<int>(
    'offset_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    providerId,
    syncedLrc,
    plainText,
    source,
    offsetMs,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('synced_lrc')) {
      context.handle(
        _syncedLrcMeta,
        syncedLrc.isAcceptableOrUnknown(data['synced_lrc']!, _syncedLrcMeta),
      );
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('offset_ms')) {
      context.handle(
        _offsetMsMeta,
        offsetMs.isAcceptableOrUnknown(data['offset_ms']!, _offsetMsMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  LyricsRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsRecord(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      syncedLrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_lrc'],
      ),
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      offsetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_ms'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $LyricsCacheTable createAlias(String alias) {
    return $LyricsCacheTable(attachedDatabase, alias);
  }
}

class LyricsRecord extends DataClass implements Insertable<LyricsRecord> {
  final String songId;
  final String providerId;
  final String? syncedLrc;
  final String? plainText;

  /// 'embedded' | 'remote'
  final String source;
  final int offsetMs;
  final DateTime fetchedAt;
  const LyricsRecord({
    required this.songId,
    required this.providerId,
    this.syncedLrc,
    this.plainText,
    required this.source,
    required this.offsetMs,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['provider_id'] = Variable<String>(providerId);
    if (!nullToAbsent || syncedLrc != null) {
      map['synced_lrc'] = Variable<String>(syncedLrc);
    }
    if (!nullToAbsent || plainText != null) {
      map['plain_text'] = Variable<String>(plainText);
    }
    map['source'] = Variable<String>(source);
    map['offset_ms'] = Variable<int>(offsetMs);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  LyricsCacheCompanion toCompanion(bool nullToAbsent) {
    return LyricsCacheCompanion(
      songId: Value(songId),
      providerId: Value(providerId),
      syncedLrc: syncedLrc == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedLrc),
      plainText: plainText == null && nullToAbsent
          ? const Value.absent()
          : Value(plainText),
      source: Value(source),
      offsetMs: Value(offsetMs),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory LyricsRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsRecord(
      songId: serializer.fromJson<String>(json['songId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      syncedLrc: serializer.fromJson<String?>(json['syncedLrc']),
      plainText: serializer.fromJson<String?>(json['plainText']),
      source: serializer.fromJson<String>(json['source']),
      offsetMs: serializer.fromJson<int>(json['offsetMs']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'providerId': serializer.toJson<String>(providerId),
      'syncedLrc': serializer.toJson<String?>(syncedLrc),
      'plainText': serializer.toJson<String?>(plainText),
      'source': serializer.toJson<String>(source),
      'offsetMs': serializer.toJson<int>(offsetMs),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  LyricsRecord copyWith({
    String? songId,
    String? providerId,
    Value<String?> syncedLrc = const Value.absent(),
    Value<String?> plainText = const Value.absent(),
    String? source,
    int? offsetMs,
    DateTime? fetchedAt,
  }) => LyricsRecord(
    songId: songId ?? this.songId,
    providerId: providerId ?? this.providerId,
    syncedLrc: syncedLrc.present ? syncedLrc.value : this.syncedLrc,
    plainText: plainText.present ? plainText.value : this.plainText,
    source: source ?? this.source,
    offsetMs: offsetMs ?? this.offsetMs,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  LyricsRecord copyWithCompanion(LyricsCacheCompanion data) {
    return LyricsRecord(
      songId: data.songId.present ? data.songId.value : this.songId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      syncedLrc: data.syncedLrc.present ? data.syncedLrc.value : this.syncedLrc,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      source: data.source.present ? data.source.value : this.source,
      offsetMs: data.offsetMs.present ? data.offsetMs.value : this.offsetMs,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsRecord(')
          ..write('songId: $songId, ')
          ..write('providerId: $providerId, ')
          ..write('syncedLrc: $syncedLrc, ')
          ..write('plainText: $plainText, ')
          ..write('source: $source, ')
          ..write('offsetMs: $offsetMs, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    songId,
    providerId,
    syncedLrc,
    plainText,
    source,
    offsetMs,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsRecord &&
          other.songId == this.songId &&
          other.providerId == this.providerId &&
          other.syncedLrc == this.syncedLrc &&
          other.plainText == this.plainText &&
          other.source == this.source &&
          other.offsetMs == this.offsetMs &&
          other.fetchedAt == this.fetchedAt);
}

class LyricsCacheCompanion extends UpdateCompanion<LyricsRecord> {
  final Value<String> songId;
  final Value<String> providerId;
  final Value<String?> syncedLrc;
  final Value<String?> plainText;
  final Value<String> source;
  final Value<int> offsetMs;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const LyricsCacheCompanion({
    this.songId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.syncedLrc = const Value.absent(),
    this.plainText = const Value.absent(),
    this.source = const Value.absent(),
    this.offsetMs = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricsCacheCompanion.insert({
    required String songId,
    required String providerId,
    this.syncedLrc = const Value.absent(),
    this.plainText = const Value.absent(),
    required String source,
    this.offsetMs = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       providerId = Value(providerId),
       source = Value(source),
       fetchedAt = Value(fetchedAt);
  static Insertable<LyricsRecord> custom({
    Expression<String>? songId,
    Expression<String>? providerId,
    Expression<String>? syncedLrc,
    Expression<String>? plainText,
    Expression<String>? source,
    Expression<int>? offsetMs,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (providerId != null) 'provider_id': providerId,
      if (syncedLrc != null) 'synced_lrc': syncedLrc,
      if (plainText != null) 'plain_text': plainText,
      if (source != null) 'source': source,
      if (offsetMs != null) 'offset_ms': offsetMs,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricsCacheCompanion copyWith({
    Value<String>? songId,
    Value<String>? providerId,
    Value<String?>? syncedLrc,
    Value<String?>? plainText,
    Value<String>? source,
    Value<int>? offsetMs,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return LyricsCacheCompanion(
      songId: songId ?? this.songId,
      providerId: providerId ?? this.providerId,
      syncedLrc: syncedLrc ?? this.syncedLrc,
      plainText: plainText ?? this.plainText,
      source: source ?? this.source,
      offsetMs: offsetMs ?? this.offsetMs,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (syncedLrc.present) {
      map['synced_lrc'] = Variable<String>(syncedLrc.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (offsetMs.present) {
      map['offset_ms'] = Variable<int>(offsetMs.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsCacheCompanion(')
          ..write('songId: $songId, ')
          ..write('providerId: $providerId, ')
          ..write('syncedLrc: $syncedLrc, ')
          ..write('plainText: $plainText, ')
          ..write('source: $source, ')
          ..write('offsetMs: $offsetMs, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongAudioFeaturesTableTable extends SongAudioFeaturesTable
    with TableInfo<$SongAudioFeaturesTableTable, SongAudioFeatures> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongAudioFeaturesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tempoBpmMeta = const VerificationMeta(
    'tempoBpm',
  );
  @override
  late final GeneratedColumn<double> tempoBpm = GeneratedColumn<double>(
    'tempo_bpm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyIndexMeta = const VerificationMeta(
    'keyIndex',
  );
  @override
  late final GeneratedColumn<int> keyIndex = GeneratedColumn<int>(
    'key_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyModeMeta = const VerificationMeta(
    'keyMode',
  );
  @override
  late final GeneratedColumn<int> keyMode = GeneratedColumn<int>(
    'key_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<double> energy = GeneratedColumn<double>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acousticnessMeta = const VerificationMeta(
    'acousticness',
  );
  @override
  late final GeneratedColumn<double> acousticness = GeneratedColumn<double>(
    'acousticness',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brightnessMeta = const VerificationMeta(
    'brightness',
  );
  @override
  late final GeneratedColumn<double> brightness = GeneratedColumn<double>(
    'brightness',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _danceabilityMeta = const VerificationMeta(
    'danceability',
  );
  @override
  late final GeneratedColumn<double> danceability = GeneratedColumn<double>(
    'danceability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingBlobMeta = const VerificationMeta(
    'embeddingBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> embeddingBlob =
      GeneratedColumn<Uint8List>(
        'embedding_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
    'analyzed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    songId,
    tempoBpm,
    keyIndex,
    keyMode,
    energy,
    acousticness,
    brightness,
    danceability,
    embeddingBlob,
    modelVersion,
    analyzedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_audio_features';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongAudioFeatures> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('tempo_bpm')) {
      context.handle(
        _tempoBpmMeta,
        tempoBpm.isAcceptableOrUnknown(data['tempo_bpm']!, _tempoBpmMeta),
      );
    } else if (isInserting) {
      context.missing(_tempoBpmMeta);
    }
    if (data.containsKey('key_index')) {
      context.handle(
        _keyIndexMeta,
        keyIndex.isAcceptableOrUnknown(data['key_index']!, _keyIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_keyIndexMeta);
    }
    if (data.containsKey('key_mode')) {
      context.handle(
        _keyModeMeta,
        keyMode.isAcceptableOrUnknown(data['key_mode']!, _keyModeMeta),
      );
    } else if (isInserting) {
      context.missing(_keyModeMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('acousticness')) {
      context.handle(
        _acousticnessMeta,
        acousticness.isAcceptableOrUnknown(
          data['acousticness']!,
          _acousticnessMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_acousticnessMeta);
    }
    if (data.containsKey('brightness')) {
      context.handle(
        _brightnessMeta,
        brightness.isAcceptableOrUnknown(data['brightness']!, _brightnessMeta),
      );
    } else if (isInserting) {
      context.missing(_brightnessMeta);
    }
    if (data.containsKey('danceability')) {
      context.handle(
        _danceabilityMeta,
        danceability.isAcceptableOrUnknown(
          data['danceability']!,
          _danceabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_danceabilityMeta);
    }
    if (data.containsKey('embedding_blob')) {
      context.handle(
        _embeddingBlobMeta,
        embeddingBlob.isAcceptableOrUnknown(
          data['embedding_blob']!,
          _embeddingBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_embeddingBlobMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_analyzedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  SongAudioFeatures map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongAudioFeatures(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      tempoBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tempo_bpm'],
      )!,
      keyIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_index'],
      )!,
      keyMode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_mode'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy'],
      )!,
      acousticness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}acousticness'],
      )!,
      brightness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brightness'],
      )!,
      danceability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}danceability'],
      )!,
      embeddingBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}embedding_blob'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at'],
      )!,
    );
  }

  @override
  $SongAudioFeaturesTableTable createAlias(String alias) {
    return $SongAudioFeaturesTableTable(attachedDatabase, alias);
  }
}

class SongAudioFeatures extends DataClass
    implements Insertable<SongAudioFeatures> {
  final String songId;
  final double tempoBpm;
  final int keyIndex;

  /// 0 = minor, 1 = major.
  final int keyMode;
  final double energy;
  final double acousticness;
  final double brightness;
  final double danceability;

  /// Packed Float32List bytes.
  final Uint8List embeddingBlob;
  final String modelVersion;
  final DateTime analyzedAt;
  const SongAudioFeatures({
    required this.songId,
    required this.tempoBpm,
    required this.keyIndex,
    required this.keyMode,
    required this.energy,
    required this.acousticness,
    required this.brightness,
    required this.danceability,
    required this.embeddingBlob,
    required this.modelVersion,
    required this.analyzedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['tempo_bpm'] = Variable<double>(tempoBpm);
    map['key_index'] = Variable<int>(keyIndex);
    map['key_mode'] = Variable<int>(keyMode);
    map['energy'] = Variable<double>(energy);
    map['acousticness'] = Variable<double>(acousticness);
    map['brightness'] = Variable<double>(brightness);
    map['danceability'] = Variable<double>(danceability);
    map['embedding_blob'] = Variable<Uint8List>(embeddingBlob);
    map['model_version'] = Variable<String>(modelVersion);
    map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    return map;
  }

  SongAudioFeaturesTableCompanion toCompanion(bool nullToAbsent) {
    return SongAudioFeaturesTableCompanion(
      songId: Value(songId),
      tempoBpm: Value(tempoBpm),
      keyIndex: Value(keyIndex),
      keyMode: Value(keyMode),
      energy: Value(energy),
      acousticness: Value(acousticness),
      brightness: Value(brightness),
      danceability: Value(danceability),
      embeddingBlob: Value(embeddingBlob),
      modelVersion: Value(modelVersion),
      analyzedAt: Value(analyzedAt),
    );
  }

  factory SongAudioFeatures.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongAudioFeatures(
      songId: serializer.fromJson<String>(json['songId']),
      tempoBpm: serializer.fromJson<double>(json['tempoBpm']),
      keyIndex: serializer.fromJson<int>(json['keyIndex']),
      keyMode: serializer.fromJson<int>(json['keyMode']),
      energy: serializer.fromJson<double>(json['energy']),
      acousticness: serializer.fromJson<double>(json['acousticness']),
      brightness: serializer.fromJson<double>(json['brightness']),
      danceability: serializer.fromJson<double>(json['danceability']),
      embeddingBlob: serializer.fromJson<Uint8List>(json['embeddingBlob']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      analyzedAt: serializer.fromJson<DateTime>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'tempoBpm': serializer.toJson<double>(tempoBpm),
      'keyIndex': serializer.toJson<int>(keyIndex),
      'keyMode': serializer.toJson<int>(keyMode),
      'energy': serializer.toJson<double>(energy),
      'acousticness': serializer.toJson<double>(acousticness),
      'brightness': serializer.toJson<double>(brightness),
      'danceability': serializer.toJson<double>(danceability),
      'embeddingBlob': serializer.toJson<Uint8List>(embeddingBlob),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'analyzedAt': serializer.toJson<DateTime>(analyzedAt),
    };
  }

  SongAudioFeatures copyWith({
    String? songId,
    double? tempoBpm,
    int? keyIndex,
    int? keyMode,
    double? energy,
    double? acousticness,
    double? brightness,
    double? danceability,
    Uint8List? embeddingBlob,
    String? modelVersion,
    DateTime? analyzedAt,
  }) => SongAudioFeatures(
    songId: songId ?? this.songId,
    tempoBpm: tempoBpm ?? this.tempoBpm,
    keyIndex: keyIndex ?? this.keyIndex,
    keyMode: keyMode ?? this.keyMode,
    energy: energy ?? this.energy,
    acousticness: acousticness ?? this.acousticness,
    brightness: brightness ?? this.brightness,
    danceability: danceability ?? this.danceability,
    embeddingBlob: embeddingBlob ?? this.embeddingBlob,
    modelVersion: modelVersion ?? this.modelVersion,
    analyzedAt: analyzedAt ?? this.analyzedAt,
  );
  SongAudioFeatures copyWithCompanion(SongAudioFeaturesTableCompanion data) {
    return SongAudioFeatures(
      songId: data.songId.present ? data.songId.value : this.songId,
      tempoBpm: data.tempoBpm.present ? data.tempoBpm.value : this.tempoBpm,
      keyIndex: data.keyIndex.present ? data.keyIndex.value : this.keyIndex,
      keyMode: data.keyMode.present ? data.keyMode.value : this.keyMode,
      energy: data.energy.present ? data.energy.value : this.energy,
      acousticness: data.acousticness.present
          ? data.acousticness.value
          : this.acousticness,
      brightness: data.brightness.present
          ? data.brightness.value
          : this.brightness,
      danceability: data.danceability.present
          ? data.danceability.value
          : this.danceability,
      embeddingBlob: data.embeddingBlob.present
          ? data.embeddingBlob.value
          : this.embeddingBlob,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongAudioFeatures(')
          ..write('songId: $songId, ')
          ..write('tempoBpm: $tempoBpm, ')
          ..write('keyIndex: $keyIndex, ')
          ..write('keyMode: $keyMode, ')
          ..write('energy: $energy, ')
          ..write('acousticness: $acousticness, ')
          ..write('brightness: $brightness, ')
          ..write('danceability: $danceability, ')
          ..write('embeddingBlob: $embeddingBlob, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    songId,
    tempoBpm,
    keyIndex,
    keyMode,
    energy,
    acousticness,
    brightness,
    danceability,
    $driftBlobEquality.hash(embeddingBlob),
    modelVersion,
    analyzedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongAudioFeatures &&
          other.songId == this.songId &&
          other.tempoBpm == this.tempoBpm &&
          other.keyIndex == this.keyIndex &&
          other.keyMode == this.keyMode &&
          other.energy == this.energy &&
          other.acousticness == this.acousticness &&
          other.brightness == this.brightness &&
          other.danceability == this.danceability &&
          $driftBlobEquality.equals(other.embeddingBlob, this.embeddingBlob) &&
          other.modelVersion == this.modelVersion &&
          other.analyzedAt == this.analyzedAt);
}

class SongAudioFeaturesTableCompanion
    extends UpdateCompanion<SongAudioFeatures> {
  final Value<String> songId;
  final Value<double> tempoBpm;
  final Value<int> keyIndex;
  final Value<int> keyMode;
  final Value<double> energy;
  final Value<double> acousticness;
  final Value<double> brightness;
  final Value<double> danceability;
  final Value<Uint8List> embeddingBlob;
  final Value<String> modelVersion;
  final Value<DateTime> analyzedAt;
  final Value<int> rowid;
  const SongAudioFeaturesTableCompanion({
    this.songId = const Value.absent(),
    this.tempoBpm = const Value.absent(),
    this.keyIndex = const Value.absent(),
    this.keyMode = const Value.absent(),
    this.energy = const Value.absent(),
    this.acousticness = const Value.absent(),
    this.brightness = const Value.absent(),
    this.danceability = const Value.absent(),
    this.embeddingBlob = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongAudioFeaturesTableCompanion.insert({
    required String songId,
    required double tempoBpm,
    required int keyIndex,
    required int keyMode,
    required double energy,
    required double acousticness,
    required double brightness,
    required double danceability,
    required Uint8List embeddingBlob,
    required String modelVersion,
    required DateTime analyzedAt,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       tempoBpm = Value(tempoBpm),
       keyIndex = Value(keyIndex),
       keyMode = Value(keyMode),
       energy = Value(energy),
       acousticness = Value(acousticness),
       brightness = Value(brightness),
       danceability = Value(danceability),
       embeddingBlob = Value(embeddingBlob),
       modelVersion = Value(modelVersion),
       analyzedAt = Value(analyzedAt);
  static Insertable<SongAudioFeatures> custom({
    Expression<String>? songId,
    Expression<double>? tempoBpm,
    Expression<int>? keyIndex,
    Expression<int>? keyMode,
    Expression<double>? energy,
    Expression<double>? acousticness,
    Expression<double>? brightness,
    Expression<double>? danceability,
    Expression<Uint8List>? embeddingBlob,
    Expression<String>? modelVersion,
    Expression<DateTime>? analyzedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (tempoBpm != null) 'tempo_bpm': tempoBpm,
      if (keyIndex != null) 'key_index': keyIndex,
      if (keyMode != null) 'key_mode': keyMode,
      if (energy != null) 'energy': energy,
      if (acousticness != null) 'acousticness': acousticness,
      if (brightness != null) 'brightness': brightness,
      if (danceability != null) 'danceability': danceability,
      if (embeddingBlob != null) 'embedding_blob': embeddingBlob,
      if (modelVersion != null) 'model_version': modelVersion,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongAudioFeaturesTableCompanion copyWith({
    Value<String>? songId,
    Value<double>? tempoBpm,
    Value<int>? keyIndex,
    Value<int>? keyMode,
    Value<double>? energy,
    Value<double>? acousticness,
    Value<double>? brightness,
    Value<double>? danceability,
    Value<Uint8List>? embeddingBlob,
    Value<String>? modelVersion,
    Value<DateTime>? analyzedAt,
    Value<int>? rowid,
  }) {
    return SongAudioFeaturesTableCompanion(
      songId: songId ?? this.songId,
      tempoBpm: tempoBpm ?? this.tempoBpm,
      keyIndex: keyIndex ?? this.keyIndex,
      keyMode: keyMode ?? this.keyMode,
      energy: energy ?? this.energy,
      acousticness: acousticness ?? this.acousticness,
      brightness: brightness ?? this.brightness,
      danceability: danceability ?? this.danceability,
      embeddingBlob: embeddingBlob ?? this.embeddingBlob,
      modelVersion: modelVersion ?? this.modelVersion,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (tempoBpm.present) {
      map['tempo_bpm'] = Variable<double>(tempoBpm.value);
    }
    if (keyIndex.present) {
      map['key_index'] = Variable<int>(keyIndex.value);
    }
    if (keyMode.present) {
      map['key_mode'] = Variable<int>(keyMode.value);
    }
    if (energy.present) {
      map['energy'] = Variable<double>(energy.value);
    }
    if (acousticness.present) {
      map['acousticness'] = Variable<double>(acousticness.value);
    }
    if (brightness.present) {
      map['brightness'] = Variable<double>(brightness.value);
    }
    if (danceability.present) {
      map['danceability'] = Variable<double>(danceability.value);
    }
    if (embeddingBlob.present) {
      map['embedding_blob'] = Variable<Uint8List>(embeddingBlob.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongAudioFeaturesTableCompanion(')
          ..write('songId: $songId, ')
          ..write('tempoBpm: $tempoBpm, ')
          ..write('keyIndex: $keyIndex, ')
          ..write('keyMode: $keyMode, ')
          ..write('energy: $energy, ')
          ..write('acousticness: $acousticness, ')
          ..write('brightness: $brightness, ')
          ..write('danceability: $danceability, ')
          ..write('embeddingBlob: $embeddingBlob, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteCatalogueCacheTable extends RemoteCatalogueCache
    with TableInfo<$RemoteCatalogueCacheTable, RemoteCatalogueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteCatalogueCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonBlobMeta = const VerificationMeta(
    'jsonBlob',
  );
  @override
  late final GeneratedColumn<String> jsonBlob = GeneratedColumn<String>(
    'json_blob',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, jsonBlob, etag, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_catalogue_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemoteCatalogueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json_blob')) {
      context.handle(
        _jsonBlobMeta,
        jsonBlob.isAcceptableOrUnknown(data['json_blob']!, _jsonBlobMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonBlobMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  RemoteCatalogueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteCatalogueEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      jsonBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_blob'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $RemoteCatalogueCacheTable createAlias(String alias) {
    return $RemoteCatalogueCacheTable(attachedDatabase, alias);
  }
}

class RemoteCatalogueEntry extends DataClass
    implements Insertable<RemoteCatalogueEntry> {
  /// 'download_catalogue' | 'lyrics_providers'
  final String key;
  final String jsonBlob;
  final String? etag;
  final DateTime fetchedAt;
  const RemoteCatalogueEntry({
    required this.key,
    required this.jsonBlob,
    this.etag,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json_blob'] = Variable<String>(jsonBlob);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  RemoteCatalogueCacheCompanion toCompanion(bool nullToAbsent) {
    return RemoteCatalogueCacheCompanion(
      key: Value(key),
      jsonBlob: Value(jsonBlob),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory RemoteCatalogueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteCatalogueEntry(
      key: serializer.fromJson<String>(json['key']),
      jsonBlob: serializer.fromJson<String>(json['jsonBlob']),
      etag: serializer.fromJson<String?>(json['etag']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'jsonBlob': serializer.toJson<String>(jsonBlob),
      'etag': serializer.toJson<String?>(etag),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  RemoteCatalogueEntry copyWith({
    String? key,
    String? jsonBlob,
    Value<String?> etag = const Value.absent(),
    DateTime? fetchedAt,
  }) => RemoteCatalogueEntry(
    key: key ?? this.key,
    jsonBlob: jsonBlob ?? this.jsonBlob,
    etag: etag.present ? etag.value : this.etag,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  RemoteCatalogueEntry copyWithCompanion(RemoteCatalogueCacheCompanion data) {
    return RemoteCatalogueEntry(
      key: data.key.present ? data.key.value : this.key,
      jsonBlob: data.jsonBlob.present ? data.jsonBlob.value : this.jsonBlob,
      etag: data.etag.present ? data.etag.value : this.etag,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCatalogueEntry(')
          ..write('key: $key, ')
          ..write('jsonBlob: $jsonBlob, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, jsonBlob, etag, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteCatalogueEntry &&
          other.key == this.key &&
          other.jsonBlob == this.jsonBlob &&
          other.etag == this.etag &&
          other.fetchedAt == this.fetchedAt);
}

class RemoteCatalogueCacheCompanion
    extends UpdateCompanion<RemoteCatalogueEntry> {
  final Value<String> key;
  final Value<String> jsonBlob;
  final Value<String?> etag;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const RemoteCatalogueCacheCompanion({
    this.key = const Value.absent(),
    this.jsonBlob = const Value.absent(),
    this.etag = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteCatalogueCacheCompanion.insert({
    required String key,
    required String jsonBlob,
    this.etag = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       jsonBlob = Value(jsonBlob),
       fetchedAt = Value(fetchedAt);
  static Insertable<RemoteCatalogueEntry> custom({
    Expression<String>? key,
    Expression<String>? jsonBlob,
    Expression<String>? etag,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (jsonBlob != null) 'json_blob': jsonBlob,
      if (etag != null) 'etag': etag,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteCatalogueCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? jsonBlob,
    Value<String?>? etag,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return RemoteCatalogueCacheCompanion(
      key: key ?? this.key,
      jsonBlob: jsonBlob ?? this.jsonBlob,
      etag: etag ?? this.etag,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (jsonBlob.present) {
      map['json_blob'] = Variable<String>(jsonBlob.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteCatalogueCacheCompanion(')
          ..write('key: $key, ')
          ..write('jsonBlob: $jsonBlob, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadHistoryTable extends DownloadHistory
    with TableInfo<$DownloadHistoryTable, DownloadRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesTotalMeta = const VerificationMeta(
    'bytesTotal',
  );
  @override
  late final GeneratedColumn<int> bytesTotal = GeneratedColumn<int>(
    'bytes_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bytesDoneMeta = const VerificationMeta(
    'bytesDone',
  );
  @override
  late final GeneratedColumn<int> bytesDone = GeneratedColumn<int>(
    'bytes_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('file'),
  );
  static const VerificationMeta _pageUrlMeta = const VerificationMeta(
    'pageUrl',
  );
  @override
  late final GeneratedColumn<String> pageUrl = GeneratedColumn<String>(
    'page_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsAddedMeta = const VerificationMeta(
    'itemsAdded',
  );
  @override
  late final GeneratedColumn<int> itemsAdded = GeneratedColumn<int>(
    'items_added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    title,
    sourceUrl,
    localPath,
    status,
    bytesTotal,
    bytesDone,
    startedAt,
    completedAt,
    error,
    kind,
    pageUrl,
    headersJson,
    itemsAdded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('bytes_total')) {
      context.handle(
        _bytesTotalMeta,
        bytesTotal.isAcceptableOrUnknown(data['bytes_total']!, _bytesTotalMeta),
      );
    }
    if (data.containsKey('bytes_done')) {
      context.handle(
        _bytesDoneMeta,
        bytesDone.isAcceptableOrUnknown(data['bytes_done']!, _bytesDoneMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('page_url')) {
      context.handle(
        _pageUrlMeta,
        pageUrl.isAcceptableOrUnknown(data['page_url']!, _pageUrlMeta),
      );
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('items_added')) {
      context.handle(
        _itemsAddedMeta,
        itemsAdded.isAcceptableOrUnknown(data['items_added']!, _itemsAddedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      bytesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_total'],
      )!,
      bytesDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_done'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      pageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_url'],
      ),
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      ),
      itemsAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}items_added'],
      )!,
    );
  }

  @override
  $DownloadHistoryTable createAlias(String alias) {
    return $DownloadHistoryTable(attachedDatabase, alias);
  }
}

class DownloadRecord extends DataClass implements Insertable<DownloadRecord> {
  final int id;
  final String siteId;
  final String title;
  final String sourceUrl;
  final String? localPath;

  /// 'queued' | 'running' | 'paused' | 'done' | 'failed'
  final String status;
  final int bytesTotal;
  final int bytesDone;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? error;

  /// 'file' (direct link / browse mode) | 'album' (listing mode: the zip URL
  /// is re-fetched from [pageUrl] right before each attempt, since it expires).
  final String kind;

  /// Album page (listing mode) or the page a browse-mode download came from.
  final String? pageUrl;

  /// Request headers needed to repeat the download (cookies, referer, UA).
  final String? headersJson;

  /// Songs added to the library by this download (AP §5.8 "Added 12 songs").
  final int itemsAdded;
  const DownloadRecord({
    required this.id,
    required this.siteId,
    required this.title,
    required this.sourceUrl,
    this.localPath,
    required this.status,
    required this.bytesTotal,
    required this.bytesDone,
    required this.startedAt,
    this.completedAt,
    this.error,
    required this.kind,
    this.pageUrl,
    this.headersJson,
    required this.itemsAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<String>(siteId);
    map['title'] = Variable<String>(title);
    map['source_url'] = Variable<String>(sourceUrl);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['status'] = Variable<String>(status);
    map['bytes_total'] = Variable<int>(bytesTotal);
    map['bytes_done'] = Variable<int>(bytesDone);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || pageUrl != null) {
      map['page_url'] = Variable<String>(pageUrl);
    }
    if (!nullToAbsent || headersJson != null) {
      map['headers_json'] = Variable<String>(headersJson);
    }
    map['items_added'] = Variable<int>(itemsAdded);
    return map;
  }

  DownloadHistoryCompanion toCompanion(bool nullToAbsent) {
    return DownloadHistoryCompanion(
      id: Value(id),
      siteId: Value(siteId),
      title: Value(title),
      sourceUrl: Value(sourceUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      status: Value(status),
      bytesTotal: Value(bytesTotal),
      bytesDone: Value(bytesDone),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      kind: Value(kind),
      pageUrl: pageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pageUrl),
      headersJson: headersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(headersJson),
      itemsAdded: Value(itemsAdded),
    );
  }

  factory DownloadRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRecord(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      title: serializer.fromJson<String>(json['title']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      status: serializer.fromJson<String>(json['status']),
      bytesTotal: serializer.fromJson<int>(json['bytesTotal']),
      bytesDone: serializer.fromJson<int>(json['bytesDone']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      error: serializer.fromJson<String?>(json['error']),
      kind: serializer.fromJson<String>(json['kind']),
      pageUrl: serializer.fromJson<String?>(json['pageUrl']),
      headersJson: serializer.fromJson<String?>(json['headersJson']),
      itemsAdded: serializer.fromJson<int>(json['itemsAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<String>(siteId),
      'title': serializer.toJson<String>(title),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'status': serializer.toJson<String>(status),
      'bytesTotal': serializer.toJson<int>(bytesTotal),
      'bytesDone': serializer.toJson<int>(bytesDone),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'error': serializer.toJson<String?>(error),
      'kind': serializer.toJson<String>(kind),
      'pageUrl': serializer.toJson<String?>(pageUrl),
      'headersJson': serializer.toJson<String?>(headersJson),
      'itemsAdded': serializer.toJson<int>(itemsAdded),
    };
  }

  DownloadRecord copyWith({
    int? id,
    String? siteId,
    String? title,
    String? sourceUrl,
    Value<String?> localPath = const Value.absent(),
    String? status,
    int? bytesTotal,
    int? bytesDone,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> error = const Value.absent(),
    String? kind,
    Value<String?> pageUrl = const Value.absent(),
    Value<String?> headersJson = const Value.absent(),
    int? itemsAdded,
  }) => DownloadRecord(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    title: title ?? this.title,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    localPath: localPath.present ? localPath.value : this.localPath,
    status: status ?? this.status,
    bytesTotal: bytesTotal ?? this.bytesTotal,
    bytesDone: bytesDone ?? this.bytesDone,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    error: error.present ? error.value : this.error,
    kind: kind ?? this.kind,
    pageUrl: pageUrl.present ? pageUrl.value : this.pageUrl,
    headersJson: headersJson.present ? headersJson.value : this.headersJson,
    itemsAdded: itemsAdded ?? this.itemsAdded,
  );
  DownloadRecord copyWithCompanion(DownloadHistoryCompanion data) {
    return DownloadRecord(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      title: data.title.present ? data.title.value : this.title,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      status: data.status.present ? data.status.value : this.status,
      bytesTotal: data.bytesTotal.present
          ? data.bytesTotal.value
          : this.bytesTotal,
      bytesDone: data.bytesDone.present ? data.bytesDone.value : this.bytesDone,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      error: data.error.present ? data.error.value : this.error,
      kind: data.kind.present ? data.kind.value : this.kind,
      pageUrl: data.pageUrl.present ? data.pageUrl.value : this.pageUrl,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      itemsAdded: data.itemsAdded.present
          ? data.itemsAdded.value
          : this.itemsAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRecord(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('title: $title, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('status: $status, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('bytesDone: $bytesDone, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('error: $error, ')
          ..write('kind: $kind, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('headersJson: $headersJson, ')
          ..write('itemsAdded: $itemsAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    title,
    sourceUrl,
    localPath,
    status,
    bytesTotal,
    bytesDone,
    startedAt,
    completedAt,
    error,
    kind,
    pageUrl,
    headersJson,
    itemsAdded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRecord &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.title == this.title &&
          other.sourceUrl == this.sourceUrl &&
          other.localPath == this.localPath &&
          other.status == this.status &&
          other.bytesTotal == this.bytesTotal &&
          other.bytesDone == this.bytesDone &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.error == this.error &&
          other.kind == this.kind &&
          other.pageUrl == this.pageUrl &&
          other.headersJson == this.headersJson &&
          other.itemsAdded == this.itemsAdded);
}

class DownloadHistoryCompanion extends UpdateCompanion<DownloadRecord> {
  final Value<int> id;
  final Value<String> siteId;
  final Value<String> title;
  final Value<String> sourceUrl;
  final Value<String?> localPath;
  final Value<String> status;
  final Value<int> bytesTotal;
  final Value<int> bytesDone;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> error;
  final Value<String> kind;
  final Value<String?> pageUrl;
  final Value<String?> headersJson;
  final Value<int> itemsAdded;
  const DownloadHistoryCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.title = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.status = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.bytesDone = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.error = const Value.absent(),
    this.kind = const Value.absent(),
    this.pageUrl = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.itemsAdded = const Value.absent(),
  });
  DownloadHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String siteId,
    required String title,
    required String sourceUrl,
    this.localPath = const Value.absent(),
    required String status,
    this.bytesTotal = const Value.absent(),
    this.bytesDone = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.error = const Value.absent(),
    this.kind = const Value.absent(),
    this.pageUrl = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.itemsAdded = const Value.absent(),
  }) : siteId = Value(siteId),
       title = Value(title),
       sourceUrl = Value(sourceUrl),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<DownloadRecord> custom({
    Expression<int>? id,
    Expression<String>? siteId,
    Expression<String>? title,
    Expression<String>? sourceUrl,
    Expression<String>? localPath,
    Expression<String>? status,
    Expression<int>? bytesTotal,
    Expression<int>? bytesDone,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? error,
    Expression<String>? kind,
    Expression<String>? pageUrl,
    Expression<String>? headersJson,
    Expression<int>? itemsAdded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (title != null) 'title': title,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (localPath != null) 'local_path': localPath,
      if (status != null) 'status': status,
      if (bytesTotal != null) 'bytes_total': bytesTotal,
      if (bytesDone != null) 'bytes_done': bytesDone,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (error != null) 'error': error,
      if (kind != null) 'kind': kind,
      if (pageUrl != null) 'page_url': pageUrl,
      if (headersJson != null) 'headers_json': headersJson,
      if (itemsAdded != null) 'items_added': itemsAdded,
    });
  }

  DownloadHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? siteId,
    Value<String>? title,
    Value<String>? sourceUrl,
    Value<String?>? localPath,
    Value<String>? status,
    Value<int>? bytesTotal,
    Value<int>? bytesDone,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? error,
    Value<String>? kind,
    Value<String?>? pageUrl,
    Value<String?>? headersJson,
    Value<int>? itemsAdded,
  }) {
    return DownloadHistoryCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      title: title ?? this.title,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      bytesTotal: bytesTotal ?? this.bytesTotal,
      bytesDone: bytesDone ?? this.bytesDone,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
      kind: kind ?? this.kind,
      pageUrl: pageUrl ?? this.pageUrl,
      headersJson: headersJson ?? this.headersJson,
      itemsAdded: itemsAdded ?? this.itemsAdded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bytesTotal.present) {
      map['bytes_total'] = Variable<int>(bytesTotal.value);
    }
    if (bytesDone.present) {
      map['bytes_done'] = Variable<int>(bytesDone.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (pageUrl.present) {
      map['page_url'] = Variable<String>(pageUrl.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (itemsAdded.present) {
      map['items_added'] = Variable<int>(itemsAdded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('title: $title, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('status: $status, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('bytesDone: $bytesDone, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('error: $error, ')
          ..write('kind: $kind, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('headersJson: $headersJson, ')
          ..write('itemsAdded: $itemsAdded')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $ExcludedFoldersTable excludedFolders = $ExcludedFoldersTable(
    this,
  );
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupConditionsTable groupConditions = $GroupConditionsTable(
    this,
  );
  late final $GroupStaticItemsTable groupStaticItems = $GroupStaticItemsTable(
    this,
  );
  late final $GroupRefsTable groupRefs = $GroupRefsTable(this);
  late final $GroupOverridesTable groupOverrides = $GroupOverridesTable(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  late final $QueuePointerTable queuePointer = $QueuePointerTable(this);
  late final $PlaybackStatesTable playbackStates = $PlaybackStatesTable(this);
  late final $PlayStatsTable playStats = $PlayStatsTable(this);
  late final $LyricsCacheTable lyricsCache = $LyricsCacheTable(this);
  late final $SongAudioFeaturesTableTable songAudioFeaturesTable =
      $SongAudioFeaturesTableTable(this);
  late final $RemoteCatalogueCacheTable remoteCatalogueCache =
      $RemoteCatalogueCacheTable(this);
  late final $DownloadHistoryTable downloadHistory = $DownloadHistoryTable(
    this,
  );
  late final Index idxSongsArtist = Index(
    'idx_songs_artist',
    'CREATE INDEX idx_songs_artist ON songs (artist)',
  );
  late final Index idxSongsAlbum = Index(
    'idx_songs_album',
    'CREATE INDEX idx_songs_album ON songs (album)',
  );
  late final Index idxSongsAlbumArtist = Index(
    'idx_songs_album_artist',
    'CREATE INDEX idx_songs_album_artist ON songs (album_artist)',
  );
  late final Index idxSongsGenre = Index(
    'idx_songs_genre',
    'CREATE INDEX idx_songs_genre ON songs (genre)',
  );
  late final Index idxSongsYear = Index(
    'idx_songs_year',
    'CREATE INDEX idx_songs_year ON songs (year)',
  );
  late final Index idxSongsDateAdded = Index(
    'idx_songs_date_added',
    'CREATE INDEX idx_songs_date_added ON songs (date_added)',
  );
  late final Index idxSongsFolder = Index(
    'idx_songs_folder',
    'CREATE INDEX idx_songs_folder ON songs (folder_path)',
  );
  late final Index idxSongsMediaStoreId = Index(
    'idx_songs_media_store_id',
    'CREATE INDEX idx_songs_media_store_id ON songs (media_store_id)',
  );
  late final Index idxQueueSequence = Index(
    'idx_queue_sequence',
    'CREATE INDEX idx_queue_sequence ON queue_items (sequence)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songs,
    excludedFolders,
    groups,
    groupConditions,
    groupStaticItems,
    groupRefs,
    groupOverrides,
    queueItems,
    queuePointer,
    playbackStates,
    playStats,
    lyricsCache,
    songAudioFeaturesTable,
    remoteCatalogueCache,
    downloadHistory,
    idxSongsArtist,
    idxSongsAlbum,
    idxSongsAlbumArtist,
    idxSongsGenre,
    idxSongsYear,
    idxSongsDateAdded,
    idxSongsFolder,
    idxSongsMediaStoreId,
    idxQueueSequence,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_conditions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_static_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_static_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_refs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_refs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_overrides', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_overrides', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('queue_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('play_stats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lyrics_cache', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_audio_features', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SongsTableCreateCompanionBuilder = SongsCompanion Function({
  required String id,
  required int mediaStoreId,
  required String title,
  Value<String> artist,
  Value<String> album,
  Value<String?> albumArtist,
  Value<String?> genre,
  Value<int?> year,
  Value<int?> trackNumber,
  Value<int> durationMs,
  required String filePath,
  required String contentUri,
  required String folderPath,
  Value<int> dateAdded,
  Value<int> dateModified,
  Value<int> sizeBytes,
  Value<int?> bitrate,
  Value<int?> sampleRate,
  Value<String> format,
  Value<String?> embeddedLrcPath,
  Value<int> lastSeenScanAt,
  Value<int> rowid,
});
typedef $$SongsTableUpdateCompanionBuilder = SongsCompanion Function({
  Value<String> id,
  Value<int> mediaStoreId,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String?> albumArtist,
  Value<String?> genre,
  Value<int?> year,
  Value<int?> trackNumber,
  Value<int> durationMs,
  Value<String> filePath,
  Value<String> contentUri,
  Value<String> folderPath,
  Value<int> dateAdded,
  Value<int> dateModified,
  Value<int> sizeBytes,
  Value<int?> bitrate,
  Value<int?> sampleRate,
  Value<String> format,
  Value<String?> embeddedLrcPath,
  Value<int> lastSeenScanAt,
  Value<int> rowid,
});

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, Song> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupStaticItemsTable, List<GroupStaticItem>>
  _groupStaticItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupStaticItems,
    aliasName: 'songs__id__group_static_items__song_id',
  );

  $$GroupStaticItemsTableProcessedTableManager get groupStaticItemsRefs {
    final manager = $$GroupStaticItemsTableTableManager(
      $_db,
      $_db.groupStaticItems,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupStaticItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupOverridesTable, List<GroupOverride>>
  _groupOverridesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupOverrides,
    aliasName: 'songs__id__group_overrides__song_id',
  );

  $$GroupOverridesTableProcessedTableManager get groupOverridesRefs {
    final manager = $$GroupOverridesTableTableManager(
      $_db,
      $_db.groupOverrides,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupOverridesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueueItemsTable, List<QueueItem>>
  _queueItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueItems,
    aliasName: 'songs__id__queue_items__song_id',
  );

  $$QueueItemsTableProcessedTableManager get queueItemsRefs {
    final manager = $$QueueItemsTableTableManager(
      $_db,
      $_db.queueItems,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlayStatsTable, List<PlayStat>>
  _playStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playStats,
    aliasName: 'songs__id__play_stats__song_id',
  );

  $$PlayStatsTableProcessedTableManager get playStatsRefs {
    final manager = $$PlayStatsTableTableManager(
      $_db,
      $_db.playStats,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LyricsCacheTable, List<LyricsRecord>>
  _lyricsCacheRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lyricsCache,
    aliasName: 'songs__id__lyrics_cache__song_id',
  );

  $$LyricsCacheTableProcessedTableManager get lyricsCacheRefs {
    final manager = $$LyricsCacheTableTableManager(
      $_db,
      $_db.lyricsCache,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lyricsCacheRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SongAudioFeaturesTableTable,
    List<SongAudioFeatures>
  >
  _songAudioFeaturesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.songAudioFeaturesTable,
        aliasName: 'songs__id__song_audio_features__song_id',
      );

  $$SongAudioFeaturesTableTableProcessedTableManager
  get songAudioFeaturesTableRefs {
    final manager = $$SongAudioFeaturesTableTableTableManager(
      $_db,
      $_db.songAudioFeaturesTable,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _songAudioFeaturesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaStoreId => $composableBuilder(
    column: $table.mediaStoreId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitrate => $composableBuilder(
    column: $table.bitrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embeddedLrcPath => $composableBuilder(
    column: $table.embeddedLrcPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenScanAt => $composableBuilder(
    column: $table.lastSeenScanAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupStaticItemsRefs(
    Expression<bool> Function($$GroupStaticItemsTableFilterComposer f) f,
  ) {
    final $$GroupStaticItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupStaticItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupStaticItemsTableFilterComposer(
            $db: $db,
            $table: $db.groupStaticItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupOverridesRefs(
    Expression<bool> Function($$GroupOverridesTableFilterComposer f) f,
  ) {
    final $$GroupOverridesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupOverrides,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupOverridesTableFilterComposer(
            $db: $db,
            $table: $db.groupOverrides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queueItemsRefs(
    Expression<bool> Function($$QueueItemsTableFilterComposer f) f,
  ) {
    final $$QueueItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueItemsTableFilterComposer(
            $db: $db,
            $table: $db.queueItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playStatsRefs(
    Expression<bool> Function($$PlayStatsTableFilterComposer f) f,
  ) {
    final $$PlayStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playStats,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayStatsTableFilterComposer(
            $db: $db,
            $table: $db.playStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lyricsCacheRefs(
    Expression<bool> Function($$LyricsCacheTableFilterComposer f) f,
  ) {
    final $$LyricsCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lyricsCache,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsCacheTableFilterComposer(
            $db: $db,
            $table: $db.lyricsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> songAudioFeaturesTableRefs(
    Expression<bool> Function($$SongAudioFeaturesTableTableFilterComposer f) f,
  ) {
    final $$SongAudioFeaturesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.songAudioFeaturesTable,
          getReferencedColumn: (t) => t.songId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SongAudioFeaturesTableTableFilterComposer(
                $db: $db,
                $table: $db.songAudioFeaturesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaStoreId => $composableBuilder(
    column: $table.mediaStoreId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitrate => $composableBuilder(
    column: $table.bitrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embeddedLrcPath => $composableBuilder(
    column: $table.embeddedLrcPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenScanAt => $composableBuilder(
    column: $table.lastSeenScanAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mediaStoreId => $composableBuilder(
    column: $table.mediaStoreId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get contentUri => $composableBuilder(
    column: $table.contentUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<int> get dateModified => $composableBuilder(
    column: $table.dateModified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get bitrate =>
      $composableBuilder(column: $table.bitrate, builder: (column) => column);

  GeneratedColumn<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get embeddedLrcPath => $composableBuilder(
    column: $table.embeddedLrcPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenScanAt => $composableBuilder(
    column: $table.lastSeenScanAt,
    builder: (column) => column,
  );

  Expression<T> groupStaticItemsRefs<T extends Object>(
    Expression<T> Function($$GroupStaticItemsTableAnnotationComposer a) f,
  ) {
    final $$GroupStaticItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupStaticItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupStaticItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupStaticItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupOverridesRefs<T extends Object>(
    Expression<T> Function($$GroupOverridesTableAnnotationComposer a) f,
  ) {
    final $$GroupOverridesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupOverrides,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupOverridesTableAnnotationComposer(
            $db: $db,
            $table: $db.groupOverrides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> queueItemsRefs<T extends Object>(
    Expression<T> Function($$QueueItemsTableAnnotationComposer a) f,
  ) {
    final $$QueueItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.queueItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playStatsRefs<T extends Object>(
    Expression<T> Function($$PlayStatsTableAnnotationComposer a) f,
  ) {
    final $$PlayStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playStats,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.playStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lyricsCacheRefs<T extends Object>(
    Expression<T> Function($$LyricsCacheTableAnnotationComposer a) f,
  ) {
    final $$LyricsCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lyricsCache,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.lyricsCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> songAudioFeaturesTableRefs<T extends Object>(
    Expression<T> Function($$SongAudioFeaturesTableTableAnnotationComposer a) f,
  ) {
    final $$SongAudioFeaturesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.songAudioFeaturesTable,
          getReferencedColumn: (t) => t.songId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SongAudioFeaturesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.songAudioFeaturesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          Song,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (Song, $$SongsTableReferences),
          Song,
          PrefetchHooks Function({
            bool groupStaticItemsRefs,
            bool groupOverridesRefs,
            bool queueItemsRefs,
            bool playStatsRefs,
            bool lyricsCacheRefs,
            bool songAudioFeaturesTableRefs,
          })
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> mediaStoreId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> contentUri = const Value.absent(),
                Value<String> folderPath = const Value.absent(),
                Value<int> dateAdded = const Value.absent(),
                Value<int> dateModified = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> bitrate = const Value.absent(),
                Value<int?> sampleRate = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String?> embeddedLrcPath = const Value.absent(),
                Value<int> lastSeenScanAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                mediaStoreId: mediaStoreId,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                durationMs: durationMs,
                filePath: filePath,
                contentUri: contentUri,
                folderPath: folderPath,
                dateAdded: dateAdded,
                dateModified: dateModified,
                sizeBytes: sizeBytes,
                bitrate: bitrate,
                sampleRate: sampleRate,
                format: format,
                embeddedLrcPath: embeddedLrcPath,
                lastSeenScanAt: lastSeenScanAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int mediaStoreId,
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required String filePath,
                required String contentUri,
                required String folderPath,
                Value<int> dateAdded = const Value.absent(),
                Value<int> dateModified = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> bitrate = const Value.absent(),
                Value<int?> sampleRate = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String?> embeddedLrcPath = const Value.absent(),
                Value<int> lastSeenScanAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                mediaStoreId: mediaStoreId,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                genre: genre,
                year: year,
                trackNumber: trackNumber,
                durationMs: durationMs,
                filePath: filePath,
                contentUri: contentUri,
                folderPath: folderPath,
                dateAdded: dateAdded,
                dateModified: dateModified,
                sizeBytes: sizeBytes,
                bitrate: bitrate,
                sampleRate: sampleRate,
                format: format,
                embeddedLrcPath: embeddedLrcPath,
                lastSeenScanAt: lastSeenScanAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongsTable, Song>(table),
                  $$SongsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupStaticItemsRefs = false,
                groupOverridesRefs = false,
                queueItemsRefs = false,
                playStatsRefs = false,
                lyricsCacheRefs = false,
                songAudioFeaturesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupStaticItemsRefs) db.groupStaticItems,
                    if (groupOverridesRefs) db.groupOverrides,
                    if (queueItemsRefs) db.queueItems,
                    if (playStatsRefs) db.playStats,
                    if (lyricsCacheRefs) db.lyricsCache,
                    if (songAudioFeaturesTableRefs) db.songAudioFeaturesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupStaticItemsRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          GroupStaticItem
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._groupStaticItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupStaticItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupOverridesRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          GroupOverride
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._groupOverridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupOverridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (queueItemsRefs)
                        await $_getPrefetchedData<Song, $SongsTable, QueueItem>(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._queueItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).queueItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playStatsRefs)
                        await $_getPrefetchedData<Song, $SongsTable, PlayStat>(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._playStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).playStatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lyricsCacheRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          LyricsRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._lyricsCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).lyricsCacheRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (songAudioFeaturesTableRefs)
                        await $_getPrefetchedData<
                          Song,
                          $SongsTable,
                          SongAudioFeatures
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._songAudioFeaturesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).songAudioFeaturesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      Song,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (Song, $$SongsTableReferences),
      Song,
      PrefetchHooks Function({
        bool groupStaticItemsRefs,
        bool groupOverridesRefs,
        bool queueItemsRefs,
        bool playStatsRefs,
        bool lyricsCacheRefs,
        bool songAudioFeaturesTableRefs,
      })
    >;
typedef $$ExcludedFoldersTableCreateCompanionBuilder =
    ExcludedFoldersCompanion Function({
      Value<int> id,
      required String folderPath,
    });
typedef $$ExcludedFoldersTableUpdateCompanionBuilder =
    ExcludedFoldersCompanion Function({
      Value<int> id,
      Value<String> folderPath,
    });

class $$ExcludedFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $ExcludedFoldersTable> {
  $$ExcludedFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExcludedFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $ExcludedFoldersTable> {
  $$ExcludedFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExcludedFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExcludedFoldersTable> {
  $$ExcludedFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get folderPath => $composableBuilder(
    column: $table.folderPath,
    builder: (column) => column,
  );
}

class $$ExcludedFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExcludedFoldersTable,
          ExcludedFolder,
          $$ExcludedFoldersTableFilterComposer,
          $$ExcludedFoldersTableOrderingComposer,
          $$ExcludedFoldersTableAnnotationComposer,
          $$ExcludedFoldersTableCreateCompanionBuilder,
          $$ExcludedFoldersTableUpdateCompanionBuilder,
          (
            ExcludedFolder,
            BaseReferences<
              _$AppDatabase,
              $ExcludedFoldersTable,
              ExcludedFolder
            >,
          ),
          ExcludedFolder,
          PrefetchHooks Function()
        > {
  $$ExcludedFoldersTableTableManager(
    _$AppDatabase db,
    $ExcludedFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExcludedFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExcludedFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExcludedFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> folderPath = const Value.absent(),
          }) => ExcludedFoldersCompanion(id: id, folderPath: folderPath),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String folderPath,
          }) => ExcludedFoldersCompanion.insert(id: id, folderPath: folderPath),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExcludedFoldersTable, ExcludedFolder>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ExcludedFoldersTable,
                    ExcludedFolder
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExcludedFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExcludedFoldersTable,
      ExcludedFolder,
      $$ExcludedFoldersTableFilterComposer,
      $$ExcludedFoldersTableOrderingComposer,
      $$ExcludedFoldersTableAnnotationComposer,
      $$ExcludedFoldersTableCreateCompanionBuilder,
      $$ExcludedFoldersTableUpdateCompanionBuilder,
      (
        ExcludedFolder,
        BaseReferences<_$AppDatabase, $ExcludedFoldersTable, ExcludedFolder>,
      ),
      ExcludedFolder,
      PrefetchHooks Function()
    >;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  required String name,
  required String type,
  Value<String?> coverUri,
  Value<String> defaultSort,
  Value<bool> defaultSortAscending,
  Value<String> defaultPlayMode,
  Value<String> matchMode,
  Value<String?> builtinKey,
  Value<bool> isBuiltin,
  Value<bool> isHidden,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<String?> coverUri,
  Value<String> defaultSort,
  Value<bool> defaultSortAscending,
  Value<String> defaultPlayMode,
  Value<String> matchMode,
  Value<String?> builtinKey,
  Value<bool> isBuiltin,
  Value<bool> isHidden,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, SongGroup> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupConditionsTable, List<GroupCondition>>
  _groupConditionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupConditions,
    aliasName: 'groups__id__group_conditions__group_id',
  );

  $$GroupConditionsTableProcessedTableManager get groupConditionsRefs {
    final manager = $$GroupConditionsTableTableManager(
      $_db,
      $_db.groupConditions,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupConditionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupStaticItemsTable, List<GroupStaticItem>>
  _groupStaticItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupStaticItems,
    aliasName: 'groups__id__group_static_items__group_id',
  );

  $$GroupStaticItemsTableProcessedTableManager get groupStaticItemsRefs {
    final manager = $$GroupStaticItemsTableTableManager(
      $_db,
      $_db.groupStaticItems,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupStaticItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupRefsTable, List<GroupRef>>
  _groupRefsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupRefs,
    aliasName: 'groups__id__group_refs__group_id',
  );

  $$GroupRefsTableProcessedTableManager get groupRefsRefs {
    final manager = $$GroupRefsTableTableManager(
      $_db,
      $_db.groupRefs,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupRefsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupRefsTable, List<GroupRef>>
  _referencedByGroupRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupRefs,
        aliasName: 'groups__id__group_refs__ref_group_id',
      );

  $$GroupRefsTableProcessedTableManager get referencedByGroupRefs {
    final manager = $$GroupRefsTableTableManager(
      $_db,
      $_db.groupRefs,
    ).filter((f) => f.refGroupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _referencedByGroupRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroupOverridesTable, List<GroupOverride>>
  _groupOverridesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupOverrides,
    aliasName: 'groups__id__group_overrides__group_id',
  );

  $$GroupOverridesTableProcessedTableManager get groupOverridesRefs {
    final manager = $$GroupOverridesTableTableManager(
      $_db,
      $_db.groupOverrides,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupOverridesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUri => $composableBuilder(
    column: $table.coverUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSort => $composableBuilder(
    column: $table.defaultSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get defaultSortAscending => $composableBuilder(
    column: $table.defaultSortAscending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultPlayMode => $composableBuilder(
    column: $table.defaultPlayMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchMode => $composableBuilder(
    column: $table.matchMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get builtinKey => $composableBuilder(
    column: $table.builtinKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupConditionsRefs(
    Expression<bool> Function($$GroupConditionsTableFilterComposer f) f,
  ) {
    final $$GroupConditionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConditions,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConditionsTableFilterComposer(
            $db: $db,
            $table: $db.groupConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupStaticItemsRefs(
    Expression<bool> Function($$GroupStaticItemsTableFilterComposer f) f,
  ) {
    final $$GroupStaticItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupStaticItems,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupStaticItemsTableFilterComposer(
            $db: $db,
            $table: $db.groupStaticItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupRefsRefs(
    Expression<bool> Function($$GroupRefsTableFilterComposer f) f,
  ) {
    final $$GroupRefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupRefs,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupRefsTableFilterComposer(
            $db: $db,
            $table: $db.groupRefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> referencedByGroupRefs(
    Expression<bool> Function($$GroupRefsTableFilterComposer f) f,
  ) {
    final $$GroupRefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupRefs,
      getReferencedColumn: (t) => t.refGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupRefsTableFilterComposer(
            $db: $db,
            $table: $db.groupRefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groupOverridesRefs(
    Expression<bool> Function($$GroupOverridesTableFilterComposer f) f,
  ) {
    final $$GroupOverridesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupOverrides,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupOverridesTableFilterComposer(
            $db: $db,
            $table: $db.groupOverrides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUri => $composableBuilder(
    column: $table.coverUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSort => $composableBuilder(
    column: $table.defaultSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get defaultSortAscending => $composableBuilder(
    column: $table.defaultSortAscending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultPlayMode => $composableBuilder(
    column: $table.defaultPlayMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchMode => $composableBuilder(
    column: $table.matchMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get builtinKey => $composableBuilder(
    column: $table.builtinKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get coverUri =>
      $composableBuilder(column: $table.coverUri, builder: (column) => column);

  GeneratedColumn<String> get defaultSort => $composableBuilder(
    column: $table.defaultSort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get defaultSortAscending => $composableBuilder(
    column: $table.defaultSortAscending,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultPlayMode => $composableBuilder(
    column: $table.defaultPlayMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchMode =>
      $composableBuilder(column: $table.matchMode, builder: (column) => column);

  GeneratedColumn<String> get builtinKey => $composableBuilder(
    column: $table.builtinKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> groupConditionsRefs<T extends Object>(
    Expression<T> Function($$GroupConditionsTableAnnotationComposer a) f,
  ) {
    final $$GroupConditionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupConditions,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupConditionsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupStaticItemsRefs<T extends Object>(
    Expression<T> Function($$GroupStaticItemsTableAnnotationComposer a) f,
  ) {
    final $$GroupStaticItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupStaticItems,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupStaticItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupStaticItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupRefsRefs<T extends Object>(
    Expression<T> Function($$GroupRefsTableAnnotationComposer a) f,
  ) {
    final $$GroupRefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupRefs,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupRefsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupRefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> referencedByGroupRefs<T extends Object>(
    Expression<T> Function($$GroupRefsTableAnnotationComposer a) f,
  ) {
    final $$GroupRefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupRefs,
      getReferencedColumn: (t) => t.refGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupRefsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupRefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> groupOverridesRefs<T extends Object>(
    Expression<T> Function($$GroupOverridesTableAnnotationComposer a) f,
  ) {
    final $$GroupOverridesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupOverrides,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupOverridesTableAnnotationComposer(
            $db: $db,
            $table: $db.groupOverrides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          SongGroup,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (SongGroup, $$GroupsTableReferences),
          SongGroup,
          PrefetchHooks Function({
            bool groupConditionsRefs,
            bool groupStaticItemsRefs,
            bool groupRefsRefs,
            bool referencedByGroupRefs,
            bool groupOverridesRefs,
          })
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> coverUri = const Value.absent(),
                Value<String> defaultSort = const Value.absent(),
                Value<bool> defaultSortAscending = const Value.absent(),
                Value<String> defaultPlayMode = const Value.absent(),
                Value<String> matchMode = const Value.absent(),
                Value<String?> builtinKey = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                name: name,
                type: type,
                coverUri: coverUri,
                defaultSort: defaultSort,
                defaultSortAscending: defaultSortAscending,
                defaultPlayMode: defaultPlayMode,
                matchMode: matchMode,
                builtinKey: builtinKey,
                isBuiltin: isBuiltin,
                isHidden: isHidden,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<String?> coverUri = const Value.absent(),
                Value<String> defaultSort = const Value.absent(),
                Value<bool> defaultSortAscending = const Value.absent(),
                Value<String> defaultPlayMode = const Value.absent(),
                Value<String> matchMode = const Value.absent(),
                Value<String?> builtinKey = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => GroupsCompanion.insert(
                id: id,
                name: name,
                type: type,
                coverUri: coverUri,
                defaultSort: defaultSort,
                defaultSortAscending: defaultSortAscending,
                defaultPlayMode: defaultPlayMode,
                matchMode: matchMode,
                builtinKey: builtinKey,
                isBuiltin: isBuiltin,
                isHidden: isHidden,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupsTable, SongGroup>(table),
                  $$GroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupConditionsRefs = false,
                groupStaticItemsRefs = false,
                groupRefsRefs = false,
                referencedByGroupRefs = false,
                groupOverridesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupConditionsRefs) db.groupConditions,
                    if (groupStaticItemsRefs) db.groupStaticItems,
                    if (groupRefsRefs) db.groupRefs,
                    if (referencedByGroupRefs) db.groupRefs,
                    if (groupOverridesRefs) db.groupOverrides,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupConditionsRefs)
                        await $_getPrefetchedData<
                          SongGroup,
                          $GroupsTable,
                          GroupCondition
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupConditionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupConditionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupStaticItemsRefs)
                        await $_getPrefetchedData<
                          SongGroup,
                          $GroupsTable,
                          GroupStaticItem
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupStaticItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupStaticItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupRefsRefs)
                        await $_getPrefetchedData<
                          SongGroup,
                          $GroupsTable,
                          GroupRef
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupRefsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupRefsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (referencedByGroupRefs)
                        await $_getPrefetchedData<
                          SongGroup,
                          $GroupsTable,
                          GroupRef
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._referencedByGroupRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).referencedByGroupRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.refGroupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groupOverridesRefs)
                        await $_getPrefetchedData<
                          SongGroup,
                          $GroupsTable,
                          GroupOverride
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupOverridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupOverridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      SongGroup,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (SongGroup, $$GroupsTableReferences),
      SongGroup,
      PrefetchHooks Function({
        bool groupConditionsRefs,
        bool groupStaticItemsRefs,
        bool groupRefsRefs,
        bool referencedByGroupRefs,
        bool groupOverridesRefs,
      })
    >;
typedef $$GroupConditionsTableCreateCompanionBuilder =
    GroupConditionsCompanion Function({
      Value<int> id,
      required int groupId,
      required String field,
      required String operator,
      required String valueJson,
      Value<int> position,
    });
typedef $$GroupConditionsTableUpdateCompanionBuilder =
    GroupConditionsCompanion Function({
      Value<int> id,
      Value<int> groupId,
      Value<String> field,
      Value<String> operator,
      Value<String> valueJson,
      Value<int> position,
    });

final class $$GroupConditionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $GroupConditionsTable, GroupCondition> {
  $$GroupConditionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_conditions__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupConditionsTable> {
  $$GroupConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operator => $composableBuilder(
    column: $table.operator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupConditionsTable> {
  $$GroupConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operator => $composableBuilder(
    column: $table.operator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupConditionsTable> {
  $$GroupConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get operator =>
      $composableBuilder(column: $table.operator, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupConditionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupConditionsTable,
          GroupCondition,
          $$GroupConditionsTableFilterComposer,
          $$GroupConditionsTableOrderingComposer,
          $$GroupConditionsTableAnnotationComposer,
          $$GroupConditionsTableCreateCompanionBuilder,
          $$GroupConditionsTableUpdateCompanionBuilder,
          (GroupCondition, $$GroupConditionsTableReferences),
          GroupCondition,
          PrefetchHooks Function({bool groupId})
        > {
  $$GroupConditionsTableTableManager(
    _$AppDatabase db,
    $GroupConditionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupConditionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> operator = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => GroupConditionsCompanion(
                id: id,
                groupId: groupId,
                field: field,
                operator: operator,
                valueJson: valueJson,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int groupId,
                required String field,
                required String operator,
                required String valueJson,
                Value<int> position = const Value.absent(),
              }) => GroupConditionsCompanion.insert(
                id: id,
                groupId: groupId,
                field: field,
                operator: operator,
                valueJson: valueJson,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupConditionsTable, GroupCondition>(table),
                  $$GroupConditionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupConditionsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupConditionsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupConditionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupConditionsTable,
      GroupCondition,
      $$GroupConditionsTableFilterComposer,
      $$GroupConditionsTableOrderingComposer,
      $$GroupConditionsTableAnnotationComposer,
      $$GroupConditionsTableCreateCompanionBuilder,
      $$GroupConditionsTableUpdateCompanionBuilder,
      (GroupCondition, $$GroupConditionsTableReferences),
      GroupCondition,
      PrefetchHooks Function({bool groupId})
    >;
typedef $$GroupStaticItemsTableCreateCompanionBuilder =
    GroupStaticItemsCompanion Function({
      required int groupId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$GroupStaticItemsTableUpdateCompanionBuilder =
    GroupStaticItemsCompanion Function({
      Value<int> groupId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$GroupStaticItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $GroupStaticItemsTable, GroupStaticItem> {
  $$GroupStaticItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_static_items__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('group_static_items__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupStaticItemsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupStaticItemsTable> {
  $$GroupStaticItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupStaticItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupStaticItemsTable> {
  $$GroupStaticItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupStaticItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupStaticItemsTable> {
  $$GroupStaticItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupStaticItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupStaticItemsTable,
          GroupStaticItem,
          $$GroupStaticItemsTableFilterComposer,
          $$GroupStaticItemsTableOrderingComposer,
          $$GroupStaticItemsTableAnnotationComposer,
          $$GroupStaticItemsTableCreateCompanionBuilder,
          $$GroupStaticItemsTableUpdateCompanionBuilder,
          (GroupStaticItem, $$GroupStaticItemsTableReferences),
          GroupStaticItem,
          PrefetchHooks Function({bool groupId, bool songId})
        > {
  $$GroupStaticItemsTableTableManager(
    _$AppDatabase db,
    $GroupStaticItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupStaticItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupStaticItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupStaticItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupStaticItemsCompanion(
                groupId: groupId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => GroupStaticItemsCompanion.insert(
                groupId: groupId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupStaticItemsTable, GroupStaticItem>(table),
                  $$GroupStaticItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupStaticItemsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupStaticItemsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$GroupStaticItemsTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$GroupStaticItemsTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupStaticItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupStaticItemsTable,
      GroupStaticItem,
      $$GroupStaticItemsTableFilterComposer,
      $$GroupStaticItemsTableOrderingComposer,
      $$GroupStaticItemsTableAnnotationComposer,
      $$GroupStaticItemsTableCreateCompanionBuilder,
      $$GroupStaticItemsTableUpdateCompanionBuilder,
      (GroupStaticItem, $$GroupStaticItemsTableReferences),
      GroupStaticItem,
      PrefetchHooks Function({bool groupId, bool songId})
    >;
typedef $$GroupRefsTableCreateCompanionBuilder = GroupRefsCompanion Function({
  required int groupId,
  required int refGroupId,
  required String kind,
  Value<int> rowid,
});
typedef $$GroupRefsTableUpdateCompanionBuilder = GroupRefsCompanion Function({
  Value<int> groupId,
  Value<int> refGroupId,
  Value<String> kind,
  Value<int> rowid,
});

final class $$GroupRefsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupRefsTable, GroupRef> {
  $$GroupRefsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_refs__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupsTable _refGroupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_refs__ref_group_id__groups__id');

  $$GroupsTableProcessedTableManager get refGroupId {
    final $_column = $_itemColumn<int>('ref_group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_refGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupRefsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupRefsTable> {
  $$GroupRefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableFilterComposer get refGroupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refGroupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupRefsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupRefsTable> {
  $$GroupRefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableOrderingComposer get refGroupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refGroupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupRefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupRefsTable> {
  $$GroupRefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableAnnotationComposer get refGroupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refGroupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupRefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupRefsTable,
          GroupRef,
          $$GroupRefsTableFilterComposer,
          $$GroupRefsTableOrderingComposer,
          $$GroupRefsTableAnnotationComposer,
          $$GroupRefsTableCreateCompanionBuilder,
          $$GroupRefsTableUpdateCompanionBuilder,
          (GroupRef, $$GroupRefsTableReferences),
          GroupRef,
          PrefetchHooks Function({bool groupId, bool refGroupId})
        > {
  $$GroupRefsTableTableManager(_$AppDatabase db, $GroupRefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupRefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupRefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupRefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                Value<int> refGroupId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupRefsCompanion(
                groupId: groupId,
                refGroupId: refGroupId,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupId,
                required int refGroupId,
                required String kind,
                Value<int> rowid = const Value.absent(),
              }) => GroupRefsCompanion.insert(
                groupId: groupId,
                refGroupId: refGroupId,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupRefsTable, GroupRef>(table),
                  $$GroupRefsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, refGroupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupRefsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupRefsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (refGroupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.refGroupId,
                        referencedTable: $$GroupRefsTableReferences
                            ._refGroupIdTable(db),
                        referencedColumn: $$GroupRefsTableReferences
                            ._refGroupIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupRefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupRefsTable,
      GroupRef,
      $$GroupRefsTableFilterComposer,
      $$GroupRefsTableOrderingComposer,
      $$GroupRefsTableAnnotationComposer,
      $$GroupRefsTableCreateCompanionBuilder,
      $$GroupRefsTableUpdateCompanionBuilder,
      (GroupRef, $$GroupRefsTableReferences),
      GroupRef,
      PrefetchHooks Function({bool groupId, bool refGroupId})
    >;
typedef $$GroupOverridesTableCreateCompanionBuilder =
    GroupOverridesCompanion Function({
      required int groupId,
      required String songId,
      required String kind,
      Value<int> rowid,
    });
typedef $$GroupOverridesTableUpdateCompanionBuilder =
    GroupOverridesCompanion Function({
      Value<int> groupId,
      Value<String> songId,
      Value<String> kind,
      Value<int> rowid,
    });

final class $$GroupOverridesTableReferences
    extends BaseReferences<_$AppDatabase, $GroupOverridesTable, GroupOverride> {
  $$GroupOverridesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AppDatabase db) =>
      db.groups.createAlias('group_overrides__group_id__groups__id');

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('group_overrides__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $GroupOverridesTable> {
  $$GroupOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupOverridesTable> {
  $$GroupOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupOverridesTable> {
  $$GroupOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupOverridesTable,
          GroupOverride,
          $$GroupOverridesTableFilterComposer,
          $$GroupOverridesTableOrderingComposer,
          $$GroupOverridesTableAnnotationComposer,
          $$GroupOverridesTableCreateCompanionBuilder,
          $$GroupOverridesTableUpdateCompanionBuilder,
          (GroupOverride, $$GroupOverridesTableReferences),
          GroupOverride,
          PrefetchHooks Function({bool groupId, bool songId})
        > {
  $$GroupOverridesTableTableManager(
    _$AppDatabase db,
    $GroupOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> groupId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupOverridesCompanion(
                groupId: groupId,
                songId: songId,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int groupId,
                required String songId,
                required String kind,
                Value<int> rowid = const Value.absent(),
              }) => GroupOverridesCompanion.insert(
                groupId: groupId,
                songId: songId,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupOverridesTable, GroupOverride>(table),
                  $$GroupOverridesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$GroupOverridesTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$GroupOverridesTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$GroupOverridesTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$GroupOverridesTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroupOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupOverridesTable,
      GroupOverride,
      $$GroupOverridesTableFilterComposer,
      $$GroupOverridesTableOrderingComposer,
      $$GroupOverridesTableAnnotationComposer,
      $$GroupOverridesTableCreateCompanionBuilder,
      $$GroupOverridesTableUpdateCompanionBuilder,
      (GroupOverride, $$GroupOverridesTableReferences),
      GroupOverride,
      PrefetchHooks Function({bool groupId, bool songId})
    >;
typedef $$QueueItemsTableCreateCompanionBuilder = QueueItemsCompanion Function({
  Value<int> id,
  required double sequence,
  required String songId,
  Value<String> source,
  required DateTime addedAt,
});
typedef $$QueueItemsTableUpdateCompanionBuilder = QueueItemsCompanion Function({
  Value<int> id,
  Value<double> sequence,
  Value<String> songId,
  Value<String> source,
  Value<DateTime> addedAt,
});

final class $$QueueItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem> {
  $$QueueItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('queue_items__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueItemsTable,
          QueueItem,
          $$QueueItemsTableFilterComposer,
          $$QueueItemsTableOrderingComposer,
          $$QueueItemsTableAnnotationComposer,
          $$QueueItemsTableCreateCompanionBuilder,
          $$QueueItemsTableUpdateCompanionBuilder,
          (QueueItem, $$QueueItemsTableReferences),
          QueueItem,
          PrefetchHooks Function({bool songId})
        > {
  $$QueueItemsTableTableManager(_$AppDatabase db, $QueueItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> sequence = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => QueueItemsCompanion(
                id: id,
                sequence: sequence,
                songId: songId,
                source: source,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double sequence,
                required String songId,
                Value<String> source = const Value.absent(),
                required DateTime addedAt,
              }) => QueueItemsCompanion.insert(
                id: id,
                sequence: sequence,
                songId: songId,
                source: source,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueItemsTable, QueueItem>(table),
                  $$QueueItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$QueueItemsTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$QueueItemsTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueItemsTable,
      QueueItem,
      $$QueueItemsTableFilterComposer,
      $$QueueItemsTableOrderingComposer,
      $$QueueItemsTableAnnotationComposer,
      $$QueueItemsTableCreateCompanionBuilder,
      $$QueueItemsTableUpdateCompanionBuilder,
      (QueueItem, $$QueueItemsTableReferences),
      QueueItem,
      PrefetchHooks Function({bool songId})
    >;
typedef $$QueuePointerTableCreateCompanionBuilder =
    QueuePointerCompanion Function({
      Value<int> id,
      Value<int?> currentItemId,
      Value<String> sourceDescription,
    });
typedef $$QueuePointerTableUpdateCompanionBuilder =
    QueuePointerCompanion Function({
      Value<int> id,
      Value<int?> currentItemId,
      Value<String> sourceDescription,
    });

class $$QueuePointerTableFilterComposer
    extends Composer<_$AppDatabase, $QueuePointerTable> {
  $$QueuePointerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentItemId => $composableBuilder(
    column: $table.currentItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDescription => $composableBuilder(
    column: $table.sourceDescription,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueuePointerTableOrderingComposer
    extends Composer<_$AppDatabase, $QueuePointerTable> {
  $$QueuePointerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentItemId => $composableBuilder(
    column: $table.currentItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDescription => $composableBuilder(
    column: $table.sourceDescription,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueuePointerTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueuePointerTable> {
  $$QueuePointerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentItemId => $composableBuilder(
    column: $table.currentItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDescription => $composableBuilder(
    column: $table.sourceDescription,
    builder: (column) => column,
  );
}

class $$QueuePointerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueuePointerTable,
          QueuePointerRow,
          $$QueuePointerTableFilterComposer,
          $$QueuePointerTableOrderingComposer,
          $$QueuePointerTableAnnotationComposer,
          $$QueuePointerTableCreateCompanionBuilder,
          $$QueuePointerTableUpdateCompanionBuilder,
          (
            QueuePointerRow,
            BaseReferences<_$AppDatabase, $QueuePointerTable, QueuePointerRow>,
          ),
          QueuePointerRow,
          PrefetchHooks Function()
        > {
  $$QueuePointerTableTableManager(_$AppDatabase db, $QueuePointerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueuePointerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueuePointerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueuePointerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> currentItemId = const Value.absent(),
                Value<String> sourceDescription = const Value.absent(),
              }) => QueuePointerCompanion(
                id: id,
                currentItemId: currentItemId,
                sourceDescription: sourceDescription,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> currentItemId = const Value.absent(),
                Value<String> sourceDescription = const Value.absent(),
              }) => QueuePointerCompanion.insert(
                id: id,
                currentItemId: currentItemId,
                sourceDescription: sourceDescription,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueuePointerTable, QueuePointerRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QueuePointerTable,
                    QueuePointerRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueuePointerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueuePointerTable,
      QueuePointerRow,
      $$QueuePointerTableFilterComposer,
      $$QueuePointerTableOrderingComposer,
      $$QueuePointerTableAnnotationComposer,
      $$QueuePointerTableCreateCompanionBuilder,
      $$QueuePointerTableUpdateCompanionBuilder,
      (
        QueuePointerRow,
        BaseReferences<_$AppDatabase, $QueuePointerTable, QueuePointerRow>,
      ),
      QueuePointerRow,
      PrefetchHooks Function()
    >;
typedef $$PlaybackStatesTableCreateCompanionBuilder =
    PlaybackStatesCompanion Function({
      Value<int> id,
      Value<int> positionMs,
      Value<bool> isPlaying,
      Value<double> speed,
      Value<bool> preservePitch,
      Value<int> repeatMode,
      Value<bool> shuffleEnabled,
      Value<String> outputRoute,
      required DateTime updatedAt,
    });
typedef $$PlaybackStatesTableUpdateCompanionBuilder =
    PlaybackStatesCompanion Function({
      Value<int> id,
      Value<int> positionMs,
      Value<bool> isPlaying,
      Value<double> speed,
      Value<bool> preservePitch,
      Value<int> repeatMode,
      Value<bool> shuffleEnabled,
      Value<String> outputRoute,
      Value<DateTime> updatedAt,
    });

class $$PlaybackStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get preservePitch => $composableBuilder(
    column: $table.preservePitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputRoute => $composableBuilder(
    column: $table.outputRoute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get preservePitch => $composableBuilder(
    column: $table.preservePitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputRoute => $composableBuilder(
    column: $table.outputRoute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlaying =>
      $composableBuilder(column: $table.isPlaying, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<bool> get preservePitch => $composableBuilder(
    column: $table.preservePitch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outputRoute => $composableBuilder(
    column: $table.outputRoute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackStatesTable,
          PlaybackStateRow,
          $$PlaybackStatesTableFilterComposer,
          $$PlaybackStatesTableOrderingComposer,
          $$PlaybackStatesTableAnnotationComposer,
          $$PlaybackStatesTableCreateCompanionBuilder,
          $$PlaybackStatesTableUpdateCompanionBuilder,
          (
            PlaybackStateRow,
            BaseReferences<
              _$AppDatabase,
              $PlaybackStatesTable,
              PlaybackStateRow
            >,
          ),
          PlaybackStateRow,
          PrefetchHooks Function()
        > {
  $$PlaybackStatesTableTableManager(
    _$AppDatabase db,
    $PlaybackStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> isPlaying = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<bool> preservePitch = const Value.absent(),
                Value<int> repeatMode = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> outputRoute = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlaybackStatesCompanion(
                id: id,
                positionMs: positionMs,
                isPlaying: isPlaying,
                speed: speed,
                preservePitch: preservePitch,
                repeatMode: repeatMode,
                shuffleEnabled: shuffleEnabled,
                outputRoute: outputRoute,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<bool> isPlaying = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<bool> preservePitch = const Value.absent(),
                Value<int> repeatMode = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String> outputRoute = const Value.absent(),
                required DateTime updatedAt,
              }) => PlaybackStatesCompanion.insert(
                id: id,
                positionMs: positionMs,
                isPlaying: isPlaying,
                speed: speed,
                preservePitch: preservePitch,
                repeatMode: repeatMode,
                shuffleEnabled: shuffleEnabled,
                outputRoute: outputRoute,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaybackStatesTable, PlaybackStateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaybackStatesTable,
                    PlaybackStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackStatesTable,
      PlaybackStateRow,
      $$PlaybackStatesTableFilterComposer,
      $$PlaybackStatesTableOrderingComposer,
      $$PlaybackStatesTableAnnotationComposer,
      $$PlaybackStatesTableCreateCompanionBuilder,
      $$PlaybackStatesTableUpdateCompanionBuilder,
      (
        PlaybackStateRow,
        BaseReferences<_$AppDatabase, $PlaybackStatesTable, PlaybackStateRow>,
      ),
      PlaybackStateRow,
      PrefetchHooks Function()
    >;
typedef $$PlayStatsTableCreateCompanionBuilder = PlayStatsCompanion Function({
  required String songId,
  Value<int> playCount,
  Value<int> skipCount,
  Value<DateTime?> lastPlayedAt,
  Value<bool> favourite,
  Value<int> rowid,
});
typedef $$PlayStatsTableUpdateCompanionBuilder = PlayStatsCompanion Function({
  Value<String> songId,
  Value<int> playCount,
  Value<int> skipCount,
  Value<DateTime?> lastPlayedAt,
  Value<bool> favourite,
  Value<int> rowid,
});

final class $$PlayStatsTableReferences
    extends BaseReferences<_$AppDatabase, $PlayStatsTable, PlayStat> {
  $$PlayStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('play_stats__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayStatsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayStatsTable> {
  $$PlayStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favourite => $composableBuilder(
    column: $table.favourite,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayStatsTable> {
  $$PlayStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favourite => $composableBuilder(
    column: $table.favourite,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayStatsTable> {
  $$PlayStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favourite =>
      $composableBuilder(column: $table.favourite, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayStatsTable,
          PlayStat,
          $$PlayStatsTableFilterComposer,
          $$PlayStatsTableOrderingComposer,
          $$PlayStatsTableAnnotationComposer,
          $$PlayStatsTableCreateCompanionBuilder,
          $$PlayStatsTableUpdateCompanionBuilder,
          (PlayStat, $$PlayStatsTableReferences),
          PlayStat,
          PrefetchHooks Function({bool songId})
        > {
  $$PlayStatsTableTableManager(_$AppDatabase db, $PlayStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayStatsCompanion(
                songId: songId,
                playCount: playCount,
                skipCount: skipCount,
                lastPlayedAt: lastPlayedAt,
                favourite: favourite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                Value<int> playCount = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayStatsCompanion.insert(
                songId: songId,
                playCount: playCount,
                skipCount: skipCount,
                lastPlayedAt: lastPlayedAt,
                favourite: favourite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayStatsTable, PlayStat>(table),
                  $$PlayStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$PlayStatsTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$PlayStatsTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayStatsTable,
      PlayStat,
      $$PlayStatsTableFilterComposer,
      $$PlayStatsTableOrderingComposer,
      $$PlayStatsTableAnnotationComposer,
      $$PlayStatsTableCreateCompanionBuilder,
      $$PlayStatsTableUpdateCompanionBuilder,
      (PlayStat, $$PlayStatsTableReferences),
      PlayStat,
      PrefetchHooks Function({bool songId})
    >;
typedef $$LyricsCacheTableCreateCompanionBuilder =
    LyricsCacheCompanion Function({
      required String songId,
      required String providerId,
      Value<String?> syncedLrc,
      Value<String?> plainText,
      required String source,
      Value<int> offsetMs,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$LyricsCacheTableUpdateCompanionBuilder =
    LyricsCacheCompanion Function({
      Value<String> songId,
      Value<String> providerId,
      Value<String?> syncedLrc,
      Value<String?> plainText,
      Value<String> source,
      Value<int> offsetMs,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$LyricsCacheTableReferences
    extends BaseReferences<_$AppDatabase, $LyricsCacheTable, LyricsRecord> {
  $$LyricsCacheTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('lyrics_cache__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LyricsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LyricsCacheTable> {
  $$LyricsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedLrc => $composableBuilder(
    column: $table.syncedLrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetMs => $composableBuilder(
    column: $table.offsetMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricsCacheTable> {
  $$LyricsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedLrc => $composableBuilder(
    column: $table.syncedLrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMs => $composableBuilder(
    column: $table.offsetMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricsCacheTable> {
  $$LyricsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncedLrc =>
      $composableBuilder(column: $table.syncedLrc, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get offsetMs =>
      $composableBuilder(column: $table.offsetMs, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricsCacheTable,
          LyricsRecord,
          $$LyricsCacheTableFilterComposer,
          $$LyricsCacheTableOrderingComposer,
          $$LyricsCacheTableAnnotationComposer,
          $$LyricsCacheTableCreateCompanionBuilder,
          $$LyricsCacheTableUpdateCompanionBuilder,
          (LyricsRecord, $$LyricsCacheTableReferences),
          LyricsRecord,
          PrefetchHooks Function({bool songId})
        > {
  $$LyricsCacheTableTableManager(_$AppDatabase db, $LyricsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String?> syncedLrc = const Value.absent(),
                Value<String?> plainText = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> offsetMs = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsCacheCompanion(
                songId: songId,
                providerId: providerId,
                syncedLrc: syncedLrc,
                plainText: plainText,
                source: source,
                offsetMs: offsetMs,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required String providerId,
                Value<String?> syncedLrc = const Value.absent(),
                Value<String?> plainText = const Value.absent(),
                required String source,
                Value<int> offsetMs = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => LyricsCacheCompanion.insert(
                songId: songId,
                providerId: providerId,
                syncedLrc: syncedLrc,
                plainText: plainText,
                source: source,
                offsetMs: offsetMs,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LyricsCacheTable, LyricsRecord>(table),
                  $$LyricsCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$LyricsCacheTableReferences
                            ._songIdTable(db),
                        referencedColumn: $$LyricsCacheTableReferences
                            ._songIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LyricsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricsCacheTable,
      LyricsRecord,
      $$LyricsCacheTableFilterComposer,
      $$LyricsCacheTableOrderingComposer,
      $$LyricsCacheTableAnnotationComposer,
      $$LyricsCacheTableCreateCompanionBuilder,
      $$LyricsCacheTableUpdateCompanionBuilder,
      (LyricsRecord, $$LyricsCacheTableReferences),
      LyricsRecord,
      PrefetchHooks Function({bool songId})
    >;
typedef $$SongAudioFeaturesTableTableCreateCompanionBuilder =
    SongAudioFeaturesTableCompanion Function({
      required String songId,
      required double tempoBpm,
      required int keyIndex,
      required int keyMode,
      required double energy,
      required double acousticness,
      required double brightness,
      required double danceability,
      required Uint8List embeddingBlob,
      required String modelVersion,
      required DateTime analyzedAt,
      Value<int> rowid,
    });
typedef $$SongAudioFeaturesTableTableUpdateCompanionBuilder =
    SongAudioFeaturesTableCompanion Function({
      Value<String> songId,
      Value<double> tempoBpm,
      Value<int> keyIndex,
      Value<int> keyMode,
      Value<double> energy,
      Value<double> acousticness,
      Value<double> brightness,
      Value<double> danceability,
      Value<Uint8List> embeddingBlob,
      Value<String> modelVersion,
      Value<DateTime> analyzedAt,
      Value<int> rowid,
    });

final class $$SongAudioFeaturesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SongAudioFeaturesTableTable,
          SongAudioFeatures
        > {
  $$SongAudioFeaturesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias('song_audio_features__song_id__songs__id');

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SongAudioFeaturesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SongAudioFeaturesTableTable> {
  $$SongAudioFeaturesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get tempoBpm => $composableBuilder(
    column: $table.tempoBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyIndex => $composableBuilder(
    column: $table.keyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyMode => $composableBuilder(
    column: $table.keyMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brightness => $composableBuilder(
    column: $table.brightness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get embeddingBlob => $composableBuilder(
    column: $table.embeddingBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongAudioFeaturesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SongAudioFeaturesTableTable> {
  $$SongAudioFeaturesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get tempoBpm => $composableBuilder(
    column: $table.tempoBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyIndex => $composableBuilder(
    column: $table.keyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyMode => $composableBuilder(
    column: $table.keyMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brightness => $composableBuilder(
    column: $table.brightness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get embeddingBlob => $composableBuilder(
    column: $table.embeddingBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongAudioFeaturesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongAudioFeaturesTableTable> {
  $$SongAudioFeaturesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get tempoBpm =>
      $composableBuilder(column: $table.tempoBpm, builder: (column) => column);

  GeneratedColumn<int> get keyIndex =>
      $composableBuilder(column: $table.keyIndex, builder: (column) => column);

  GeneratedColumn<int> get keyMode =>
      $composableBuilder(column: $table.keyMode, builder: (column) => column);

  GeneratedColumn<double> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<double> get acousticness => $composableBuilder(
    column: $table.acousticness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get brightness => $composableBuilder(
    column: $table.brightness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get danceability => $composableBuilder(
    column: $table.danceability,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get embeddingBlob => $composableBuilder(
    column: $table.embeddingBlob,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongAudioFeaturesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongAudioFeaturesTableTable,
          SongAudioFeatures,
          $$SongAudioFeaturesTableTableFilterComposer,
          $$SongAudioFeaturesTableTableOrderingComposer,
          $$SongAudioFeaturesTableTableAnnotationComposer,
          $$SongAudioFeaturesTableTableCreateCompanionBuilder,
          $$SongAudioFeaturesTableTableUpdateCompanionBuilder,
          (SongAudioFeatures, $$SongAudioFeaturesTableTableReferences),
          SongAudioFeatures,
          PrefetchHooks Function({bool songId})
        > {
  $$SongAudioFeaturesTableTableTableManager(
    _$AppDatabase db,
    $SongAudioFeaturesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongAudioFeaturesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SongAudioFeaturesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SongAudioFeaturesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<double> tempoBpm = const Value.absent(),
                Value<int> keyIndex = const Value.absent(),
                Value<int> keyMode = const Value.absent(),
                Value<double> energy = const Value.absent(),
                Value<double> acousticness = const Value.absent(),
                Value<double> brightness = const Value.absent(),
                Value<double> danceability = const Value.absent(),
                Value<Uint8List> embeddingBlob = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<DateTime> analyzedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongAudioFeaturesTableCompanion(
                songId: songId,
                tempoBpm: tempoBpm,
                keyIndex: keyIndex,
                keyMode: keyMode,
                energy: energy,
                acousticness: acousticness,
                brightness: brightness,
                danceability: danceability,
                embeddingBlob: embeddingBlob,
                modelVersion: modelVersion,
                analyzedAt: analyzedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required double tempoBpm,
                required int keyIndex,
                required int keyMode,
                required double energy,
                required double acousticness,
                required double brightness,
                required double danceability,
                required Uint8List embeddingBlob,
                required String modelVersion,
                required DateTime analyzedAt,
                Value<int> rowid = const Value.absent(),
              }) => SongAudioFeaturesTableCompanion.insert(
                songId: songId,
                tempoBpm: tempoBpm,
                keyIndex: keyIndex,
                keyMode: keyMode,
                energy: energy,
                acousticness: acousticness,
                brightness: brightness,
                danceability: danceability,
                embeddingBlob: embeddingBlob,
                modelVersion: modelVersion,
                analyzedAt: analyzedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SongAudioFeaturesTableTable, SongAudioFeatures>(
                    table,
                  ),
                  $$SongAudioFeaturesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.songId,
                        referencedTable: $$SongAudioFeaturesTableTableReferences
                            ._songIdTable(db),
                        referencedColumn:
                            $$SongAudioFeaturesTableTableReferences
                                ._songIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SongAudioFeaturesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongAudioFeaturesTableTable,
      SongAudioFeatures,
      $$SongAudioFeaturesTableTableFilterComposer,
      $$SongAudioFeaturesTableTableOrderingComposer,
      $$SongAudioFeaturesTableTableAnnotationComposer,
      $$SongAudioFeaturesTableTableCreateCompanionBuilder,
      $$SongAudioFeaturesTableTableUpdateCompanionBuilder,
      (SongAudioFeatures, $$SongAudioFeaturesTableTableReferences),
      SongAudioFeatures,
      PrefetchHooks Function({bool songId})
    >;
typedef $$RemoteCatalogueCacheTableCreateCompanionBuilder =
    RemoteCatalogueCacheCompanion Function({
      required String key,
      required String jsonBlob,
      Value<String?> etag,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$RemoteCatalogueCacheTableUpdateCompanionBuilder =
    RemoteCatalogueCacheCompanion Function({
      Value<String> key,
      Value<String> jsonBlob,
      Value<String?> etag,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$RemoteCatalogueCacheTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteCatalogueCacheTable> {
  $$RemoteCatalogueCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonBlob => $composableBuilder(
    column: $table.jsonBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemoteCatalogueCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteCatalogueCacheTable> {
  $$RemoteCatalogueCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonBlob => $composableBuilder(
    column: $table.jsonBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemoteCatalogueCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteCatalogueCacheTable> {
  $$RemoteCatalogueCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get jsonBlob =>
      $composableBuilder(column: $table.jsonBlob, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$RemoteCatalogueCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemoteCatalogueCacheTable,
          RemoteCatalogueEntry,
          $$RemoteCatalogueCacheTableFilterComposer,
          $$RemoteCatalogueCacheTableOrderingComposer,
          $$RemoteCatalogueCacheTableAnnotationComposer,
          $$RemoteCatalogueCacheTableCreateCompanionBuilder,
          $$RemoteCatalogueCacheTableUpdateCompanionBuilder,
          (
            RemoteCatalogueEntry,
            BaseReferences<
              _$AppDatabase,
              $RemoteCatalogueCacheTable,
              RemoteCatalogueEntry
            >,
          ),
          RemoteCatalogueEntry,
          PrefetchHooks Function()
        > {
  $$RemoteCatalogueCacheTableTableManager(
    _$AppDatabase db,
    $RemoteCatalogueCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteCatalogueCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteCatalogueCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RemoteCatalogueCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> jsonBlob = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteCatalogueCacheCompanion(
                key: key,
                jsonBlob: jsonBlob,
                etag: etag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String jsonBlob,
                Value<String?> etag = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemoteCatalogueCacheCompanion.insert(
                key: key,
                jsonBlob: jsonBlob,
                etag: etag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemoteCatalogueCacheTable, RemoteCatalogueEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RemoteCatalogueCacheTable,
                    RemoteCatalogueEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemoteCatalogueCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemoteCatalogueCacheTable,
      RemoteCatalogueEntry,
      $$RemoteCatalogueCacheTableFilterComposer,
      $$RemoteCatalogueCacheTableOrderingComposer,
      $$RemoteCatalogueCacheTableAnnotationComposer,
      $$RemoteCatalogueCacheTableCreateCompanionBuilder,
      $$RemoteCatalogueCacheTableUpdateCompanionBuilder,
      (
        RemoteCatalogueEntry,
        BaseReferences<
          _$AppDatabase,
          $RemoteCatalogueCacheTable,
          RemoteCatalogueEntry
        >,
      ),
      RemoteCatalogueEntry,
      PrefetchHooks Function()
    >;
typedef $$DownloadHistoryTableCreateCompanionBuilder =
    DownloadHistoryCompanion Function({
      Value<int> id,
      required String siteId,
      required String title,
      required String sourceUrl,
      Value<String?> localPath,
      required String status,
      Value<int> bytesTotal,
      Value<int> bytesDone,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<String?> error,
      Value<String> kind,
      Value<String?> pageUrl,
      Value<String?> headersJson,
      Value<int> itemsAdded,
    });
typedef $$DownloadHistoryTableUpdateCompanionBuilder =
    DownloadHistoryCompanion Function({
      Value<int> id,
      Value<String> siteId,
      Value<String> title,
      Value<String> sourceUrl,
      Value<String?> localPath,
      Value<String> status,
      Value<int> bytesTotal,
      Value<int> bytesDone,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> error,
      Value<String> kind,
      Value<String?> pageUrl,
      Value<String?> headersJson,
      Value<int> itemsAdded,
    });

class $$DownloadHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesDone => $composableBuilder(
    column: $table.bytesDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageUrl => $composableBuilder(
    column: $table.pageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemsAdded => $composableBuilder(
    column: $table.itemsAdded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesDone => $composableBuilder(
    column: $table.bytesDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageUrl => $composableBuilder(
    column: $table.pageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemsAdded => $composableBuilder(
    column: $table.itemsAdded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesDone =>
      $composableBuilder(column: $table.bytesDone, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get pageUrl =>
      $composableBuilder(column: $table.pageUrl, builder: (column) => column);

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemsAdded => $composableBuilder(
    column: $table.itemsAdded,
    builder: (column) => column,
  );
}

class $$DownloadHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadHistoryTable,
          DownloadRecord,
          $$DownloadHistoryTableFilterComposer,
          $$DownloadHistoryTableOrderingComposer,
          $$DownloadHistoryTableAnnotationComposer,
          $$DownloadHistoryTableCreateCompanionBuilder,
          $$DownloadHistoryTableUpdateCompanionBuilder,
          (
            DownloadRecord,
            BaseReferences<
              _$AppDatabase,
              $DownloadHistoryTable,
              DownloadRecord
            >,
          ),
          DownloadRecord,
          PrefetchHooks Function()
        > {
  $$DownloadHistoryTableTableManager(
    _$AppDatabase db,
    $DownloadHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> bytesTotal = const Value.absent(),
                Value<int> bytesDone = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> pageUrl = const Value.absent(),
                Value<String?> headersJson = const Value.absent(),
                Value<int> itemsAdded = const Value.absent(),
              }) => DownloadHistoryCompanion(
                id: id,
                siteId: siteId,
                title: title,
                sourceUrl: sourceUrl,
                localPath: localPath,
                status: status,
                bytesTotal: bytesTotal,
                bytesDone: bytesDone,
                startedAt: startedAt,
                completedAt: completedAt,
                error: error,
                kind: kind,
                pageUrl: pageUrl,
                headersJson: headersJson,
                itemsAdded: itemsAdded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String siteId,
                required String title,
                required String sourceUrl,
                Value<String?> localPath = const Value.absent(),
                required String status,
                Value<int> bytesTotal = const Value.absent(),
                Value<int> bytesDone = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> pageUrl = const Value.absent(),
                Value<String?> headersJson = const Value.absent(),
                Value<int> itemsAdded = const Value.absent(),
              }) => DownloadHistoryCompanion.insert(
                id: id,
                siteId: siteId,
                title: title,
                sourceUrl: sourceUrl,
                localPath: localPath,
                status: status,
                bytesTotal: bytesTotal,
                bytesDone: bytesDone,
                startedAt: startedAt,
                completedAt: completedAt,
                error: error,
                kind: kind,
                pageUrl: pageUrl,
                headersJson: headersJson,
                itemsAdded: itemsAdded,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadHistoryTable, DownloadRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DownloadHistoryTable,
                    DownloadRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadHistoryTable,
      DownloadRecord,
      $$DownloadHistoryTableFilterComposer,
      $$DownloadHistoryTableOrderingComposer,
      $$DownloadHistoryTableAnnotationComposer,
      $$DownloadHistoryTableCreateCompanionBuilder,
      $$DownloadHistoryTableUpdateCompanionBuilder,
      (
        DownloadRecord,
        BaseReferences<_$AppDatabase, $DownloadHistoryTable, DownloadRecord>,
      ),
      DownloadRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$ExcludedFoldersTableTableManager get excludedFolders =>
      $$ExcludedFoldersTableTableManager(_db, _db.excludedFolders);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupConditionsTableTableManager get groupConditions =>
      $$GroupConditionsTableTableManager(_db, _db.groupConditions);
  $$GroupStaticItemsTableTableManager get groupStaticItems =>
      $$GroupStaticItemsTableTableManager(_db, _db.groupStaticItems);
  $$GroupRefsTableTableManager get groupRefs =>
      $$GroupRefsTableTableManager(_db, _db.groupRefs);
  $$GroupOverridesTableTableManager get groupOverrides =>
      $$GroupOverridesTableTableManager(_db, _db.groupOverrides);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
  $$QueuePointerTableTableManager get queuePointer =>
      $$QueuePointerTableTableManager(_db, _db.queuePointer);
  $$PlaybackStatesTableTableManager get playbackStates =>
      $$PlaybackStatesTableTableManager(_db, _db.playbackStates);
  $$PlayStatsTableTableManager get playStats =>
      $$PlayStatsTableTableManager(_db, _db.playStats);
  $$LyricsCacheTableTableManager get lyricsCache =>
      $$LyricsCacheTableTableManager(_db, _db.lyricsCache);
  $$SongAudioFeaturesTableTableTableManager get songAudioFeaturesTable =>
      $$SongAudioFeaturesTableTableTableManager(
        _db,
        _db.songAudioFeaturesTable,
      );
  $$RemoteCatalogueCacheTableTableManager get remoteCatalogueCache =>
      $$RemoteCatalogueCacheTableTableManager(_db, _db.remoteCatalogueCache);
  $$DownloadHistoryTableTableManager get downloadHistory =>
      $$DownloadHistoryTableTableManager(_db, _db.downloadHistory);
}
