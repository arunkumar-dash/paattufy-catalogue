import 'package:flutter/material.dart';

import '../entities/entities.dart';
import '../utils/formatters.dart';
import 'song_artwork.dart';

/// Library row (AP §5.2): artwork · title · `artist · album` · duration · menu.
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onLongPress,
    this.onMenu,
    this.playing = false,
    this.selected = false,
    this.selecting = false,
    this.trailing,
  });

  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMenu;
  final bool playing;
  final bool selected;
  final bool selecting;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              if (selecting)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: selected ? scheme.primary : scheme.onSurfaceVariant),
                ),
              SongArtwork(contentUri: song.contentUri, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: playing ? scheme.primary : null,
                      ),
                    ),
                    Text(
                      '${song.artist} · ${song.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (playing) Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.graphic_eq, size: 18, color: scheme.primary)),
              Text(formatMs(song.durationMs),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()])),
              ?trailing,
              if (onMenu != null && !selecting)
                IconButton(icon: const Icon(Icons.more_vert), onPressed: onMenu, visualDensity: VisualDensity.compact),
            ],
          ),
        ),
      ),
    );
  }
}
