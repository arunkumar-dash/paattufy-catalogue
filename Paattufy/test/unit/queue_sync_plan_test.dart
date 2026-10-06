import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/features/playback/domain/queue_sync_plan.dart';

void main() {
  test('no ops when identical', () {
    expect(planQueueSync([1, 2, 3], [1, 2, 3]), isEmpty);
  });

  test('play-next is a single insert; current track untouched', () {
    final ops = planQueueSync([1, 2, 3], [1, 9, 2, 3]);
    expect(ops, [const InsertOp(1, 9)]);
  });

  test('append is a single insert at the tail', () {
    expect(planQueueSync([1, 2], [1, 2, 7]), [const InsertOp(2, 7)]);
  });

  test('removal is a single remove', () {
    expect(planQueueSync([1, 2, 3], [1, 3]), [const RemoveOp(1)]);
  });

  test('reorder is a single move', () {
    expect(planQueueSync([1, 2, 3, 4], [1, 4, 2, 3]), [const MoveOp(3, 1)]);
  });

  test('randomised: applying the plan always yields the desired order', () {
    final rng = Random(42);
    for (var n = 0; n < 500; n++) {
      final pool = List.generate(12, (i) => i);
      pool.shuffle(rng);
      final loaded = pool.take(rng.nextInt(10)).toList();
      final pool2 = List.generate(14, (i) => i)..shuffle(rng);
      final desired = pool2.take(rng.nextInt(12)).toList();
      final ops = planQueueSync(loaded, desired);
      expect(applySyncOps(loaded, ops), desired, reason: '$loaded -> $desired via $ops');
    }
  });
}
