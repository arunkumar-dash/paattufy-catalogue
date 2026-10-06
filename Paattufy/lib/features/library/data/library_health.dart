import 'dart:io';

import '../../../core/entities/entities.dart';

/// A set of songs that look like the same recording (AP §8.7).
class DuplicateGroup {
  const DuplicateGroup(this.songs, this.reason);
  final List<Song> songs;
  final String reason;
}

enum BrokenReason { zeroDuration, zeroSize, missingFile }

class BrokenFile {
  const BrokenFile(this.song, this.reason);
  final Song song;
  final BrokenReason reason;
}

/// Duplicate & broken-file detection after imports. Report-only: the library
/// is read-only, so nothing is ever deleted (AP §11.8).
class LibraryHealth {
  const LibraryHealth();

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), ' ').replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ').trim();

  /// Clusters songs whose normalised title + artist match and whose durations
  /// are within [toleranceMs]; also flags byte-identical size+duration pairs
  /// even when tags differ.
  List<DuplicateGroup> findDuplicates(List<Song> songs, {int toleranceMs = 2000}) {
    final groups = <DuplicateGroup>[];
    final claimed = <String>{};

    // 1. same title + artist, similar duration
    final byKey = <String, List<Song>>{};
    for (final s in songs) {
      final t = _norm(s.title);
      if (t.isEmpty) continue;
      byKey.putIfAbsent('$t|${_norm(s.artist)}', () => []).add(s);
    }
    for (final list in byKey.values) {
      if (list.length < 2) continue;
      for (final cluster in _clusterByDuration(list, toleranceMs)) {
        if (cluster.length > 1) {
          groups.add(DuplicateGroup(cluster, 'Same title and artist'));
          claimed.addAll(cluster.map((s) => s.id));
        }
      }
    }

    // 2. identical size + duration (renamed copies)
    final bySize = <String, List<Song>>{};
    for (final s in songs) {
      if (s.sizeBytes <= 0 || claimed.contains(s.id)) continue;
      bySize.putIfAbsent('${s.sizeBytes}|${s.durationMs}', () => []).add(s);
    }
    for (final list in bySize.values) {
      if (list.length > 1) groups.add(DuplicateGroup(list, 'Identical file size and length'));
    }
    return groups;
  }

  List<List<Song>> _clusterByDuration(List<Song> list, int tol) {
    final sorted = [...list]..sort((a, b) => a.durationMs.compareTo(b.durationMs));
    final clusters = <List<Song>>[];
    for (final s in sorted) {
      if (clusters.isNotEmpty && s.durationMs - clusters.last.last.durationMs <= tol) {
        clusters.last.add(s);
      } else {
        clusters.add([s]);
      }
    }
    return clusters;
  }

  /// Songs MediaStore lists but that can't be played: no duration, no bytes,
  /// or the file is gone. [exists] is injectable for tests.
  Future<List<BrokenFile>> findBroken(
    List<Song> songs, {
    Future<bool> Function(String path)? exists,
  }) async {
    final check = exists ?? (p) => File(p).exists();
    final out = <BrokenFile>[];
    for (final s in songs) {
      if (s.durationMs <= 0) {
        out.add(BrokenFile(s, BrokenReason.zeroDuration));
      } else if (s.sizeBytes <= 0) {
        out.add(BrokenFile(s, BrokenReason.zeroSize));
      } else if (!await check(s.filePath)) {
        out.add(BrokenFile(s, BrokenReason.missingFile));
      }
    }
    return out;
  }
}
