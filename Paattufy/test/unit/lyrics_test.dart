import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/remote/remote_catalogue.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/lyrics/data/declarative_provider.dart';
import 'package:paattufy/features/lyrics/data/lyrics_catalogue.dart';
import 'package:paattufy/features/lyrics/data/lyrics_repository.dart';
import 'package:paattufy/features/lyrics/domain/lrc.dart';
import 'package:paattufy/features/lyrics/domain/lyrics_models.dart';

import '../support/fake_http.dart';
import '../support/test_db.dart';

const lrcSample = '''
[ar:Ilaiyaraaja]
[ti:Kanavugal]
[offset:+500]
[00:12.00]First line
[00:17.50]Second line
[01:05.123]Third line
[00:30.00][00:45.25]Chorus
''';

final lrclibSearchJson = [
  {
    'id': 1,
    'trackName': 'Kanavugal',
    'artistName': 'Ilaiyaraaja',
    'albumName': 'Nizhal Nijam',
    'duration': 240.0,
    'instrumental': false,
    'plainLyrics': 'First line\nSecond line',
    'syncedLyrics': '[00:12.00]First line\n[00:17.50]Second line',
  },
  {
    'id': 2,
    'trackName': 'Kanavugal (live)',
    'artistName': 'Ilaiyaraaja',
    'albumName': 'Live',
    'duration': 301.4,
    'instrumental': false,
    'plainLyrics': 'Only plain',
    'syncedLyrics': null,
  },
];

void main() {
  group('LRC parsing', () {
    final parsed = Lrc.parse(lrcSample);

    test('timestamps, multi-tag lines and ordering', () {
      final texts = parsed.lines.map((l) => l.text).toList();
      expect(texts, ['First line', 'Second line', 'Chorus', 'Chorus', 'Third line']);
      final times = parsed.lines.map((l) => l.time).toList();
      expect([...times]..sort(), times, reason: 'sorted by time');
    });

    test('[offset:+500] makes lyrics appear 500 ms earlier (LRC spec)', () {
      expect(parsed.offsetMs, 500);
      expect(parsed.lines.first.time, const Duration(seconds: 11, milliseconds: 500));
    });

    test('metadata tags are captured', () {
      expect(parsed.tags['ar'], 'Ilaiyaraaja');
      expect(parsed.tags['ti'], 'Kanavugal');
    });

    test('fraction digit variants', () {
      final p = Lrc.parse('[00:01.5]a\n[00:02.50]b\n[00:03.500]c\n[00:04]d\n[00:05:25]e');
      expect(p.lines.map((l) => l.time.inMilliseconds), [1500, 2500, 3500, 4000, 5250]);
    });

    test('CRLF line endings, enhanced word tags, blank text, minutes > 59', () {
      final p = Lrc.parse('[62:03.00]Long\r\n[00:01.00]<00:01.00>Hel<00:01.40>lo\r\n[00:02.00]');
      expect(p.lines.first.text, 'Hello');
      expect(p.lines[1].text, '', reason: 'instrumental gap line is kept as an empty line');
      expect(p.lines.last.time, const Duration(minutes: 62, seconds: 3));
    });

    test('plain text / garbage yields no synced lines', () {
      expect(Lrc.parse('just some\nplain lyrics').isSynced, isFalse);
      expect(Lrc.parse('').lines, isEmpty);
    });

    test('negative times after offset clamp to zero', () {
      final p = Lrc.parse('[offset:5000]\n[00:01.00]x');
      expect(p.lines.single.time, Duration.zero);
    });
  });

  group('active line lookup & offset', () {
    final lines = Lrc.parse('[00:10.00]a\n[00:20.00]b\n[00:30.00]c').lines;

    test('before first line → -1; boundaries; past the end', () {
      expect(Lrc.activeIndex(lines, const Duration(seconds: 5)), -1);
      expect(Lrc.activeIndex(lines, const Duration(seconds: 10)), 0);
      expect(Lrc.activeIndex(lines, const Duration(milliseconds: 19999)), 0);
      expect(Lrc.activeIndex(lines, const Duration(seconds: 20)), 1);
      expect(Lrc.activeIndex(lines, const Duration(minutes: 9)), 2);
      expect(Lrc.activeIndex(const [], Duration.zero), -1);
    });

    test('positive offset advances the highlight, negative delays it', () {
      expect(Lrc.activeIndex(lines, const Duration(seconds: 19), offsetMs: 1200), 1);
      expect(Lrc.activeIndex(lines, const Duration(seconds: 21), offsetMs: -1200), 0);
    });

    test('tap-to-seek lands where the line is active under the nudge', () {
      for (final off in [-400, 0, 600]) {
        final t = Lrc.seekTimeFor(lines, 1, offsetMs: off);
        expect(Lrc.activeIndex(lines, t, offsetMs: off), 1);
      }
      expect(Lrc.seekTimeFor(lines, 0, offsetMs: 99999), Duration.zero);
    });
  });

  group('readJsonPath', () {
    final doc = {
      'data': {
        'items': [
          {'t': 'x', 'nested': {'k': 7}},
        ],
      },
    };
    test('root, dotted, indexed, missing', () {
      expect(readJsonPath(doc, r'$'), doc);
      expect(readJsonPath(doc, r'$.data.items[0].t'), 'x');
      expect(readJsonPath(doc, 'data.items[0].nested.k'), 7);
      expect(readJsonPath(doc, r'$.data.nope'), isNull);
      expect(readJsonPath(doc, r'$.data.items[5]'), isNull);
    });
  });

  group('DeclarativeLyricsProvider (LRCLIB shape)', () {
    late FakeHttpAdapter http;
    late DeclarativeLyricsProvider lrclib;
    final sleeps = <Duration>[];

    setUp(() {
      sleeps.clear();
      http = FakeHttpAdapter((o) {
        if (o.path.endsWith('/api/search')) return FakeResponse.json(lrclibSearchJson);
        if (o.path.endsWith('/api/get')) return FakeResponse.json(lrclibSearchJson.first);
        return const FakeResponse('nope', status: 404);
      });
      lrclib = DeclarativeLyricsProvider(ProviderSpec.lrclib, fakeDio(http), sleep: (d) async => sleeps.add(d));
    });

    test('search maps fields and sends q with the descriptive User-Agent', () async {
      final r = await lrclib.search('kanavugal raja');
      expect(r, hasLength(2));
      expect(r.first.title, 'Kanavugal');
      expect(r.first.artist, 'Ilaiyaraaja');
      expect(r.first.album, 'Nizhal Nijam');
      expect(r.first.durationSec, 240.0);
      expect(r.first.hasSynced, isTrue);
      expect(r.last.hasSynced, isFalse);
      expect(r.last.hasPlain, isTrue);
      final req = http.requests.single;
      expect(req.uri.path, '/api/search');
      expect(req.uri.queryParameters['q'], 'kanavugal raja');
      expect(req.headers['User-Agent'], 'Paattufy/1.0 (personal-use build)');
    });

    test('fetchBest substitutes all templates, rounds duration', () async {
      final c = await lrclib.fetchBest(title: 'Kanavugal', artist: 'Ilaiyaraaja', album: 'Nizhal Nijam', durationSec: 239.6);
      expect(c!.title, 'Kanavugal');
      final q = http.requests.single.uri.queryParameters;
      expect(q, {'track_name': 'Kanavugal', 'artist_name': 'Ilaiyaraaja', 'album_name': 'Nizhal Nijam', 'duration': '240'});
    });

    test('empty template values are omitted; 404 → null', () async {
      http.handler = (o) => const FakeResponse('{"code":404}', status: 404);
      final c = await lrclib.fetchBest(title: 'X', artist: 'Y');
      expect(c, isNull);
      final q = http.requests.single.uri.queryParameters;
      expect(q.containsKey('album_name'), isFalse);
      expect(q.containsKey('duration'), isFalse);
    });

    test('sequential requests are throttled to minDelayMs', () async {
      await lrclib.search('a');
      await lrclib.search('b');
      await lrclib.search('c');
      expect(sleeps, hasLength(2));
      expect(sleeps.every((d) => d > Duration.zero && d <= const Duration(milliseconds: 250)), isTrue);
    });

    test('a catalogue-declared provider with a different shape needs no new class', () async {
      final spec = ProviderSpec.fromJson({
        'id': 'other',
        'displayName': 'Other',
        'baseUrl': 'https://lyrics.example',
        'search': {
          'method': 'GET',
          'path': '/v2/find',
          'queryParams': {'term': '{query}'},
          'resultsArrayPath': r'$.data.hits',
          'fieldMap': {'title': 'song.name', 'artist': 'song.by', 'synced': 'lrc', 'durationSec': 'len'},
        },
      })!;
      final h = FakeHttpAdapter((o) => FakeResponse.json({
            'data': {
              'hits': [
                {'song': {'name': 'T', 'by': 'A'}, 'lrc': '[00:01.00]hi', 'len': 200},
              ],
            },
          }));
      final r = await DeclarativeLyricsProvider(spec, fakeDio(h)).search('t a');
      expect(r.single.title, 'T');
      expect(r.single.artist, 'A');
      expect(r.single.synced, contains('hi'));
      expect(r.single.durationSec, 200);
      expect(h.requests.single.uri.toString(), 'https://lyrics.example/v2/find?term=t+a');
    });

    test('duration match indicator', () {
      const c = LyricsCandidate(providerId: 'p', title: 't', artist: 'a', durationSec: 240);
      expect(c.durationMatch(241), DurationMatch.exact);
      expect(c.durationMatch(245), DurationMatch.close);
      expect(c.durationMatch(300), DurationMatch.far);
      expect(const LyricsCandidate(providerId: 'p', title: 't', artist: 'a').durationMatch(1), DurationMatch.unknown);
    });
  });

  group('catalogue merge (AP §3.7)', () {
    test('built-in LRCLIB is always present, remote appends, same id overrides', () {
      final merged = LyricsCatalogue.mergeProviders({
        'schemaVersion': 1,
        'providers': [
          {'id': 'lrclib', 'displayName': 'LRCLIB mirror', 'baseUrl': 'https://mirror.example'},
          {'id': 'newone', 'displayName': 'New One', 'baseUrl': 'https://new.example'},
          {'nonsense': true},
        ],
      });
      expect(merged.map((p) => p.id), ['lrclib', 'newone']);
      expect(merged.first.baseUrl, 'https://mirror.example');
    });

    test('no remote / unsupported schema → built-in only', () {
      expect(LyricsCatalogue.mergeProviders(null).map((p) => p.id), ['lrclib']);
      expect(LyricsCatalogue.mergeProviders({'schemaVersion': 99, 'providers': []}).map((p) => p.id), ['lrclib']);
    });

    test('the real published catalogue shape parses into the built-in shape', () {
      final spec = ProviderSpec.fromJson({
        'id': 'lrclib',
        'displayName': 'LRCLIB',
        'baseUrl': 'https://lrclib.net',
        'userAgent': 'Paattufy/1.0 (personal-use build)',
        'search': {
          'method': 'GET',
          'path': '/api/search',
          'queryParams': {'q': '{query}'},
          'resultsArrayPath': r'$',
          'fieldMap': {'title': 'trackName', 'artist': 'artistName', 'album': 'albumName', 'durationSec': 'duration', 'synced': 'syncedLyrics', 'plain': 'plainLyrics', 'isInstrumental': 'instrumental'},
        },
        'fetchBest': {
          'method': 'GET',
          'path': '/api/get',
          'queryParams': {'track_name': '{title}', 'artist_name': '{artist}', 'album_name': '{album}', 'duration': '{durationSec}'},
        },
        'rateLimit': {'minDelayMs': 250},
      })!;
      expect(spec.minDelayMs, 250);
      expect(spec.search!.fieldMap, ProviderSpec.lrclib.search!.fieldMap);
      expect(spec.fetchBest!.queryParams, ProviderSpec.lrclib.fetchBest!.queryParams);
    });
  });

  group('RemoteCatalogue (ETag cache)', () {
    late AppDatabase db;
    late FakeHttpAdapter http;
    late RemoteCatalogue cat;
    var now = DateTime(2026, 10, 1, 9);
    const url = 'https://raw.githubusercontent.com/x/paattufy-catalogue/main/v1/lyrics-providers.json';

    setUp(() async {
      (db, _) = await seededDb();
      now = DateTime(2026, 10, 1, 9);
      http = FakeHttpAdapter((o) {
        if (o.headers['If-None-Match'] == '"v1"') return const FakeResponse('', status: 304);
        return FakeResponse('{"schemaVersion":1,"providers":[]}', headers: {
          'etag': ['"v1"'],
        });
      });
      cat = RemoteCatalogue(db, fakeDio(http), clock: () => now);
    });
    tearDown(() => db.close());

    test('first fetch stores body + ETag; a fresh cache needs no request', () async {
      final a = await cat.get(RemoteCatalogue.lyricsKey, url);
      expect(a.json!['schemaVersion'], 1);
      expect(a.fromCache, isFalse);
      final b = await cat.get(RemoteCatalogue.lyricsKey, url);
      expect(b.fromCache, isTrue);
      expect(http.requests, hasLength(1));
    });

    test('forced refresh sends If-None-Match and a 304 costs nothing', () async {
      await cat.get(RemoteCatalogue.lyricsKey, url);
      now = now.add(const Duration(hours: 1));
      final r = await cat.get(RemoteCatalogue.lyricsKey, url, force: true);
      expect(http.requests.last.headers['If-None-Match'], '"v1"');
      expect(r.fromCache, isTrue);
      expect(r.json!['schemaVersion'], 1);
      expect(r.fetchedAt, now, reason: '304 refreshes the "last updated" timestamp');
    });

    test('stale cache triggers a refresh after maxAge', () async {
      await cat.get(RemoteCatalogue.lyricsKey, url, maxAge: const Duration(hours: 24));
      now = now.add(const Duration(hours: 25));
      await cat.get(RemoteCatalogue.lyricsKey, url, maxAge: const Duration(hours: 24));
      expect(http.requests, hasLength(2));
    });

    test('offline: last good copy is served with an error note; nothing cached → null', () async {
      final cold = await cat.get(RemoteCatalogue.lyricsKey, url);
      expect(cold.json, isNotNull);
      http.handler = (o) => null; // network gone
      now = now.add(const Duration(days: 3));
      final r = await cat.get(RemoteCatalogue.lyricsKey, url);
      expect(r.json!['schemaVersion'], 1);
      expect(r.fromCache, isTrue);
      expect(r.error, isNotNull);
      final none = await cat.get(RemoteCatalogue.downloadKey, url);
      expect(none.json, isNull);
    });

    test('invalid JSON never overwrites a good cache', () async {
      await cat.get(RemoteCatalogue.lyricsKey, url);
      http.handler = (o) => const FakeResponse('<html>oops</html>');
      final r = await cat.get(RemoteCatalogue.lyricsKey, url, force: true);
      expect(r.error, contains('valid JSON'));
      expect(r.json!['schemaVersion'], 1);
      expect((await cat.cached(RemoteCatalogue.lyricsKey)).json!['schemaVersion'], 1);
    });
  });

  group('LyricsRepository resolution', () {
    late AppDatabase db;
    late List<Song> songs;
    late LyricsRepository repo;
    late FakeLocal local;
    late List<FakeProvider> providers;
    var settings = const AppSettings();
    var now = DateTime(2026, 10, 1);

    setUp(() async {
      (db, songs) = await seededDb();
      settings = const AppSettings();
      now = DateTime(2026, 10, 1);
      local = FakeLocal();
      providers = [FakeProvider('lrclib'), FakeProvider('second')];
      repo = LyricsRepository(
        db,
        providers: () async => providers,
        settings: () => settings,
        localSources: [local],
        clock: () => now,
      );
    });
    tearDown(() => db.close());

    test('embedded/sidecar synced lyrics win — remote is never consulted', () async {
      local.data[songs[0].id] = (synced: '[00:01.00]local', plain: 'local');
      providers[0].best = const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:01.00]remote');
      final out = await repo.fetchAndCache(songs[0]);
      expect(out.resolved!.source, 'embedded');
      expect(out.resolved!.synced, contains('local'));
      expect(providers[0].fetchCalls, 0);
    });

    test('nothing local → fetch, cache forever, then serve offline', () async {
      providers[0].best = const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:01.00]remote', plain: 'remote');
      final out = await repo.fetchAndCache(songs[0]);
      expect(out.resolved!.source, 'remote');
      expect(out.resolved!.synced, contains('remote'));
      providers[0].best = null; // provider dies
      final again = await repo.resolveLocal(songs[0]);
      expect(again!.synced, contains('remote'), reason: 'served from cache, no network');
    });

    test('a local sidecar beats a previously cached remote pick', () async {
      providers[0].best = const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:01.00]remote');
      await repo.fetchAndCache(songs[0]);
      local.data[songs[0].id] = (synced: '[00:01.00]local', plain: null);
      expect((await repo.resolveLocal(songs[0]))!.source, 'embedded');
    });

    test('"try next provider on no-result" honours the setting', () async {
      providers[1].best = const LyricsCandidate(providerId: 'second', title: 't', artist: 'a', plain: 'from second');
      var out = await repo.fetchAndCache(songs[1]);
      expect(out.resolved!.providerId, 'second');
      expect(providers[0].fetchCalls, 1);

      settings = const AppSettings(tryNextLyricsProvider: false);
      out = await repo.fetchAndCache(songs[2]);
      expect(out.resolved, isNull);
      expect(providers[1].fetchCalls, 1, reason: 'second provider not tried when disabled');
    });

    test('provider order and enable/disable from settings', () async {
      settings = const AppSettings(lyricsProviderOrder: ['second', 'lrclib']);
      expect((await repo.orderedProviders()).map((p) => p.id), ['second', 'lrclib']);
      settings = const AppSettings(disabledLyricsProviders: ['second']);
      expect((await repo.orderedProviders()).map((p) => p.id), ['lrclib']);
    });

    test('a failing provider is skipped and reported, not fatal', () async {
      providers[0].throwOnFetch = true;
      providers[1].best = const LyricsCandidate(providerId: 'second', title: 't', artist: 'a', plain: 'ok');
      final out = await repo.fetchAndCache(songs[0]);
      expect(out.resolved!.providerId, 'second');
      expect(out.providerErrors.keys, ['lrclib']);
    });

    test('misses are remembered (negative cache) until the TTL expires', () async {
      await repo.fetchAndCache(songs[3]);
      expect(providers[0].fetchCalls, 1);
      await repo.fetchAndCache(songs[3]);
      expect(providers[0].fetchCalls, 1, reason: 'negative cache suppresses the retry');
      now = now.add(const Duration(days: 8));
      await repo.fetchAndCache(songs[3]);
      expect(providers[0].fetchCalls, 2);
      await repo.fetchAndCache(songs[3], ignoreNegativeCache: true);
      expect(providers[0].fetchCalls, 3);
    });

    test('picker search merges providers, synced first, survives a dead provider', () async {
      providers[0].results = [
        const LyricsCandidate(providerId: 'lrclib', title: 'plain', artist: 'a', plain: 'p'),
        const LyricsCandidate(providerId: 'lrclib', title: 'synced', artist: 'a', synced: '[00:01.00]x'),
      ];
      providers[1].throwOnSearch = true;
      final r = await repo.search('q');
      expect(r.map((c) => c.title), ['synced', 'plain']);
    });

    test('user pick is pinned to the song', () async {
      await repo.pick(
          songs[4], const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:02.00]picked'));
      final r = await repo.resolveLocal(songs[4]);
      expect(r!.synced, contains('picked'));
      expect(r.providerId, 'lrclib');
    });

    test('offset: ±200 ms steps, persisted per song, survive re-pick and cache clear', () async {
      expect(await repo.adjustOffset(songs[5], 200), 200);
      expect(await repo.adjustOffset(songs[5], 200), 400);
      expect(await repo.adjustOffset(songs[5], -600), -200);
      await repo.pick(songs[5], const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:01.00]x'));
      expect((await repo.resolveLocal(songs[5]))!.offsetMs, -200, reason: 're-pick keeps the nudge');
      await repo.clearCache();
      expect(await repo.resolveLocal(songs[5]), isNull, reason: 'cached text cleared');
      await repo.pick(songs[5], const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:01.00]x'));
      expect((await repo.resolveLocal(songs[5]))!.offsetMs, -200, reason: 'offset survived clear');
      expect(await repo.adjustOffset(songs[5], 999999), 10000, reason: 'clamped');
    });

    test('clearCache drops remote picks without offsets and reports size', () async {
      await repo.pick(songs[6], const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', plain: 'x'));
      expect(await repo.cacheSize(), 1);
      await repo.clearCache();
      expect(await repo.cacheSize(), 0);
      expect(await repo.resolveLocal(songs[6]), isNull);
    });

    test('local plain-only lyrics are a last resort, below a cached remote synced pick', () async {
      local.data[songs[7].id] = (synced: null, plain: 'plain local');
      expect((await repo.resolveLocal(songs[7]))!.plain, 'plain local');
      await repo.pick(songs[7], const LyricsCandidate(providerId: 'lrclib', title: 't', artist: 'a', synced: '[00:01.00]remote'));
      expect((await repo.resolveLocal(songs[7]))!.source, 'remote');
    });
  });
}

class FakeLocal implements LocalLyricsSource {
  final Map<String, ({String? synced, String? plain})> data = {};
  @override
  Future<({String? synced, String? plain})?> read(Song song) async => data[song.id];
}

class FakeProvider implements LyricsProvider {
  FakeProvider(this.id);
  @override
  final String id;
  @override
  String get displayName => id;
  LyricsCandidate? best;
  List<LyricsCandidate> results = [];
  int fetchCalls = 0;
  bool throwOnFetch = false;
  bool throwOnSearch = false;

  @override
  Future<LyricsCandidate?> fetchBest({required String title, required String artist, String? album, double? durationSec}) async {
    fetchCalls++;
    if (throwOnFetch) throw DioException(requestOptions: RequestOptions(path: '/'), message: 'boom');
    return best;
  }

  @override
  Future<List<LyricsCandidate>> search(String query) async {
    if (throwOnSearch) throw StateError('dead');
    return results;
  }
}
