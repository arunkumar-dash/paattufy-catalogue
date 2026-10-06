import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/utils/song_id.dart';

void main() {
  test('is deterministic, 16 hex chars, and depends on both inputs', () {
    final a = songIdFor(1, '/music/a.mp3');
    expect(a, songIdFor(1, '/music/a.mp3'));
    expect(a, matches(RegExp(r'^[0-9a-f]{16}$')));
    expect(a, isNot(songIdFor(2, '/music/a.mp3')));
    expect(a, isNot(songIdFor(1, '/music/b.mp3')));
  });
}
