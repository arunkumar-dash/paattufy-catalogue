/// One timed lyric line.
class LyricLine {
  const LyricLine(this.time, this.text);
  final Duration time;
  final String text;

  @override
  String toString() => '[${time.inMilliseconds}ms] $text';
  @override
  bool operator ==(Object other) =>
      other is LyricLine && other.time == time && other.text == text;
  @override
  int get hashCode => Object.hash(time, text);
}

/// Parsed `.lrc` content.
class ParsedLrc {
  const ParsedLrc(this.lines, {this.offsetMs = 0, this.tags = const {}});
  final List<LyricLine> lines;

  /// `[offset:±ms]` from the file itself (applied to line times already).
  final int offsetMs;
  final Map<String, String> tags;

  bool get isSynced => lines.isNotEmpty;
}

/// LRC parsing and playback-position lookup (TP §5.6).
class Lrc {
  // [mm:ss], [mm:ss.x], [mm:ss.xx], [mm:ss.xxx] and the legacy [mm:ss:xx].
  // Minutes may exceed 59 (long recordings); there is deliberately no hour
  // field, since `[a:b:c]` is far more often minutes:seconds:fraction.
  static final RegExp _time = RegExp(r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]');
  static final RegExp _tag = RegExp(r'^\[([A-Za-z#]+):(.*)\]\s*$');
  // Enhanced-LRC word-level tags such as <00:12.34>
  static final RegExp _wordTag = RegExp(r'<\d{1,3}:\d{1,2}(?:[.:]\d{1,3})?>');

  static ParsedLrc parse(String source) {
    final tags = <String, String>{};
    final lines = <LyricLine>[];
    var offset = 0;

    for (final raw in source.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      final matches = _time.allMatches(line).toList();
      if (matches.isEmpty) {
        final t = _tag.firstMatch(line);
        if (t != null) {
          final key = t.group(1)!.toLowerCase();
          final value = t.group(2)!.trim();
          tags[key] = value;
          if (key == 'offset') offset = int.tryParse(value.replaceFirst('+', '')) ?? 0;
        }
        continue;
      }

      // Text is whatever follows the last leading time tag.
      final text = line.substring(matches.last.end).replaceAll(_wordTag, '').trim();
      for (final m in matches) {
        final min = int.parse(m.group(1)!);
        final sec = int.parse(m.group(2)!);
        final frac = m.group(3);
        final ms = frac == null ? 0 : (int.parse(frac) * _fracScale(frac.length)).round();
        lines.add(LyricLine(
          Duration(minutes: min, seconds: sec, milliseconds: ms),
          text,
        ));
      }
    }

    // A positive [offset:] makes lyrics appear *earlier*, per the LRC spec.
    final shifted = [
      for (final l in lines)
        LyricLine(_clampZero(l.time - Duration(milliseconds: offset)), l.text),
    ]..sort((a, b) => a.time.compareTo(b.time));

    return ParsedLrc(shifted, offsetMs: offset, tags: tags);
  }

  static double _fracScale(int digits) => switch (digits) { 1 => 100, 2 => 10, _ => 1 };

  static Duration _clampZero(Duration d) => d.isNegative ? Duration.zero : d;

  /// Index of the line that is active at [position], or -1 before the first
  /// line. [offsetMs] is the user's per-song nudge (±200 ms steps, AP §5.6),
  /// applied at render time only — it never mutates the cached LRC text.
  static int activeIndex(List<LyricLine> lines, Duration position, {int offsetMs = 0}) {
    if (lines.isEmpty) return -1;
    final t = position + Duration(milliseconds: offsetMs);
    var lo = 0, hi = lines.length - 1, ans = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (lines[mid].time <= t) {
        ans = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return ans;
  }

  /// Time a tap on line [index] should seek to, compensating the nudge so the
  /// line is *active* afterwards.
  static Duration seekTimeFor(List<LyricLine> lines, int index, {int offsetMs = 0}) {
    final t = lines[index].time - Duration(milliseconds: offsetMs);
    return t.isNegative ? Duration.zero : t;
  }

  /// Plain text version (timestamps removed), for providers that only return
  /// synced lyrics or for the full-screen reader fallback.
  static String toPlain(List<LyricLine> lines) => lines.map((l) => l.text).join('\n');
}
