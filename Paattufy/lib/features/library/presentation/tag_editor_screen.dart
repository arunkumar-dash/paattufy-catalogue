import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/entities/entities.dart';
import '../../../core/widgets/song_artwork.dart';
import '../data/library_providers.dart';
import '../data/tag_service.dart';

/// Tag editor (AP §8.6): title / artist / album / album artist / genre / year /
/// track number and artwork. Changes are written into the file's tags (TagLib)
/// and the library is refreshed.
class TagEditorScreen extends ConsumerStatefulWidget {
  const TagEditorScreen({super.key, required this.songId});
  final String songId;

  @override
  ConsumerState<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends ConsumerState<TagEditorScreen> {
  Song? _song;
  TagInfo? _info;
  bool _loading = true;
  bool _unsupported = false;
  bool _saving = false;
  Uint8List? _newArt;
  bool _removeArt = false;
  final _c = {for (final k in ['title', 'artist', 'album', 'albumArtist', 'genre', 'year', 'track']) k: TextEditingController()};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final song = await ref.read(libraryRepositoryProvider).songById(widget.songId);
    if (song == null) {
      if (mounted) context.pop();
      return;
    }
    final info = await ref.read(tagServiceProvider).read(song);
    if (!mounted) return;
    setState(() {
      _song = song;
      _info = info;
      _unsupported = info == null;
      _c['title']!.text = info?.title ?? song.title;
      _c['artist']!.text = info?.artist ?? (song.artist == 'Unknown artist' ? '' : song.artist);
      _c['album']!.text = info?.album ?? (song.album == 'Unknown album' ? '' : song.album);
      _c['albumArtist']!.text = info?.albumArtist ?? song.albumArtist ?? '';
      _c['genre']!.text = info?.genre ?? song.genre ?? '';
      _c['year']!.text = info?.year ?? (song.year?.toString() ?? '');
      _c['track']!.text = info?.track ?? (song.trackNumber?.toString() ?? '');
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickArt() async {
    final picked = await FilePicker.pickFile(type: FileType.image);
    final path = picked?.path;
    if (path == null) return;
    final bytes = await File(path).readAsBytes();
    if (!mounted) return;
    setState(() {
      _newArt = bytes;
      _removeArt = false;
    });
  }

  Future<void> _save() async {
    final song = _song!;
    setState(() => _saving = true);
    final tags = ref.read(tagServiceProvider);
    try {
      final ok = await tags.write(song, {for (final e in _c.entries) e.key: e.value.text});
      var artOk = true;
      if (_newArt != null) artOk = await tags.setArtwork(song, _newArt);
      if (_removeArt && _newArt == null) artOk = await tags.setArtwork(song, null);
      if (!mounted) return;
      if (ok && artOk) {
        await ref.read(scanControllerProvider.notifier).run(full: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tags saved')));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not write tags. Is All-files access granted?')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not write tags: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Edit tags')), body: const Center(child: CircularProgressIndicator()));
    final song = _song!;
    Widget field(String key, String label, {TextInputType? type}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(controller: _c[key], keyboardType: type, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Edit tags'), actions: [
        TextButton(onPressed: _saving || _unsupported ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save')),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (_unsupported)
          const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('This file format can\'t be edited'), subtitle: Text('Supported: MP3, FLAC, M4A/MP4, OGG/Opus and most common formats.'))),
        Row(children: [
          _newArt != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_newArt!, width: 96, height: 96, fit: BoxFit.cover)) : (_removeArt ? const SizedBox(width: 96, height: 96, child: Icon(Icons.image_not_supported_outlined, size: 40)) : SongArtwork(contentUri: song.contentUri, size: 96, radius: 12)),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(spacing: 8, children: [
              OutlinedButton.icon(onPressed: _unsupported ? null : _pickArt, icon: const Icon(Icons.image_outlined), label: const Text('Replace artwork')),
              if (_info?.hasArtwork ?? false) TextButton(onPressed: () => setState(() { _removeArt = true; _newArt = null; }), child: const Text('Remove')),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        field('title', 'Title'),
        field('artist', 'Artist'),
        field('album', 'Album'),
        field('albumArtist', 'Album artist'),
        field('genre', 'Genre'),
        Row(children: [
          Expanded(child: field('year', 'Year', type: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: field('track', 'Track #', type: TextInputType.number)),
        ]),
        Text('Only tag metadata is changed — the audio itself is never re-encoded.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}
