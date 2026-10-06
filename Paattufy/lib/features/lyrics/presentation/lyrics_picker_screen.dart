import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../library/data/library_providers.dart';
import '../data/lyrics_providers.dart';
import '../domain/lrc.dart';
import '../domain/lyrics_models.dart';

/// Lyrics picker (AP §5.6): editable query → result cards with track / artist
/// / album, a duration-match indicator and a Synced / Plain badge → preview →
/// `Use this`. The choice is remembered forever.
class LyricsPickerScreen extends ConsumerStatefulWidget {
  const LyricsPickerScreen({super.key, required this.songId});
  final String songId;

  @override
  ConsumerState<LyricsPickerScreen> createState() => _LyricsPickerScreenState();
}

class _LyricsPickerScreenState extends ConsumerState<LyricsPickerScreen> {
  final _controller = TextEditingController();
  String _query = '';
  Song? _song;

  @override
  void initState() {
    super.initState();
    ref.read(libraryRepositoryProvider).songById(widget.songId).then((s) {
      if (!mounted || s == null) return;
      setState(() {
        _song = s;
        _query = defaultLyricsQuery(s);
        _controller.text = _query;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(lyricsSearchProvider(_query));
    final scheme = Theme.of(context).colorScheme;
    final song = _song;
    return Scaffold(
      appBar: AppBar(title: const Text('Search lyrics')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Artist and title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
              suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => setState(() => _query = _controller.text)),
            ),
          ),
        ),
        if (song != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('For: ${song.title} — ${song.artist}', style: TextStyle(color: scheme.onSurfaceVariant)),
            ),
          ),
        Expanded(
          child: results.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not reach the lyrics provider.\n$e', textAlign: TextAlign.center))),
            data: (list) {
              if (list.isEmpty) return const Center(child: Text('No results. Try a simpler query.'));
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, i) => _CandidateCard(
                  candidate: list[i],
                  songDurationSec: song == null ? null : song.durationMs / 1000,
                  onTap: song == null ? null : () => _preview(context, song, list[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Future<void> _preview(BuildContext context, Song song, LyricsCandidate c) async {
    final text = c.hasSynced ? Lrc.toPlain(Lrc.parse(c.synced!).lines) : (c.plain ?? '');
    final use = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, scroll) => Column(children: [
          ListTile(title: Text(c.title), subtitle: Text('${c.artist}${c.album == null ? '' : ' · ${c.album}'}')),
          Expanded(child: ListView(controller: scroll, padding: const EdgeInsets.symmetric(horizontal: 20), children: [Text(text, style: const TextStyle(fontSize: 16, height: 1.6))])),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheet, false), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheet, true), child: const Text('Use this'))),
              ]),
            ),
          ),
        ]),
      ),
    );
    if (use == true) {
      await ref.read(lyricsRepositoryProvider).pick(song, c);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lyrics saved for this song')));
        Navigator.of(context).pop();
      }
    }
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate, required this.songDurationSec, required this.onTap});
  final LyricsCandidate candidate;
  final double? songDurationSec;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final match = songDurationSec == null ? DurationMatch.unknown : candidate.durationMatch(songDurationSec!);
    final (matchLabel, matchColor) = switch (match) {
      DurationMatch.exact => ('Duration matches', Colors.green),
      DurationMatch.close => ('Close length', Colors.amber),
      DurationMatch.far => ('Different length', scheme.error),
      DurationMatch.unknown => ('Length unknown', scheme.onSurfaceVariant),
    };
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(candidate.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${candidate.artist}${candidate.album == null ? '' : ' · ${candidate.album}'}', maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.timer_outlined, size: 14, color: matchColor),
            const SizedBox(width: 4),
            Text(matchLabel, style: TextStyle(fontSize: 12, color: matchColor)),
          ]),
        ]),
        trailing: Chip(
          label: Text(candidate.hasSynced ? 'Synced' : (candidate.isInstrumental ? 'Instrumental' : 'Plain')),
          backgroundColor: candidate.hasSynced ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
