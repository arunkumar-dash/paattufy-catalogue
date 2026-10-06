// Paattufy fixture generator (TP §8).
//
// Synthesises small sine-wave WAV files (16-bit PCM mono) with varying
// duration/frequency, plus a fixture metadata table (JSON) describing the
// fake library they represent. Tests never touch real music.
//
// Run from the project root:
//   dart run test/fixtures/generate_fixtures.dart
//
// Output:
//   test/fixtures/audio/*.wav
//   test/fixtures/fixture_library.json

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int sampleRate = 22050;

class FixtureSong {
  FixtureSong({
    required this.fileName,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtist,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.durationMs,
    required this.frequencyHz,
  });

  final String fileName;
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String genre;
  final int year;
  final int trackNumber;
  final int durationMs;
  final double frequencyHz;

  Map<String, Object?> toJson() => {
        'fileName': fileName,
        'title': title,
        'artist': artist,
        'album': album,
        'albumArtist': albumArtist,
        'genre': genre,
        'year': year,
        'trackNumber': trackNumber,
        'durationMs': durationMs,
        'frequencyHz': frequencyHz,
        'format': 'wav',
        'sampleRate': sampleRate,
      };
}

/// The fake library: two artists, two albums each, spanning genres/years so
/// smart-group rules, sorting and suggestion scoring all have something to
/// chew on.
final List<FixtureSong> fixtureSongs = [
  FixtureSong(fileName: 'kanavugal_01.wav', title: 'Kanavugal', artist: 'Ilaiyaraaja', album: 'Nizhal Nijam', albumArtist: 'Ilaiyaraaja', genre: 'Melody', year: 1982, trackNumber: 1, durationMs: 4000, frequencyHz: 261.63),
  FixtureSong(fileName: 'megam_02.wav', title: 'Megam', artist: 'Ilaiyaraaja', album: 'Nizhal Nijam', albumArtist: 'Ilaiyaraaja', genre: 'Melody', year: 1982, trackNumber: 2, durationMs: 3500, frequencyHz: 293.66),
  FixtureSong(fileName: 'poove_03.wav', title: 'Poove', artist: 'Ilaiyaraaja', album: 'Vaanam Vasappadum', albumArtist: 'Ilaiyaraaja', genre: 'Sad', year: 1986, trackNumber: 1, durationMs: 3000, frequencyHz: 329.63),
  FixtureSong(fileName: 'thendral_04.wav', title: 'Thendral', artist: 'Ilaiyaraaja', album: 'Vaanam Vasappadum', albumArtist: 'Ilaiyaraaja', genre: 'Sad', year: 1986, trackNumber: 2, durationMs: 4500, frequencyHz: 349.23),
  FixtureSong(fileName: 'minnal_05.wav', title: 'Minnal', artist: 'A. R. Rahman', album: 'Veyilodu Vilaiyadi', albumArtist: 'A. R. Rahman', genre: 'Dance', year: 2008, trackNumber: 1, durationMs: 3000, frequencyHz: 392.00),
  FixtureSong(fileName: 'natpu_06.wav', title: 'Natpu', artist: 'A. R. Rahman', album: 'Veyilodu Vilaiyadi', albumArtist: 'A. R. Rahman', genre: 'Dance', year: 2008, trackNumber: 2, durationMs: 2500, frequencyHz: 440.00),
  FixtureSong(fileName: 'kadhal_07.wav', title: 'Kadhal', artist: 'A. R. Rahman', album: 'Mazhai Thooralam', albumArtist: 'A. R. Rahman', genre: 'Melody', year: 2014, trackNumber: 1, durationMs: 4000, frequencyHz: 493.88),
  FixtureSong(fileName: 'mazhai_08.wav', title: 'Mazhai', artist: 'A. R. Rahman', album: 'Mazhai Thooralam', albumArtist: 'A. R. Rahman', genre: 'Melody', year: 2014, trackNumber: 2, durationMs: 3500, frequencyHz: 523.25),
  FixtureSong(fileName: 'nilavu_09.wav', title: 'Nilavu', artist: 'Yuvan Shankar Raja', album: 'Iravukku Aayiram', albumArtist: 'Yuvan Shankar Raja', genre: 'Sad', year: 2004, trackNumber: 1, durationMs: 3000, frequencyHz: 220.00),
  FixtureSong(fileName: 'thuli_10.wav', title: 'Thuli', artist: 'Yuvan Shankar Raja', album: 'Iravukku Aayiram', albumArtist: 'Yuvan Shankar Raja', genre: 'Sad', year: 2004, trackNumber: 2, durationMs: 3200, frequencyHz: 246.94),
  FixtureSong(fileName: 'paravai_11.wav', title: 'Paravai', artist: 'Yuvan Shankar Raja', album: 'Kaatru Veliyidai', albumArtist: 'Yuvan Shankar Raja', genre: 'Dance', year: 2011, trackNumber: 1, durationMs: 2800, frequencyHz: 587.33),
  FixtureSong(fileName: 'vennilaa_12.wav', title: 'Vennilaa', artist: 'Yuvan Shankar Raja', album: 'Kaatru Veliyidai', albumArtist: 'Yuvan Shankar Raja', genre: 'Melody', year: 2011, trackNumber: 2, durationMs: 3800, frequencyHz: 659.25),
];

/// Writes a minimal 16-bit PCM mono WAV of a pure sine tone.
Uint8List _sineWaveWav(double frequencyHz, int durationMs) {
  final int sampleCount = (sampleRate * durationMs / 1000).round();
  final data = Int16List(sampleCount);
  for (var i = 0; i < sampleCount; i++) {
    final t = i / sampleRate;
    // Gentle 50 ms fade in/out so analysis code never sees a click edge.
    final fadeSamples = (sampleRate * 0.05).round();
    final envelope = i < fadeSamples
        ? i / fadeSamples
        : (i > sampleCount - fadeSamples
            ? (sampleCount - i) / fadeSamples
            : 1.0);
    data[i] = (sin(2 * pi * frequencyHz * t) * 0.8 * envelope * 32767).round();
  }

  final byteData = ByteData(44 + sampleCount * 2);
  void writeString(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      byteData.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  writeString(0, 'RIFF');
  byteData.setUint32(4, 36 + sampleCount * 2, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  byteData.setUint32(16, 16, Endian.little); // PCM chunk size
  byteData.setUint16(20, 1, Endian.little); // PCM format
  byteData.setUint16(22, 1, Endian.little); // mono
  byteData.setUint32(24, sampleRate, Endian.little);
  byteData.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  byteData.setUint16(32, 2, Endian.little); // block align
  byteData.setUint16(34, 16, Endian.little); // bits per sample
  writeString(36, 'data');
  byteData.setUint32(40, sampleCount * 2, Endian.little);
  for (var i = 0; i < sampleCount; i++) {
    byteData.setInt16(44 + i * 2, data[i], Endian.little);
  }
  return byteData.buffer.asUint8List();
}

Future<void> main() async {
  final audioDir = Directory('test/fixtures/audio');
  await audioDir.create(recursive: true);

  for (final song in fixtureSongs) {
    final wav = _sineWaveWav(song.frequencyHz, song.durationMs);
    await File('${audioDir.path}/${song.fileName}').writeAsBytes(wav);
  }

  final manifest = {
    'schemaVersion': 1,
    'generatedBy': 'test/fixtures/generate_fixtures.dart',
    'songs': fixtureSongs.map((s) => s.toJson()).toList(),
  };
  await File('test/fixtures/fixture_library.json').writeAsString(
    const JsonEncoder.withIndent('  ').convert(manifest),
  );

  stdout.writeln(
    'Generated ${fixtureSongs.length} fixture WAVs + fixture_library.json',
  );
}
