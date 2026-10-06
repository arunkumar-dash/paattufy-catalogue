import 'dart:async';

/// Sleep timer (AP §8.1): stop after N minutes, or at the end of the current
/// track. Pure logic over injected callbacks so it is unit-tested with
/// `fakeAsync`.
class SleepTimer {
  SleepTimer({required this._onFire, Timer Function(Duration, void Function())? timerFactory})
      : _makeTimer = timerFactory ?? ((d, cb) => Timer(d, cb));

  final Future<void> Function() _onFire;
  final Timer Function(Duration, void Function()) _makeTimer;

  Timer? _timer;
  Timer? _ticker;
  DateTime? _firesAt;
  bool _endOfTrack = false;
  int? _trackWhenSet;
  DateTime Function() clock = DateTime.now;

  final _changes = StreamController<SleepTimerState>.broadcast();
  Stream<SleepTimerState> get changes => _changes.stream;

  SleepTimerState get state => SleepTimerState(
        active: _timer != null || _endOfTrack,
        endOfTrack: _endOfTrack,
        remaining: _firesAt?.difference(clock()),
      );

  /// Fires after [duration].
  void startIn(Duration duration) {
    cancel();
    _firesAt = clock().add(duration);
    _timer = _makeTimer(duration, _fire);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _changes.add(state));
    _changes.add(state);
  }

  /// Fires when the track identified by [currentItemId] ends (or the listener
  /// moves to a different one).
  void startAtEndOfTrack(int? currentItemId) {
    cancel();
    _endOfTrack = true;
    _trackWhenSet = currentItemId;
    _changes.add(state);
  }

  /// The playback controller reports item changes / completion here.
  void onTrackBoundary(int? newCurrentItemId) {
    if (_endOfTrack && newCurrentItemId != _trackWhenSet) _fire();
  }

  void cancel() {
    _timer?.cancel();
    _ticker?.cancel();
    _timer = null;
    _ticker = null;
    _firesAt = null;
    _endOfTrack = false;
    _trackWhenSet = null;
    _changes.add(state);
  }

  void _fire() {
    cancel();
    unawaited(_onFire());
  }

  void dispose() {
    cancel();
    _changes.close();
  }
}

class SleepTimerState {
  const SleepTimerState({required this.active, required this.endOfTrack, this.remaining});
  final bool active;
  final bool endOfTrack;
  final Duration? remaining;
}
