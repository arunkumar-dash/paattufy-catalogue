import 'dart:math';
import 'dart:typed_data';

import '../../../core/entities/entities.dart';
import '../../../core/settings/app_settings.dart';
import 'audio_features.dart';

/// What the scorer needs to know about a song's history.
class SongHistory {
  const SongHistory({this.playCount = 0, this.skipCount = 0, this.lastPlayedAt});
  final int playCount;
  final int skipCount;
  final DateTime? lastPlayedAt;
}

/// Features for one song; null/absent means "not yet analysed", which triggers
/// the per-candidate Metadata fallback (AP §3.7a).
class SongFeatureVector {
  const SongFeatureVector(this.heuristic, this.embedding);
  final Float32List heuristic;
  final Float32List? embedding;

  static SongFeatureVector from(AudioFeatures f) =>
      SongFeatureVector(f.heuristicVector(), f.embeddingVector());
}

class ScoredSong {
  const ScoredSong(this.song, this.score, this.usedMood);
  final Song song;
  final double score;

  /// True if Mood scoring was used for this candidate (vs Metadata fallback).
  final bool usedMood;
}

/// Suggestion scoring (TP §5.7). Pure: no I/O, fully unit-testable.
class SuggestionScorer {
  const SuggestionScorer();

  // Metadata-mode cascade weights, strongest first (AP §3.7a): artist → album
  // → album-artist → year window → genre → folder → most-played.
  static const List<double> metadataWeights = [64, 32, 16, 8, 4, 2, 1];
  static final double _metadataTotal = metadataWeights.reduce((a, b) => a + b);

  /// Songs within this many years count as the same "year window".
  static const int yearWindow = 3;

  /// Ranks candidates best-first. Already-queued songs are rejected outright
  /// (hard rule); recently played ones are penalised.
  List<ScoredSong> rank({
    required SuggestionMode mode,
    required List<Song> queue,
    required List<Song> candidates,
    required Map<String, SongFeatureVector> features,
    required Map<String, SongHistory> history,
    required DateTime now,
  }) {
    final queuedIds = {for (final s in queue) s.id};
    final centroid = mode == SuggestionMode.mood ? _centroid(queue, features) : null;
    final maxPlays = history.values.fold<int>(0, (m, h) => max(m, h.playCount));
    final queueScript = _majorityScript(queue);

    final scored = <ScoredSong>[];
    for (final c in candidates) {
      if (queuedIds.contains(c.id)) continue; // hard reject

      double base;
      var usedMood = false;
      final fv = features[c.id];
      if (centroid != null && fv != null) {
        final cos = featureSimilarity(fv.heuristic, fv.embedding, centroid.heuristic, centroid.embedding);
        base = (cos + 1) / 2; // map [-1,1] → [0,1] so it is comparable with metadata scores
        base += _moodTieBreak(c, queue, queueScript);
        usedMood = true;
      } else {
        base = _metadataScore(c, queue, history[c.id], maxPlays);
      }

      final h = history[c.id];
      final score = base * recencyFactor(h?.lastPlayedAt, now) * skipFactor(h?.skipCount ?? 0);
      scored.add(ScoredSong(c, score, usedMood));
    }
    scored.sort((a, b) {
      final d = b.score.compareTo(a.score);
      return d != 0 ? d : a.song.title.compareTo(b.song.title);
    });
    return scored;
  }

  /// `max(0.2, 1 - exp(-hoursSincePlayed / 24))`; never-played = 1.
  static double recencyFactor(DateTime? lastPlayedAt, DateTime now) {
    if (lastPlayedAt == null) return 1.0;
    final hours = now.difference(lastPlayedAt).inMinutes / 60.0;
    if (hours <= 0) return 0.2;
    return max(0.2, 1 - exp(-hours / 24));
  }

  /// Songs the user keeps skipping / dismissing drift down (floor 0.5).
  static double skipFactor(int skips) => max(0.5, 1 / (1 + 0.15 * skips));

  // --- Mood -----------------------------------------------------------------

  /// Mean feature vector of every queue song that has been analysed. The
  /// embedding block is averaged only over songs that have one.
  SongFeatureVector? _centroid(List<Song> queue, Map<String, SongFeatureVector> features) {
    final vs = [for (final s in queue) features[s.id]].whereType<SongFeatureVector>().toList();
    if (vs.isEmpty) return null;
    final heur = Float32List(AudioFeatures.heuristicDims);
    for (final v in vs) {
      for (var i = 0; i < heur.length; i++) {
        heur[i] += v.heuristic[i] / vs.length;
      }
    }
    final withEmb = vs.where((v) => v.embedding != null).toList();
    Float32List? emb;
    if (withEmb.isNotEmpty) {
      emb = Float32List(AudioFeatures.embeddingDims);
      for (final v in withEmb) {
        for (var i = 0; i < emb.length; i++) {
          emb[i] += v.embedding![i] / withEmb.length;
        }
      }
    }
    return SongFeatureVector(heur, emb);
  }

  /// A small additive bonus — a tie-breaker, never the driver (AP §11.14).
  double _moodTieBreak(Song c, List<Song> queue, String? queueScript) {
    var bonus = 0.0;
    if (queue.any((q) => _eq(q.artist, c.artist))) bonus += 0.03;
    if (queueScript != null && scriptOf('${c.title} ${c.artist}') == queueScript) bonus += 0.02;
    return bonus;
  }

  // --- Metadata -----------------------------------------------------------------

  double _metadataScore(Song c, List<Song> queue, SongHistory? h, int maxPlays) {
    if (queue.isEmpty) {
      return maxPlays == 0 ? 0 : (h?.playCount ?? 0) / maxPlays * (1 / _metadataTotal);
    }
    double frac(bool Function(Song q) test) =>
        queue.where(test).length / queue.length;

    final f = <double>[
      frac((q) => _eq(q.artist, c.artist)),
      frac((q) => _eq(q.album, c.album)),
      frac((q) => q.albumArtist != null && _eq(q.albumArtist, c.albumArtist)),
      frac((q) => q.year != null && c.year != null && (q.year! - c.year!).abs() <= yearWindow),
      frac((q) => q.genre != null && _eq(q.genre, c.genre)),
      frac((q) => q.folderPath == c.folderPath),
      maxPlays == 0 ? 0.0 : (h?.playCount ?? 0) / maxPlays,
    ];
    var total = 0.0;
    for (var i = 0; i < f.length; i++) {
      total += f[i] * metadataWeights[i];
    }
    return total / _metadataTotal;
  }

  static bool _eq(String? a, String? b) =>
      a != null && b != null && a.toLowerCase() == b.toLowerCase();

  // --- language (script) heuristic ----------------------------------------------------

  static String? _majorityScript(List<Song> queue) {
    if (queue.isEmpty) return null;
    final counts = <String, int>{};
    for (final s in queue) {
      final k = scriptOf('${s.title} ${s.artist}');
      counts[k] = (counts[k] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Unicode script of the first letter — a cheap stand-in for "language"
  /// when tags carry none (Tamil / Devanagari / … vs Latin).
  static String scriptOf(String text) {
    for (final r in text.runes) {
      if (r >= 0x0B80 && r <= 0x0BFF) return 'tamil';
      if (r >= 0x0900 && r <= 0x097F) return 'devanagari';
      if (r >= 0x0C00 && r <= 0x0C7F) return 'telugu';
      if (r >= 0x0D00 && r <= 0x0D7F) return 'malayalam';
      if (r >= 0x0C80 && r <= 0x0CFF) return 'kannada';
      if (r >= 0x0A00 && r <= 0x0A7F) return 'gurmukhi';
      if (r >= 0x4E00 && r <= 0x9FFF) return 'cjk';
      if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) return 'latin';
    }
    return 'latin';
  }
}
