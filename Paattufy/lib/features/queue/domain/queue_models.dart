import '../../../core/entities/entities.dart';

/// A queue row joined with its song.
class QueueEntry {
  const QueueEntry(this.item, this.song);
  final QueueItem item;
  final Song song;

  int get id => item.id;
  bool get isSuggested => item.source == 'suggested';
}

/// Immutable view of the whole queue: ordered entries plus the pointer.
class QueueSnapshot {
  const QueueSnapshot({
    this.entries = const [],
    this.currentItemId,
    this.sourceDescription = '',
  });

  final List<QueueEntry> entries;
  final int? currentItemId;
  final String sourceDescription;

  static const empty = QueueSnapshot();

  int get currentIndex =>
      currentItemId == null ? -1 : entries.indexWhere((e) => e.id == currentItemId);

  QueueEntry? get current {
    final i = currentIndex;
    return i < 0 ? null : entries[i];
  }

  /// Items after the pointer — "Next up" + "Suggested" (AP §3.4, §5.7).
  List<QueueEntry> get upcoming {
    final i = currentIndex;
    return i < 0 ? entries : entries.sublist(i + 1);
  }

  int get upcomingCount => upcoming.length;
  bool get isEmpty => entries.isEmpty;
}
