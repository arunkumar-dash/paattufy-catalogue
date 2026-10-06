import 'package:flutter/material.dart';

import '../domain/rules.dart';

/// Adaptive value editors for a rule condition (AP §5.4): artist/album →
/// searchable picker, year → number or range slider, date added → date range or
/// "last N days", duration → range, text → contains/equals.
class ConditionValueEditor extends StatelessWidget {
  const ConditionValueEditor({
    super.key,
    required this.field,
    required this.operator,
    required this.value,
    required this.onChanged,
    required this.suggestions,
  });

  final RuleField field;
  final RuleOperator operator;
  final Object? value;
  final ValueChanged<Object?> onChanged;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    switch (field.kind) {
      case FieldKind.flag:
        return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Songs marked as favourite'));
      case FieldKind.text:
        return operator == RuleOperator.isAnyOf
            ? _ChipsEditor(values: [for (final v in (value as List? ?? const [])) '$v'], suggestions: suggestions, onChanged: onChanged)
            : _SuggestField(initial: '${value ?? ''}', suggestions: suggestions, onChanged: onChanged, label: field.label);
      case FieldKind.number:
        return _numberEditor();
      case FieldKind.date:
        return _dateEditor(context);
    }
  }

  Widget _numberEditor() {
    if (operator == RuleOperator.between) {
      final l = (value as List? ?? const [0, 0]);
      if (field == RuleField.year) {
        final lo = (l[0] as num).toDouble().clamp(1950, 2035).toDouble();
        final hi = (l[1] as num).toDouble().clamp(1950, 2035).toDouble();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${lo.round()} – ${hi.round()}'),
          RangeSlider(values: RangeValues(lo, hi), min: 1950, max: 2035, divisions: 85, labels: RangeLabels('${lo.round()}', '${hi.round()}'),
              onChanged: (r) => onChanged([r.start.round(), r.end.round()])),
        ]);
      }
      return Row(children: [
        Expanded(child: _NumField(value: l[0] as num, label: 'From', onChanged: (v) => onChanged([v, l[1]]))),
        const SizedBox(width: 8),
        Expanded(child: _NumField(value: l[1] as num, label: 'To', onChanged: (v) => onChanged([l[0], v]))),
      ]);
    }
    return _NumField(value: (value as num? ?? 0), label: field.label, onChanged: onChanged);
  }

  Widget _dateEditor(BuildContext context) {
    if (operator == RuleOperator.inLastDays) {
      return _NumField(value: (value as num? ?? 30), label: 'Days', onChanged: onChanged);
    }
    String fmt(Object? secs) => DateTime.fromMillisecondsSinceEpoch(((secs as num?) ?? 0).toInt() * 1000).toString().split(' ').first;
    Future<int?> pick(Object? initial) async {
      final d = await showDatePicker(
        context: context,
        initialDate: DateTime.fromMillisecondsSinceEpoch(((initial as num?) ?? DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt() * 1000),
        firstDate: DateTime(1990),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      return d == null ? null : d.millisecondsSinceEpoch ~/ 1000;
    }

    if (operator == RuleOperator.between) {
      final l = (value as List? ?? [0, 0]);
      return Row(children: [
        Expanded(child: OutlinedButton(onPressed: () async { final v = await pick(l[0]); if (v != null) onChanged([v, l[1]]); }, child: Text(fmt(l[0])))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('to')),
        Expanded(child: OutlinedButton(onPressed: () async { final v = await pick(l[1]); if (v != null) onChanged([l[0], v]); }, child: Text(fmt(l[1])))),
      ]);
    }
    return OutlinedButton(onPressed: () async { final v = await pick(value); if (v != null) onChanged(v); }, child: Text(fmt(value)));
  }
}

/// Default value when the user picks a field/operator.
Object? defaultValueFor(RuleField field, RuleOperator op) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  switch (field.kind) {
    case FieldKind.flag:
      return true;
    case FieldKind.text:
      return op == RuleOperator.isAnyOf ? <String>[] : '';
    case FieldKind.number:
      if (op == RuleOperator.between) {
        return switch (field) { RuleField.year => [1980, 1989], RuleField.duration => [60, 300], _ => [1, 10] };
      }
      return switch (field) { RuleField.year => 2000, RuleField.duration => 180, _ => 1 };
    case FieldKind.date:
      return switch (op) {
        RuleOperator.inLastDays => 30,
        RuleOperator.between => [now - 30 * 86400, now],
        _ => now - 30 * 86400,
      };
  }
}

bool isConditionComplete(RuleField field, RuleOperator op, Object? value) {
  if (field.kind == FieldKind.text) {
    return op == RuleOperator.isAnyOf ? (value is List && value.isNotEmpty) : (value is String && value.trim().isNotEmpty);
  }
  return value != null;
}

class _NumField extends StatefulWidget {
  const _NumField({required this.value, required this.label, required this.onChanged});
  final num value;
  final String label;
  final ValueChanged<num> onChanged;
  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  late final TextEditingController _c = TextEditingController(text: _fmt(widget.value));
  static String _fmt(num n) => n == n.roundToDouble() ? '${n.round()}' : '$n';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: widget.label, isDense: true, border: const OutlineInputBorder()),
        onChanged: (v) {
          final n = num.tryParse(v);
          if (n != null) widget.onChanged(n);
        },
      );
}

class _SuggestField extends StatelessWidget {
  const _SuggestField({required this.initial, required this.suggestions, required this.onChanged, required this.label});
  final String initial;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => Autocomplete<String>(
        initialValue: TextEditingValue(text: initial),
        optionsBuilder: (v) {
          final q = v.text.trim().toLowerCase();
          if (q.isEmpty) return const Iterable<String>.empty();
          return suggestions.where((s) => s.toLowerCase().contains(q)).take(8);
        },
        onSelected: onChanged,
        fieldViewBuilder: (context, controller, focus, submit) => TextField(
          controller: controller,
          focusNode: focus,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.search, size: 18)),
        ),
      );
}

class _ChipsEditor extends StatefulWidget {
  const _ChipsEditor({required this.values, required this.suggestions, required this.onChanged});
  final List<String> values;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;
  @override
  State<_ChipsEditor> createState() => _ChipsEditorState();
}

class _ChipsEditorState extends State<_ChipsEditor> {
  final _c = TextEditingController();

  void _add(String v) {
    final t = v.trim();
    if (t.isEmpty || widget.values.contains(t)) return;
    widget.onChanged([...widget.values, t]);
    _c.clear();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, children: [
          for (final v in widget.values) InputChip(label: Text(v), onDeleted: () => widget.onChanged([...widget.values]..remove(v))),
        ]),
        Autocomplete<String>(
          optionsBuilder: (v) {
            final q = v.text.trim().toLowerCase();
            if (q.isEmpty) return const Iterable<String>.empty();
            return widget.suggestions.where((s) => s.toLowerCase().contains(q) && !widget.values.contains(s)).take(8);
          },
          onSelected: (s) {
            _add(s);
          },
          fieldViewBuilder: (context, controller, focus, submit) => TextField(
            controller: controller,
            focusNode: focus,
            onSubmitted: (v) {
              _add(v);
              controller.clear();
              focus.requestFocus();
            },
            decoration: const InputDecoration(labelText: 'Add a value, then press enter', isDense: true, border: OutlineInputBorder()),
          ),
        ),
      ]);
}
