import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/library/data/artwork_cache.dart';

/// Lazily loaded album art (AP §2 "lazy artwork") with a tonal placeholder.
class SongArtwork extends ConsumerStatefulWidget {
  const SongArtwork({
    super.key,
    required this.contentUri,
    this.size = 44,
    this.radius = 8,
    this.icon = Icons.music_note,
    this.fit = BoxFit.cover,
  });

  final String? contentUri;
  final double size;
  final double radius;
  final IconData icon;
  final BoxFit fit;

  @override
  ConsumerState<SongArtwork> createState() => _SongArtworkState();
}

class _SongArtworkState extends ConsumerState<SongArtwork> {
  Future<Uint8List?>? _future;

  String? _loadedKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(SongArtwork old) {
    super.didUpdateWidget(old);
    if (old.contentUri != widget.contentUri || old.size != widget.size) _load();
  }

  void _load() {
    final uri = widget.contentUri;
    if (uri == null) {
      _future = null;
      _loadedKey = null;
      return;
    }
    final px = (widget.size * MediaQuery.devicePixelRatioOf(context)).ceil().clamp(64, 1024);
    final key = '$uri@$px';
    if (key == _loadedKey) return;
    _loadedKey = key;
    _future = ref.read(artworkCacheProvider).bytes(uri, size: px);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: widget.size,
      height: widget.size,
      color: scheme.surfaceContainerHighest,
      child: Icon(widget.icon, size: widget.size * 0.45, color: scheme.onSurfaceVariant),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _future == null
            ? placeholder
            : FutureBuilder<Uint8List?>(
                future: _future,
                builder: (context, snap) {
                  final data = snap.data;
                  if (data == null) return placeholder;
                  return Image.memory(data, fit: widget.fit, gaplessPlayback: true, width: widget.size, height: widget.size);
                },
              ),
      ),
    );
  }
}

/// 2×2 art mosaic used on group cards (AP §5.4).
class SongMosaic extends StatelessWidget {
  const SongMosaic({super.key, required this.contentUris, this.size = 120, this.radius = 12, this.icon = Icons.queue_music});
  final List<String> contentUris;
  final double size;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (contentUris.isEmpty) return SongArtwork(contentUri: null, size: size, radius: radius, icon: icon);
    if (contentUris.length < 4) return SongArtwork(contentUri: contentUris.first, size: size, radius: radius, icon: icon);
    final half = size / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(children: [
          Row(children: [
            SongArtwork(contentUri: contentUris[0], size: half, radius: 0),
            SongArtwork(contentUri: contentUris[1], size: half, radius: 0),
          ]),
          Row(children: [
            SongArtwork(contentUri: contentUris[2], size: half, radius: 0),
            SongArtwork(contentUri: contentUris[3], size: half, radius: 0),
          ]),
        ]),
      ),
    );
  }
}
