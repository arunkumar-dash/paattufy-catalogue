import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/entities/entities.dart';
import '../../library/data/library_providers.dart';
import '../data/group_providers.dart';
import '../data/group_repository.dart';
import '../domain/rules.dart';
import 'rule_value_editors.dart';

/// Distinct values for the chip / autocomplete pickers.
final _distinctValuesProvider = FutureProvider.autoDispose.family<List<String>, RuleField>((ref, field) async {
  final songs = await ref.watch(libraryRepositoryProvider).allVisibleSongs();
  final values = <String>{};
  for (final s in songs) {
    final v = switch (field) {
      RuleField.artist => s.artist,
      RuleField.albumArtist => s.albumArtist,
      RuleField.album => s.album,
      RuleField.genre => s.genre,
      RuleField.folderPath => s.folderPath,
      RuleField.format => s.format,
      RuleField.title => s.title,
      _ => null,
    };
    if (v != null && v.isNotEmpty) values.add(v);
  }
  return values.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
});

class _Cond {
  _Cond(this.field, this.operator, this.value);
  RuleField field;
  RuleOperator operator;
  Object? value;
  final Key key = UniqueKey();
}

/// Group editor: static picker or smart rule builder with live preview
/// (AP §5.4).
class GroupEditorScreen extends ConsumerStatefulWidget {
  const GroupEditorScreen({super.key, this.groupId, required this.type});
  final int? groupId;
  final String type; // 'static' | 'smart'

  @override
  ConsumerState<GroupEditorScreen> createState() => _GroupEditorScreenState();
}

class _GroupEditorScreenState extends ConsumerState<GroupEditorScreen> {
  final _name = TextEditingController();
  bool _loaded = false;
  SongGroup? _existing;

  // smart
  MatchMode _mode = MatchMode.all;
  final List<_Cond> _conds = [];
  final List<int> _include = [];
  final List<int> _exclude = [];
  List<String> _pins = [];
  List<String> _excludes = [];
  String _sort = GroupSort.title;
  bool _ascending = true;
  String _playMode = 'ordered';
  RulePreview? _preview;
  Timer? _debounce;

  // static
  final Set<String> _picked = {};
  final List<String> _pickedOrder = [];
  String _search = '';

  bool get _isSmart => (_existing?.type ?? widget.type) == 'smart';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(groupRepositoryProvider);
    final id = widget.groupId;
    if (id != null) {
      final g = await repo.groupById(id);
      if (g != null) {
        _existing = g;
        _name.text = g.name;
        _sort = g.defaultSort;
        _ascending = g.defaultSortAscending;
        _playMode = g.defaultPlayMode;
        if (g.type == 'smart') {
          final r = await repo.rulesFor(id);
          _mode = r.matchMode;
          _conds.addAll([for (final c in r.conditions) _Cond(c.field, c.operator, c.value)]);
          _include.addAll(r.includeGroupIds);
          _exclude.addAll(r.excludeGroupIds);
          _pins = [...r.pinnedSongIds];
          _excludes = [...r.excludedSongIds];
        } else {
          final members = await repo.songsIn(id, sort: GroupSort.manual);
          for (final s in members) {
            _picked.add(s.id);
            _pickedOrder.add(s.id);
          }
        }
      }
    } else if (widget.type == 'smart') {
      _conds.add(_Cond(RuleField.artist, RuleOperator.equals, ''));
    }
    if (!mounted) return;
    setState(() => _loaded = true);
    _schedulePreview();
  }

  SmartRules _rules() => SmartRules(
        matchMode: _mode,
        conditions: [
          for (final c in _conds)
            if (isConditionComplete(c.field, c.operator, c.value)) RuleCondition(c.field, c.operator, c.value),
        ],
        includeGroupIds: _include,
        excludeGroupIds: _exclude,
        pinnedSongIds: _pins,
        excludedSongIds: _excludes,
      );

  /// Live preview re-runs the compiled query 300 ms after the last edit
  /// (TP §5.2).
  void _schedulePreview() {
    if (!_isSmart) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final p = await ref.read(groupRepositoryProvider).preview(_rules());
      if (mounted) setState(() => _preview = p);
    });
  }

  Future<void> _save() async {
    final repo = ref.read(groupRepositoryProvider);
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Give the group a name')));
      return;
    }
    int id;
    if (_isSmart) {
      if (_existing == null) {
        id = await repo.createSmart(name, _rules(), defaultSort: _sort, ascending: _ascending, playMode: _playMode);
      } else {
        id = _existing!.id;
        await repo.updateSmart(id, name: name, rules: _rules(), defaultSort: _sort, ascending: _ascending, playMode: _playMode);
      }
    } else if (_existing == null) {
      id = await repo.createStatic(name, songIds: _pickedOrder.where(_picked.contains).toList());
      await repo.updateSmart(id, defaultSort: _sort, playMode: _playMode);
    } else {
      id = _existing!.id;
      await repo.rename(id, name);
      final current = (await repo.songsIn(id, sort: GroupSort.manual)).map((s) => s.id).toSet();
      for (final gone in current.difference(_picked)) {
        await repo.removeSong(id, gone);
      }
      await repo.addSongs(id, _pickedOrder.where((s) => _picked.contains(s) && !current.contains(s)).toList());
    }
    if (!mounted) return;
    if (widget.groupId == null) {
      context.pushReplacement('/group/$id');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final title = _existing == null ? (_isSmart ? 'New smart group' : 'New static group') : 'Edit ${_existing!.name}';
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [TextButton(onPressed: _save, child: const Text('Save'))]),
      body: _isSmart ? _smartBody() : _staticBody(),
      bottomNavigationBar: _isSmart ? _previewFooter() : null,
    );
  }

  // --- static -------------------------------------------------------------------------

  Widget _staticBody() {
    final songsAsync = ref.watch(songsProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Group name', border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Find songs to add', border: OutlineInputBorder(), isDense: true),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ]),
      ),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text('${_picked.length} selected'))),
      Expanded(
        child: songsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (songs) {
            final shown = _search.isEmpty
                ? songs
                : songs.where((s) => '${s.title} ${s.artist} ${s.album}'.toLowerCase().contains(_search)).toList();
            return ListView.builder(
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final s = shown[i];
                return CheckboxListTile(
                  value: _picked.contains(s.id),
                  title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${s.artist} · ${s.album}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _picked.add(s.id);
                      if (!_pickedOrder.contains(s.id)) _pickedOrder.add(s.id);
                    } else {
                      _picked.remove(s.id);
                    }
                  }),
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  // --- smart --------------------------------------------------------------------------------

  Widget _smartBody() {
    final groups = ref.watch(groupSummariesProvider).value ?? const [];
    String nameOf(int id) => groups.where((g) => g.group.id == id).firstOrNull?.group.name ?? 'Group #$id';
    return ListView(padding: const EdgeInsets.all(12), children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Group name', border: OutlineInputBorder()), textCapitalization: TextCapitalization.sentences),
      const SizedBox(height: 16),
      Row(children: [
        const Text('Match '),
        DropdownButton<MatchMode>(
          value: _mode,
          items: const [DropdownMenuItem(value: MatchMode.all, child: Text('all')), DropdownMenuItem(value: MatchMode.any, child: Text('any'))],
          onChanged: (v) => setState(() {
            _mode = v!;
            _schedulePreview();
          }),
        ),
        const Text(' of the following:'),
      ]),
      for (var i = 0; i < _conds.length; i++) _conditionCard(i),
      Wrap(spacing: 8, children: [
        ActionChip(avatar: const Icon(Icons.add, size: 18), label: const Text('Add condition'), onPressed: () => setState(() {
          _conds.add(_Cond(RuleField.artist, RuleOperator.equals, ''));
        })),
        ActionChip(avatar: const Icon(Icons.add_circle_outline, size: 18), label: const Text('Include group'), onPressed: () => _pickGroup(include: true)),
        ActionChip(avatar: const Icon(Icons.remove_circle_outline, size: 18), label: const Text('Exclude group'), onPressed: () => _pickGroup(include: false)),
      ]),
      if (_include.isNotEmpty || _exclude.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: [
          for (final id in _include) InputChip(avatar: const Icon(Icons.add, size: 16), label: Text('Include ${nameOf(id)}'), onDeleted: () => setState(() { _include.remove(id); _schedulePreview(); })),
          for (final id in _exclude) InputChip(avatar: const Icon(Icons.remove, size: 16), label: Text('Exclude ${nameOf(id)}'), onDeleted: () => setState(() { _exclude.remove(id); _schedulePreview(); })),
        ]),
      ],
      if (_pins.isNotEmpty || _excludes.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('${_pins.length} pinned · ${_excludes.length} excluded manually', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      const Divider(height: 32),
      Row(children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: GroupSort.all.contains(_sort) ? _sort : GroupSort.title,
            decoration: const InputDecoration(labelText: 'Default sort', border: OutlineInputBorder(), isDense: true),
            items: [for (final s in GroupSort.all.where((s) => s != GroupSort.manual)) DropdownMenuItem(value: s, child: Text(_sortLabel(s)))],
            onChanged: (v) => setState(() => _sort = v!),
          ),
        ),
        IconButton(icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward), tooltip: _ascending ? 'Ascending' : 'Descending', onPressed: () => setState(() => _ascending = !_ascending)),
      ]),
      const SizedBox(height: 12),
      SegmentedButton<String>(
        segments: const [ButtonSegment(value: 'ordered', label: Text('In order'), icon: Icon(Icons.format_list_numbered)), ButtonSegment(value: 'shuffle', label: Text('Shuffle'), icon: Icon(Icons.shuffle))],
        selected: {_playMode},
        onSelectionChanged: (s) => setState(() => _playMode = s.first),
      ),
      const SizedBox(height: 120),
    ]);
  }

  String _sortLabel(String s) => switch (s) {
        GroupSort.title => 'Title',
        GroupSort.artist => 'Artist',
        GroupSort.album => 'Album',
        GroupSort.dateAdded => 'Date added',
        GroupSort.duration => 'Duration',
        GroupSort.year => 'Year',
        GroupSort.lastPlayed => 'Last played',
        GroupSort.playCount => 'Play count',
        _ => s,
      };

  Widget _conditionCard(int i) {
    final c = _conds[i];
    final suggestions = ref.watch(_distinctValuesProvider(c.field)).value ?? const [];
    return Card(
      key: c.key,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: DropdownButton<RuleField>(
                isExpanded: true,
                value: c.field,
                items: [for (final f in RuleField.values) DropdownMenuItem(value: f, child: Text(f.label))],
                onChanged: (f) => setState(() {
                  c.field = f!;
                  c.operator = f.operators.first;
                  c.value = defaultValueFor(f, c.operator);
                  _schedulePreview();
                }),
              ),
            ),
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Remove', onPressed: () => setState(() { _conds.removeAt(i); _schedulePreview(); })),
          ]),
          if (c.field.operators.length > 1)
            DropdownButton<RuleOperator>(
              value: c.field.operators.contains(c.operator) ? c.operator : c.field.operators.first,
              items: [for (final o in c.field.operators) DropdownMenuItem(value: o, child: Text(o.label))],
              onChanged: (o) => setState(() {
                c.operator = o!;
                c.value = defaultValueFor(c.field, o);
                _schedulePreview();
              }),
            ),
          const SizedBox(height: 6),
          ConditionValueEditor(
            field: c.field,
            operator: c.operator,
            value: c.value,
            suggestions: suggestions,
            onChanged: (v) => setState(() {
              c.value = v;
              _schedulePreview();
            }),
          ),
        ]),
      ),
    );
  }

  Future<void> _pickGroup({required bool include}) async {
    final all = await ref.read(groupRepositoryProvider).watchGroupRows().first;
    final choices = all.where((g) => g.id != _existing?.id && !_include.contains(g.id) && !_exclude.contains(g.id)).toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          ListTile(title: Text(include ? 'Include songs of a group' : 'Exclude songs of a group')),
          for (final g in choices) ListTile(leading: Icon(g.type == 'smart' ? Icons.auto_awesome : Icons.queue_music), title: Text(g.name), onTap: () => Navigator.pop(sheet, g.id)),
        ]),
      ),
    );
    if (picked != null) {
      setState(() {
        (include ? _include : _exclude).add(picked);
        _schedulePreview();
      });
    }
  }

  /// "Matches 84 songs" + a peek list, updating as rules change (AP §5.4).
  Widget _previewFooter() {
    final p = _preview;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        child: ExpansionTile(
          title: Text(p == null ? 'Matching…' : 'Matches ${p.count} ${p.count == 1 ? 'song' : 'songs'}', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Live preview'),
          children: [
            SizedBox(
              height: 220,
              child: p == null || p.peek.isEmpty
                  ? const Center(child: Text('No songs match yet'))
                  : ListView(children: [for (final s in p.peek) ListTile(dense: true, title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis))]),
            ),
          ],
        ),
      ),
    );
  }
}
