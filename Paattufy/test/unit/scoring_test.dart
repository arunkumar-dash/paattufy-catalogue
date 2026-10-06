import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/suggestions/domain/audio_features.dart';
import 'package:paattufy/features/suggestions/domain/scoring.dart';

import '../support/song_factory.dart';

AudioFeatures feat({
  double tempo = 120,
  int key = 0,
  int mode = 1,
  double energy = 0.5,
  double ac = 0.5,
  double br = 0.5,
  double dance = 0.5,
  List<double>? emb,
}) =>
    AudioFeatures(
      tempoBpm: tempo,
      keyIndex: key,
      keyMode: mode,
      energy: energy,
      acousticness: ac,
      brightness: br,
      danceability: dance,
      embedding: emb == null ? null : Float32List.fromList(emb),
    );

List<double> embAround(int axis) =>
    [for (var i = 0; i < 64; i++) i == axis ? 1.0 : 0.02 * sin(i.toDouble())];

void main() {
  const scorer = SuggestionScorer();
  final now = DateTime(2026, 10, 1, 12);

  List<String> order(List<ScoredSong> r) => r.map((s) => s.song.id).toList();

  group('recency penalty: max(0.2, 1 - exp(-h/24))', () {
    test('formula values', () {
      expect(SuggestionScorer.recencyFactor(null, now), 1.0);
      expect(SuggestionScorer.recencyFactor(now, now), 0.2);
      expect(SuggestionScorer.recencyFactor(now.subtract(const Duration(hours: 24)), now),
          closeTo(1 - exp(-1), 1e-9));
      expect(SuggestionScorer.recencyFactor(now.subtract(const Duration(hours: 1)), now), 0.2,
          reason: 'floor applies for very recent plays');
      expect(SuggestionScorer.recencyFactor(now.subtract(const Duration(hours: 200)), now),
          greaterThan(0.99));
    });
  });

  test('already-queued songs are rejected outright', () {
    final q = [mkSong('a')];
    final r = scorer.rank(
      mode: SuggestionMode.metadata,
      queue: q,
      candidates: [mkSong('a'), mkSong('b')],
      features: {},
      history: {},
      now: now,
    );
    expect(order(r), ['b']);
  });

  group('Metadata mode cascade (AP §3.7a)', () {
    final seed = mkSong('seed', artist: 'Raja', album: 'Nizhal', albumArtist: 'Raja', year: 1982, genre: 'Melody', folder: '/raja');

    List<String> rankIds(List<dynamic> cands, {Map<String, SongHistory> history = const {}}) =>
        order(scorer.rank(
          mode: SuggestionMode.metadata,
          queue: [seed],
          candidates: cands.cast(),
          features: {},
          history: history,
          now: now,
        ));

    test('same artist > same album > same album-artist > year window > genre > folder', () {
      final sameArtist = mkSong('artist', artist: 'Raja', album: 'Other', folder: '/x');
      final sameAlbum = mkSong('album', artist: 'Someone', album: 'Nizhal', folder: '/x');
      final sameAlbumArtist = mkSong('albumartist', artist: 'Someone', album: 'Other', albumArtist: 'Raja', folder: '/x');
      final sameYear = mkSong('year', artist: 'Someone', album: 'Other', year: 1984, folder: '/x');
      final sameGenre = mkSong('genre', artist: 'Someone', album: 'Other', genre: 'Melody', folder: '/x');
      final sameFolder = mkSong('folder', artist: 'Someone', album: 'Other', folder: '/raja');
      final nothing = mkSong('nothing', artist: 'Someone', album: 'Other', folder: '/x');
      expect(
        rankIds([nothing, sameFolder, sameGenre, sameYear, sameAlbumArtist, sameAlbum, sameArtist]),
        ['artist', 'album', 'albumartist', 'year', 'genre', 'folder', 'nothing'],
      );
    });

    test('most-played breaks ties within the same tier', () {
      final a = mkSong('a', artist: 'Raja');
      final b = mkSong('b', artist: 'Raja');
      expect(
        rankIds([a, b], history: {
          'a': const SongHistory(playCount: 1),
          'b': const SongHistory(playCount: 9),
        }),
        ['b', 'a'],
      );
    });

    test('year window is ±3 years', () {
      final near = mkSong('near', artist: 'X', year: 1985);
      final far = mkSong('far', artist: 'X', year: 1986);
      expect(rankIds([far, near]), ['near', 'far']);
    });

    test('uses ALL queue songs, not a single seed (AP §3.4)', () {
      final queue = [
        mkSong('q1', artist: 'Raja'),
        mkSong('q2', artist: 'Raja'),
        mkSong('q3', artist: 'Rahman'),
      ];
      final raja = mkSong('c1', artist: 'Raja');
      final rahman = mkSong('c2', artist: 'Rahman');
      final r = scorer.rank(
        mode: SuggestionMode.metadata,
        queue: queue,
        candidates: [rahman, raja],
        features: {},
        history: {},
        now: now,
      );
      expect(order(r), ['c1', 'c2'], reason: '2/3 of the queue is Raja, 1/3 Rahman');
    });

    test('recently played candidates are penalised', () {
      final fresh = mkSong('fresh', artist: 'Raja');
      final justPlayed = mkSong('just', artist: 'Raja');
      expect(
        rankIds([justPlayed, fresh], history: {'just': SongHistory(lastPlayedAt: now.subtract(const Duration(minutes: 10)))}),
        ['fresh', 'just'],
      );
    });

    test('skipped songs drift down', () {
      final liked = mkSong('liked', artist: 'Raja');
      final skipped = mkSong('skipped', artist: 'Raja');
      expect(
        rankIds([skipped, liked], history: {'skipped': const SongHistory(skipCount: 6)}),
        ['liked', 'skipped'],
      );
    });
  });

  group('Mood mode (AP §3.7a)', () {
    test('ranks by closeness to the taste centroid of the WHOLE queue', () {
      // Queue = one calm song + one calm song → centroid is calm.
      final calm1 = feat(tempo: 70, energy: 0.2, ac: 0.9, br: 0.2, dance: 0.2, key: 9, mode: 0);
      final calm2 = feat(tempo: 75, energy: 0.25, ac: 0.85, br: 0.25, dance: 0.25, key: 9, mode: 0);
      final calmCand = feat(tempo: 72, energy: 0.22, ac: 0.88, br: 0.22, dance: 0.22, key: 9, mode: 0);
      final loudCand = feat(tempo: 170, energy: 0.95, ac: 0.1, br: 0.9, dance: 0.9, key: 2, mode: 1);
      final q = [mkSong('q1', artist: 'A'), mkSong('q2', artist: 'B')];
      final r = scorer.rank(
        mode: SuggestionMode.mood,
        queue: q,
        candidates: [mkSong('loud', artist: 'A'), mkSong('calm', artist: 'Z')],
        features: {
          'q1': SongFeatureVector.from(calm1),
          'q2': SongFeatureVector.from(calm2),
          'calm': SongFeatureVector.from(calmCand),
          'loud': SongFeatureVector.from(loudCand),
        },
        history: {},
        now: now,
      );
      expect(order(r), ['calm', 'loud'], reason: 'mood beats the same-artist tie-break');
      expect(r.every((s) => s.usedMood), isTrue);
    });

    test('embedding decides when heuristics are identical', () {
      final base = feat(emb: embAround(3));
      final similar = feat(emb: embAround(3));
      final different = feat(emb: embAround(40));
      final r = scorer.rank(
        mode: SuggestionMode.mood,
        queue: [mkSong('q')],
        candidates: [mkSong('diff'), mkSong('sim')],
        features: {
          'q': SongFeatureVector.from(base),
          'sim': SongFeatureVector.from(similar),
          'diff': SongFeatureVector.from(different),
        },
        history: {},
        now: now,
      );
      expect(order(r), ['sim', 'diff']);
    });

    test('candidates without features fall back to Metadata scoring individually', () {
      final q = [mkSong('q', artist: 'Raja')];
      final r = scorer.rank(
        mode: SuggestionMode.mood,
        queue: q,
        candidates: [mkSong('analysed', artist: 'Other'), mkSong('raw', artist: 'Raja')],
        features: {
          'q': SongFeatureVector.from(feat()),
          'analysed': SongFeatureVector.from(feat(tempo: 175, energy: 1, key: 6)),
        },
        history: {},
        now: now,
      );
      final raw = r.firstWhere((s) => s.song.id == 'raw');
      final analysed = r.firstWhere((s) => s.song.id == 'analysed');
      expect(raw.usedMood, isFalse);
      expect(analysed.usedMood, isTrue);
      expect(raw.score, greaterThan(analysed.score), reason: 'same artist (metadata) vs very dissimilar (mood)');
    });

    test('no analysed queue songs → whole ranking degrades to Metadata', () {
      final r = scorer.rank(
        mode: SuggestionMode.mood,
        queue: [mkSong('q', artist: 'Raja')],
        candidates: [mkSong('a', artist: 'Raja'), mkSong('b', artist: 'Other')],
        features: {'a': SongFeatureVector.from(feat()), 'b': SongFeatureVector.from(feat())},
        history: {},
        now: now,
      );
      expect(order(r), ['a', 'b']);
      expect(r.any((s) => s.usedMood), isFalse);
    });

    test('mixed embedding / no-embedding compares on heuristics only (no crash)', () {
      final r = scorer.rank(
        mode: SuggestionMode.mood,
        queue: [mkSong('q')],
        candidates: [mkSong('c')],
        features: {
          'q': SongFeatureVector.from(feat(emb: embAround(1))),
          'c': SongFeatureVector.from(feat()),
        },
        history: {},
        now: now,
      );
      expect(r.single.score, inInclusiveRange(0, 1.1));
    });
  });

  test('script heuristic recognises Tamil vs Latin', () {
    expect(SuggestionScorer.scriptOf('கனவுகள் Raja'), 'tamil');
    expect(SuggestionScorer.scriptOf('Kanavugal'), 'latin');
    expect(SuggestionScorer.scriptOf('मेघ'), 'devanagari');
  });

  test('feature (de)serialisation round-trips', () {
    final v = Float32List.fromList([0.5, -1.25, 3]);
    expect(AudioFeatures.unpackFloats(AudioFeatures.packFloats(v)), v);
    expect(AudioFeatures.unpackFloats(Uint8List(0)), isEmpty);
    final full = feat(emb: embAround(2)).fullVector();
    expect(full.length, AudioFeatures.heuristicDims + AudioFeatures.embeddingDims);
    expect(feat().fullVector().sublist(AudioFeatures.heuristicDims).every((x) => x == 0), isTrue);
  });
}
