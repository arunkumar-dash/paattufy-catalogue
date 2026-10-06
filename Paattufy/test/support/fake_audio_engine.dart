import 'dart:async';

import 'package:paattufy/features/playback/domain/audio_engine.dart';

/// In-memory [AudioEngine] that records calls and lets tests drive events.
class FakeAudioEngine implements AudioEngine {
  final _index = StreamController<int?>.broadcast(sync: true);
  final _playing = StreamController<bool>.broadcast(sync: true);
  final _position = StreamController<Duration>.broadcast(sync: true);
  final _duration = StreamController<Duration?>.broadcast(sync: true);
  final _state = StreamController<EngineState>.broadcast(sync: true);

  List<EngineTrack> tracks = [];
  int? _currentIndex;
  Duration _pos = Duration.zero;
  bool _isPlaying = false;

  int setTracksCalls = 0;
  int insertCalls = 0;
  int removeCalls = 0;
  int moveCalls = 0;
  int stopCalls = 0;
  double speed = 1.0;
  double pitch = 1.0;
  RepeatMode repeat = RepeatMode.off;
  bool skipSilence = false;
  bool normalisation = false;
  Duration lastSetTracksPosition = Duration.zero;
  final List<String> log = [];

  void emitPosition(Duration p) {
    _pos = p;
    _position.add(p);
  }

  /// Simulates a natural end-of-track advance to the next item.
  void advanceNaturally() {
    final next = (_currentIndex ?? -1) + 1;
    if (next < tracks.length) {
      _currentIndex = next;
      _pos = Duration.zero;
      _index.add(next);
    } else {
      _isPlaying = false;
      _playing.add(false);
      _state.add(EngineState.completed);
    }
  }

  @override
  Future<void> setTracks(List<EngineTrack> t,
      {required int index, Duration position = Duration.zero}) async {
    setTracksCalls++;
    log.add('setTracks(${t.length}, idx=$index)');
    tracks = [...t];
    _currentIndex = t.isEmpty ? null : index;
    _pos = position;
    lastSetTracksPosition = position;
    _index.add(_currentIndex);
  }

  @override
  Future<void> insertTracks(int index, List<EngineTrack> t) async {
    insertCalls++;
    log.add('insert($index)');
    tracks.insertAll(index, t);
    final cur = _currentIndex;
    if (cur != null && index <= cur) _currentIndex = cur + t.length;
  }

  @override
  Future<void> removeTrackAt(int index) async {
    removeCalls++;
    log.add('remove($index)');
    tracks.removeAt(index);
    final cur = _currentIndex;
    if (cur == null) return;
    if (index < cur) {
      _currentIndex = cur - 1;
    } else if (index == cur) {
      _currentIndex = tracks.isEmpty ? null : cur.clamp(0, tracks.length - 1);
      _index.add(_currentIndex);
    }
  }

  @override
  Future<void> moveTrack(int from, int to) async {
    moveCalls++;
    log.add('move($from,$to)');
    final cur = _currentIndex;
    final t = tracks.removeAt(from);
    tracks.insert(to, t);
    if (cur != null) {
      if (cur == from) {
        _currentIndex = to;
      } else if (from < cur && to >= cur) {
        _currentIndex = cur - 1;
      } else if (from > cur && to <= cur) {
        _currentIndex = cur + 1;
      }
    }
  }

  @override
  List<int> get loadedQueueItemIds => tracks.map((t) => t.queueItemId).toList();

  @override
  Future<void> play() async {
    if (tracks.isEmpty) return;
    _isPlaying = true;
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _playing.add(false);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _isPlaying = false;
    _playing.add(false);
    _state.add(EngineState.idle);
  }

  @override
  Future<void> seek(Duration position, {int? index}) async {
    log.add('seek(${position.inMilliseconds}, idx=$index)');
    _pos = position;
    if (index != null && index != _currentIndex) {
      _currentIndex = index;
      _index.add(index);
    }
  }

  @override
  Future<void> seekToNext() async => seek(Duration.zero, index: (_currentIndex ?? -1) + 1);
  @override
  Future<void> seekToPrevious() async => seek(Duration.zero, index: (_currentIndex ?? 1) - 1);

  @override
  Future<void> setSpeed(double s) async => speed = s;
  @override
  Future<void> setPitch(double p) async => pitch = p;
  @override
  Future<void> setRepeatMode(RepeatMode m) async => repeat = m;
  @override
  Future<void> setSkipSilence(bool e) async => skipSilence = e;
  double volume = 1.0;
  @override
  Future<void> setVolume(double v) async => volume = v;

  @override
  Future<void> setVolumeNormalisation(bool e) async => normalisation = e;
  @override
  Future<void> setTrackGainDb(double g) async {}

  @override
  int? get currentIndex => _currentIndex;
  @override
  Duration get position => _pos;
  @override
  Duration? get duration => _currentIndex == null
      ? null
      : Duration(milliseconds: tracks[_currentIndex!].song.durationMs);
  @override
  bool get playing => _isPlaying;
  @override
  int? get audioSessionId => 1;
  @override
  Stream<int?> get currentIndexStream => _index.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<Duration?> get durationStream => _duration.stream;
  @override
  Stream<EngineState> get stateStream => _state.stream;

  @override
  Future<void> dispose() async {}
}
