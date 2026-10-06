import 'dart:convert';

/// Fields a smart-group condition can test (AP §3.3) plus play-history fields
/// that power the built-in groups and "Never played"-style groups (AP §8.4).
enum RuleField {
  artist,
  albumArtist,
  album,
  genre,
  year,
  dateAdded,
  duration,
  folderPath,
  title,
  format,
  favourite,
  playCount,
  lastPlayed,
}

enum RuleOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  isAnyOf,
  between,
  atLeast,
  atMost,
  inLastDays,
  isTrue,
}

enum FieldKind { text, number, date, flag }

extension RuleFieldInfo on RuleField {
  FieldKind get kind => switch (this) {
        RuleField.artist ||
        RuleField.albumArtist ||
        RuleField.album ||
        RuleField.genre ||
        RuleField.folderPath ||
        RuleField.title ||
        RuleField.format =>
          FieldKind.text,
        RuleField.year || RuleField.duration || RuleField.playCount => FieldKind.number,
        RuleField.dateAdded || RuleField.lastPlayed => FieldKind.date,
        RuleField.favourite => FieldKind.flag,
      };

  String get label => switch (this) {
        RuleField.artist => 'Artist',
        RuleField.albumArtist => 'Album artist',
        RuleField.album => 'Album',
        RuleField.genre => 'Genre',
        RuleField.year => 'Release year',
        RuleField.dateAdded => 'Date added',
        RuleField.duration => 'Duration (seconds)',
        RuleField.folderPath => 'Folder',
        RuleField.title => 'Title',
        RuleField.format => 'File format',
        RuleField.favourite => 'Favourite',
        RuleField.playCount => 'Play count',
        RuleField.lastPlayed => 'Last played',
      };

  /// Operators that make sense for this field, first = default.
  List<RuleOperator> get operators => switch (kind) {
        FieldKind.text => const [
            RuleOperator.equals,
            RuleOperator.contains,
            RuleOperator.startsWith,
            RuleOperator.notEquals,
            RuleOperator.isAnyOf,
          ],
        FieldKind.number => const [
            RuleOperator.equals,
            RuleOperator.between,
            RuleOperator.atLeast,
            RuleOperator.atMost,
          ],
        FieldKind.date => const [
            RuleOperator.inLastDays,
            RuleOperator.between,
            RuleOperator.atLeast,
            RuleOperator.atMost,
          ],
        FieldKind.flag => const [RuleOperator.isTrue],
      };
}

extension RuleOperatorLabel on RuleOperator {
  String get label => switch (this) {
        RuleOperator.equals => 'is',
        RuleOperator.notEquals => 'is not',
        RuleOperator.contains => 'contains',
        RuleOperator.startsWith => 'starts with',
        RuleOperator.isAnyOf => 'is any of',
        RuleOperator.between => 'is between',
        RuleOperator.atLeast => 'is at least',
        RuleOperator.atMost => 'is at most',
        RuleOperator.inLastDays => 'in the last (days)',
        RuleOperator.isTrue => 'is set',
      };
}

/// One `[field] [operator] [value]` row. [value] is a `String`, `num`,
/// `List<String>` (isAnyOf) or `List<num>` (between), by field/operator.
class RuleCondition {
  const RuleCondition(this.field, this.operator, this.value);
  final RuleField field;
  final RuleOperator operator;
  final Object? value;

  Map<String, Object?> toJson() =>
      {'field': field.name, 'operator': operator.name, 'value': value};

  static RuleCondition fromJson(Map<String, Object?> j) => RuleCondition(
        RuleField.values.byName(j['field'] as String),
        RuleOperator.values.byName(j['operator'] as String),
        j['value'],
      );

  String encodeValue() => jsonEncode(value);
  static Object? decodeValue(String s) => jsonDecode(s);

  @override
  bool operator ==(Object other) =>
      other is RuleCondition &&
      other.field == field &&
      other.operator == operator &&
      jsonEncode(other.value) == jsonEncode(value);
  @override
  int get hashCode => Object.hash(field, operator, jsonEncode(value));
  @override
  String toString() => '${field.name} ${operator.name} $value';
}

enum MatchMode { all, any }

/// The full rule set of a smart group (TP §5.2): conditions, include/exclude
/// other groups, and manual pin/exclude overrides.
class SmartRules {
  const SmartRules({
    this.matchMode = MatchMode.all,
    this.conditions = const [],
    this.includeGroupIds = const [],
    this.excludeGroupIds = const [],
    this.pinnedSongIds = const [],
    this.excludedSongIds = const [],
  });

  final MatchMode matchMode;
  final List<RuleCondition> conditions;
  final List<int> includeGroupIds;
  final List<int> excludeGroupIds;
  final List<String> pinnedSongIds;
  final List<String> excludedSongIds;

  SmartRules copyWith({
    MatchMode? matchMode,
    List<RuleCondition>? conditions,
    List<int>? includeGroupIds,
    List<int>? excludeGroupIds,
    List<String>? pinnedSongIds,
    List<String>? excludedSongIds,
  }) =>
      SmartRules(
        matchMode: matchMode ?? this.matchMode,
        conditions: conditions ?? this.conditions,
        includeGroupIds: includeGroupIds ?? this.includeGroupIds,
        excludeGroupIds: excludeGroupIds ?? this.excludeGroupIds,
        pinnedSongIds: pinnedSongIds ?? this.pinnedSongIds,
        excludedSongIds: excludedSongIds ?? this.excludedSongIds,
      );

  /// JSON shape from TP §5.2 (used for import/export and preview diffing only;
  /// the database rows are the source of truth).
  Map<String, Object?> toJson() => {
        'matchMode': matchMode.name,
        'conditions': [for (final c in conditions) c.toJson()],
        'includeGroupIds': includeGroupIds,
        'excludeGroupIds': excludeGroupIds,
        'pinnedSongIds': pinnedSongIds,
        'excludedSongIds': excludedSongIds,
      };

  static SmartRules fromJson(Map<String, Object?> j) => SmartRules(
        matchMode: MatchMode.values.byName((j['matchMode'] as String?) ?? 'all'),
        conditions: [
          for (final c in (j['conditions'] as List? ?? const []))
            RuleCondition.fromJson((c as Map).cast<String, Object?>()),
        ],
        includeGroupIds: [for (final i in (j['includeGroupIds'] as List? ?? const [])) (i as num).toInt()],
        excludeGroupIds: [for (final i in (j['excludeGroupIds'] as List? ?? const [])) (i as num).toInt()],
        pinnedSongIds: [for (final i in (j['pinnedSongIds'] as List? ?? const [])) i as String],
        excludedSongIds: [for (final i in (j['excludedSongIds'] as List? ?? const [])) i as String],
      );
}
