import 'dart:math';
import 'dart:typed_data';

import '../../../core/entities/entities.dart';
import '../domain/audio_features.dart';
import '../domain/dsp.dart';
import 'embedder.dart';
import 'feature_repository.dart';
import 'pcm_decoder.dart';

/// Runs the per-song pipeline (TP §5.7): decode → heuristic features → optional
/// ML embedding → persist. Analysis uses a bounded excerpt (centred 60 s) so a
/// song costs a fixed amount of battery regardless of length; the ML frames are
/// taken at the start / middle / end of that excerpt to keep inference cheap.
class FeatureExtractor {
  FeatureExtractor({
    required this._decoder,
    required FeatureRepository repository,
    this._embedder,
    Dsp? dsp,
    this.excerptSeconds = 60,
  })  : _repo = repository,
        _dsp = dsp ?? Dsp();

  static const int analysisRate = 22050;
  static const int yamnetRate = 16000;

  final PcmDecoder _decoder;
  final FeatureRepository _repo;
  final AudioEmbedder? _embedder;
  final Dsp _dsp;
  final int excerptSeconds;

  /// Identifies this pipeline; stored with each row so upgrading it (e.g.
  /// bundling the YAMNet model) re-analyses older songs.
  String get version => _embedder == null ? 'heuristic-v1' : 'heuristic-v1+${_embedder.version}';

  /// Extracts features for one song without persisting. Null when the file
  /// cannot be decoded or is too short to analyse.
  Future<AudioFeatures?> extract(Song song) async {
    final excerptMs = excerptSeconds * 1000;
    final startMs = song.durationMs > excerptMs + 15000 ? (song.durationMs - excerptMs) ~/ 2 : 0;
    final pcm = await _decoder.decode(
      song.contentUri,
      sampleRate: analysisRate,
      startMs: startMs,
      durationMs: excerptMs,
    );
    if (pcm == null || pcm.length < analysisRate * 2) return null;

    final r = _dsp.analyse(pcm);
    Float32List? embedding;
    final embedder = _embedder;
    if (embedder != null) {
      embedding = await embedder.embed(_mlFrames(pcm));
    }
    return AudioFeatures(
      tempoBpm: r.tempoBpm,
      keyIndex: r.keyIndex,
      keyMode: r.keyMode,
      energy: r.energy,
      acousticness: r.acousticness,
      brightness: r.brightness,
      danceability: r.danceability,
      embedding: embedding,
    );
  }

  /// Analyses and persists one song. Returns true on success; unanalysable
  /// files get a `failed` marker so they are not retried forever.
  Future<bool> analyse(Song song) async {
    try {
      final f = await extract(song);
      if (f == null) {
        await _repo.markFailed(song.id);
        return false;
      }
      await _repo.save(song.id, f, version);
      return true;
    } catch (_) {
      await _repo.markFailed(song.id);
      return false;
    }
  }

  /// Runs up to [limit] songs that still need analysis; returns how many
  /// succeeded. [shouldContinue] lets callers abort between songs (e.g. when
  /// the background task is stopped).
  Future<int> runBatch({
    int limit = 5,
    List<String> excludedFolders = const [],
    bool Function()? shouldContinue,
  }) async {
    final songs = await _repo.songsNeedingAnalysis(version, limit: limit, excludedFolders: excludedFolders);
    var done = 0;
    for (final s in songs) {
      if (shouldContinue != null && !shouldContinue()) break;
      if (await analyse(s)) done++;
    }
    return done;
  }

  /// Three 0.975 s frames (start / middle / end of the excerpt) resampled from
  /// 22.05 kHz to YAMNet's 16 kHz.
  List<Float32List> _mlFrames(Float32List pcm) {
    final srcLen = (YamnetEmbedder.frameSamples * analysisRate / yamnetRate).ceil();
    if (pcm.length < srcLen) return [_resample(pcm)];
    final starts = {0, (pcm.length - srcLen) ~/ 2, pcm.length - srcLen}.toList();
    return [for (final s in starts) _resample(Float32List.sublistView(pcm, s, s + srcLen))];
  }

  Float32List _resample(Float32List src) {
    final ratio = analysisRate / yamnetRate;
    final outLen = min((src.length / ratio).floor(), YamnetEmbedder.frameSamples);
    final out = Float32List(YamnetEmbedder.frameSamples);
    for (var i = 0; i < outLen; i++) {
      final pos = i * ratio;
      final i0 = pos.floor();
      final i1 = min(i0 + 1, src.length - 1);
      final frac = pos - i0;
      out[i] = (src[i0] * (1 - frac) + src[i1] * frac).toDouble();
    }
    return out;
  }
}
