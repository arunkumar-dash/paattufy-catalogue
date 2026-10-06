/// A search/fetch result from a provider (AP §3.7, §5.6).
class LyricsCandidate {
  const LyricsCandidate({
    required this.providerId,
    required this.title,
    required this.artist,
    this.album,
    this.durationSec,
    this.synced,
    this.plain,
    this.isInstrumental = false,
  });

  final String providerId;
  final String title;
  final String artist;
  final String? album;
  final double? durationSec;
  final String? synced;
  final String? plain;
  final bool isInstrumental;

  bool get hasSynced => synced != null && synced!.trim().isNotEmpty;
  bool get hasPlain => plain != null && plain!.trim().isNotEmpty;
  bool get hasAnyLyrics => hasSynced || hasPlain;

  /// How close this result's duration is to the song's, in seconds (null when
  /// unknown). Drives the "duration match" indicator in the picker.
  double? durationDelta(double songDurationSec) =>
      durationSec == null ? null : (durationSec! - songDurationSec).abs();

  DurationMatch durationMatch(double songDurationSec) {
    final d = durationDelta(songDurationSec);
    if (d == null) return DurationMatch.unknown;
    if (d <= 2) return DurationMatch.exact;
    if (d <= 6) return DurationMatch.close;
    return DurationMatch.far;
  }
}

enum DurationMatch { exact, close, far, unknown }

/// What the app should show for a song, after the resolution order
/// (embedded/sidecar → cached remote pick → nothing).
class ResolvedLyrics {
  const ResolvedLyrics({
    required this.source,
    required this.providerId,
    this.synced,
    this.plain,
    this.offsetMs = 0,
  });

  /// 'embedded' | 'remote'
  final String source;
  final String providerId;
  final String? synced;
  final String? plain;
  final int offsetMs;

  bool get hasSynced => synced != null && synced!.trim().isNotEmpty;
  bool get hasPlain => plain != null && plain!.trim().isNotEmpty;
}

/// Domain interface every lyrics source implements (TP §5.6).
abstract class LyricsProvider {
  String get id;
  String get displayName;

  /// Multiple candidates for the picker; [query] is user-editable.
  Future<List<LyricsCandidate>> search(String query);

  /// Best signature match for a song, or null.
  Future<LyricsCandidate?> fetchBest({
    required String title,
    required String artist,
    String? album,
    double? durationSec,
  });
}
