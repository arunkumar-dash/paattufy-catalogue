import 'dart:async';

import 'package:dio/dio.dart';

import '../domain/lyrics_models.dart';

/// Reads values out of decoded JSON using a tiny path language: `$` (root),
/// `$.a.b`, `a.b`, and `[n]` indices. Enough for the catalogue's
/// `resultsArrayPath` / `fieldMap` (TP §7.2).
Object? readJsonPath(Object? root, String path) {
  var p = path.trim();
  if (p == r'$' || p.isEmpty) return root;
  if (p.startsWith(r'$.')) p = p.substring(2);
  if (p.startsWith(r'$')) p = p.substring(1);
  Object? cur = root;
  for (final raw in p.split('.')) {
    if (raw.isEmpty) continue;
    final m = RegExp(r'^([^\[\]]*)((?:\[\d+\])*)$').firstMatch(raw);
    if (m == null) return null;
    final key = m.group(1)!;
    if (key.isNotEmpty) {
      if (cur is Map && cur.containsKey(key)) {
        cur = cur[key];
      } else {
        return null;
      }
    }
    for (final idx in RegExp(r'\[(\d+)\]').allMatches(m.group(2)!)) {
      final i = int.parse(idx.group(1)!);
      if (cur is List && i < cur.length) {
        cur = cur[i];
      } else {
        return null;
      }
    }
  }
  return cur;
}

/// One request template from the catalogue (`search` / `fetchBest`).
class RequestSpec {
  const RequestSpec({
    required this.method,
    required this.path,
    this.queryParams = const {},
    this.resultsArrayPath = r'$',
    this.fieldMap,
  });

  final String method;
  final String path;
  final Map<String, String> queryParams;
  final String resultsArrayPath;

  /// Maps our field names (title, artist, album, durationSec, synced, plain,
  /// isInstrumental) to keys in the provider's response.
  final Map<String, String>? fieldMap;

  static RequestSpec? fromJson(Object? j) {
    if (j is! Map) return null;
    final path = j['path'];
    if (path is! String) return null;
    return RequestSpec(
      method: ((j['method'] as String?) ?? 'GET').toUpperCase(),
      path: path,
      queryParams: {
        for (final e in ((j['queryParams'] as Map?) ?? const {}).entries) '${e.key}': '${e.value}',
      },
      resultsArrayPath: (j['resultsArrayPath'] as String?) ?? r'$',
      fieldMap: (j['fieldMap'] as Map?)?.map((k, v) => MapEntry('$k', '$v')),
    );
  }
}

/// A provider described entirely by a catalogue entry — no per-provider Dart
/// class (AP §3.7, TP §5.6). When a provider dies or a better one appears, the
/// GitHub file is edited; the app needs no rebuild.
class ProviderSpec {
  const ProviderSpec({
    required this.id,
    required this.displayName,
    required this.baseUrl,
    this.userAgent = 'Paattufy/1.0 (personal-use build)',
    this.search,
    this.fetchBest,
    this.minDelayMs = 0,
  });

  final String id;
  final String displayName;
  final String baseUrl;
  final String userAgent;
  final RequestSpec? search;
  final RequestSpec? fetchBest;
  final int minDelayMs;

  static ProviderSpec? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], name = j['displayName'], base = j['baseUrl'];
    if (id is! String || base is! String) return null;
    return ProviderSpec(
      id: id,
      displayName: name is String ? name : id,
      baseUrl: base,
      userAgent: (j['userAgent'] as String?) ?? 'Paattufy/1.0 (personal-use build)',
      search: RequestSpec.fromJson(j['search']),
      fetchBest: RequestSpec.fromJson(j['fetchBest']),
      minDelayMs: ((j['rateLimit'] as Map?)?['minDelayMs'] as num?)?.toInt() ?? 0,
    );
  }

  /// LRCLIB, built in as the default (AP §11.16) — same shape as the catalogue
  /// entry so remote updates can override it field by field.
  static const lrclib = ProviderSpec(
    id: 'lrclib',
    displayName: 'LRCLIB',
    baseUrl: 'https://lrclib.net',
    userAgent: 'Paattufy/1.0 (personal-use build)',
    minDelayMs: 250,
    search: RequestSpec(
      method: 'GET',
      path: '/api/search',
      queryParams: {'q': '{query}'},
      resultsArrayPath: r'$',
      fieldMap: {
        'title': 'trackName',
        'artist': 'artistName',
        'album': 'albumName',
        'durationSec': 'duration',
        'synced': 'syncedLyrics',
        'plain': 'plainLyrics',
        'isInstrumental': 'instrumental',
      },
    ),
    fetchBest: RequestSpec(
      method: 'GET',
      path: '/api/get',
      queryParams: {
        'track_name': '{title}',
        'artist_name': '{artist}',
        'album_name': '{album}',
        'duration': '{durationSec}',
      },
    ),
  );
}

/// Interprets a [ProviderSpec] against a [Dio] client. Sequential requests are
/// throttled to the spec's `minDelayMs` (LRCLIB asks for politeness, TP §5.6).
class DeclarativeLyricsProvider implements LyricsProvider {
  DeclarativeLyricsProvider(this.spec, this._dio, {Future<void> Function(Duration)? sleep})
      : _sleep = sleep ?? Future.delayed;

  final ProviderSpec spec;
  final Dio _dio;
  final Future<void> Function(Duration) _sleep;
  DateTime? _lastRequestAt;

  @override
  String get id => spec.id;
  @override
  String get displayName => spec.displayName;

  @override
  Future<List<LyricsCandidate>> search(String query) async {
    final req = spec.search;
    if (req == null) return const [];
    final data = await _request(req, {'query': query});
    final list = readJsonPath(data, req.resultsArrayPath);
    if (list is! List) return const [];
    final map = req.fieldMap ?? spec.search?.fieldMap ?? const {};
    return [
      for (final item in list)
        if (item is Map) _toCandidate(item, map),
    ].where((c) => c.title.isNotEmpty).toList();
  }

  @override
  Future<LyricsCandidate?> fetchBest({
    required String title,
    required String artist,
    String? album,
    double? durationSec,
  }) async {
    final req = spec.fetchBest;
    if (req == null) return null;
    final data = await _request(req, {
      'title': title,
      'artist': artist,
      'album': album ?? '',
      'durationSec': durationSec == null ? '' : durationSec.round().toString(),
    });
    if (data == null) return null;
    final root = readJsonPath(data, req.resultsArrayPath);
    final item = root is List ? (root.isEmpty ? null : root.first) : root;
    if (item is! Map) return null;
    final map = req.fieldMap ?? spec.search?.fieldMap ?? const {};
    final c = _toCandidate(item, map);
    return c.title.isEmpty ? null : c;
  }

  Future<Object?> _request(RequestSpec req, Map<String, String> vars) async {
    await _throttle();
    final params = <String, String>{};
    for (final e in req.queryParams.entries) {
      var v = e.value;
      vars.forEach((name, value) => v = v.replaceAll('{$name}', value));
      if (v.trim().isNotEmpty && !RegExp(r'\{\w+\}').hasMatch(v)) params[e.key] = v;
    }
    try {
      final res = await _dio.request<Object?>(
        '${spec.baseUrl}${req.path}',
        queryParameters: params,
        options: Options(
          method: req.method,
          headers: {'User-Agent': spec.userAgent},
          responseType: ResponseType.json,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (res.statusCode != null && res.statusCode! >= 400) return null; // e.g. 404 = no match
      return res.data;
    } on DioException {
      rethrow;
    }
  }

  Future<void> _throttle() async {
    final min = Duration(milliseconds: spec.minDelayMs);
    final last = _lastRequestAt;
    if (last != null && min > Duration.zero) {
      final wait = min - DateTime.now().difference(last);
      if (wait > Duration.zero) await _sleep(wait);
    }
    _lastRequestAt = DateTime.now();
  }

  LyricsCandidate _toCandidate(Map item, Map<String, String> fm) {
    Object? field(String ours) {
      final key = fm[ours];
      return key == null ? null : readJsonPath(item, key);
    }

    String? str(Object? v) => v is String && v.isNotEmpty ? v : null;
    return LyricsCandidate(
      providerId: spec.id,
      title: str(field('title')) ?? '',
      artist: str(field('artist')) ?? '',
      album: str(field('album')),
      durationSec: (field('durationSec') as num?)?.toDouble(),
      synced: str(field('synced')),
      plain: str(field('plain')),
      isInstrumental: field('isInstrumental') == true,
    );
  }
}
