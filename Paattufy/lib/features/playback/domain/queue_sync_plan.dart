/// Minimal edit script turning the engine's loaded queue into the desired one,
/// so queue mutations (play next, add, reorder, remove) never interrupt the
/// currently playing track (gapless, AP §3.5 / TP §5.4).
sealed class SyncOp {
  const SyncOp();
}

class RemoveOp extends SyncOp {
  const RemoveOp(this.index);
  final int index;
  @override
  String toString() => 'Remove($index)';
  @override
  bool operator ==(Object other) => other is RemoveOp && other.index == index;
  @override
  int get hashCode => Object.hash('r', index);
}

class InsertOp extends SyncOp {
  const InsertOp(this.index, this.id);
  final int index;
  final int id;
  @override
  String toString() => 'Insert($index, $id)';
  @override
  bool operator ==(Object other) =>
      other is InsertOp && other.index == index && other.id == id;
  @override
  int get hashCode => Object.hash('i', index, id);
}

class MoveOp extends SyncOp {
  const MoveOp(this.from, this.to);
  final int from;
  final int to;
  @override
  String toString() => 'Move($from, $to)';
  @override
  bool operator ==(Object other) =>
      other is MoveOp && other.from == from && other.to == to;
  @override
  int get hashCode => Object.hash('m', from, to);
}

/// Item ids are unique queue-row ids, so the diff is unambiguous.
///
/// 1. Remove everything no longer wanted (highest index first).
/// 2. Walk the desired list left to right, fixing position `i`: either move
///    the wanted item there from further right, or insert it fresh.
List<SyncOp> planQueueSync(List<int> loaded, List<int> desired) {
  final ops = <SyncOp>[];
  final want = desired.toSet();
  final work = [...loaded];
  for (var i = work.length - 1; i >= 0; i--) {
    if (!want.contains(work[i])) {
      ops.add(RemoveOp(i));
      work.removeAt(i);
    }
  }
  for (var i = 0; i < desired.length; i++) {
    if (i < work.length && work[i] == desired[i]) continue;
    final from = work.indexOf(desired[i]);
    if (from > i) {
      ops.add(MoveOp(from, i));
      work.insert(i, work.removeAt(from));
    } else {
      ops.add(InsertOp(i, desired[i]));
      work.insert(i, desired[i]);
    }
  }
  return ops;
}

/// Applies [ops] to a plain list — used by tests to prove the plan is correct.
List<int> applySyncOps(List<int> loaded, List<SyncOp> ops) {
  final work = [...loaded];
  for (final op in ops) {
    switch (op) {
      case RemoveOp(:final index):
        work.removeAt(index);
      case InsertOp(:final index, :final id):
        work.insert(index, id);
      case MoveOp(:final from, :final to):
        work.insert(to, work.removeAt(from));
    }
  }
  return work;
}
