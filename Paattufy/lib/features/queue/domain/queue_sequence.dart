/// Sparse-sequence arithmetic for the queue deque (TP §5.3).
///
/// Items are ordered by a REAL `sequence`; inserting between two neighbours
/// takes their midpoint, so reorder / play-next / add-to-queue never renumber
/// the whole table. [needsCompaction] flags when the gaps have shrunk near the
/// float-precision floor and a renumber is due.
class QueueSequence {
  /// Spacing used when (re)numbering and when appending to the tail.
  static const double step = 1000;

  /// Below this gap the queue should be renumbered.
  static const double minGap = 1e-6;

  /// [count] evenly spaced sequences strictly between [before] and [after].
  /// Either bound may be null (open end).
  static List<double> between(double? before, double? after, int count) {
    assert(count > 0);
    if (before == null && after == null) {
      return [for (var i = 1; i <= count; i++) i * step];
    }
    if (after == null) {
      return [for (var i = 1; i <= count; i++) before! + i * step];
    }
    if (before == null) {
      return [for (var i = count; i >= 1; i--) after - i * step];
    }
    final gap = (after - before) / (count + 1);
    return [for (var i = 1; i <= count; i++) before + gap * i];
  }

  /// True when the smallest gap in the (sorted) sequence list is too small to
  /// safely subdivide again.
  static bool needsCompaction(List<double> sortedSequences, {int pending = 1}) {
    for (var i = 1; i < sortedSequences.length; i++) {
      final gap = sortedSequences[i] - sortedSequences[i - 1];
      if (gap / (pending + 1) < minGap) return true;
    }
    return false;
  }

  /// Fresh evenly spaced numbering for [count] items.
  static List<double> renumber(int count) =>
      [for (var i = 1; i <= count; i++) i * step];
}
