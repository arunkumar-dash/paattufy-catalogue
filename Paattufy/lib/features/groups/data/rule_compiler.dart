import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/rules.dart';

/// Compiles rule trees into a single Drift boolean expression over `songs`
/// (TP §5.2), so a group — however deeply it includes/excludes other groups —
/// is evaluated by one SELECT.
///
/// ```text
/// finalSet = (conditionMatches + includeGroupMembers + manualPins)
///            - excludeGroupMembers - manualExcludes
/// ```
class RuleCompiler {
  RuleCompiler(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  $SongsTable get _songs => _db.songs;

  /// Membership expression for group [groupId]. Cyclic include/exclude
  /// references are ignored (a group already being compiled contributes
  /// nothing) rather than recursing forever.
  Future<Expression<bool>> membership(int groupId, {Set<int>? visiting}) async {
    final seen = {...?visiting};
    if (!seen.add(groupId)) return const Constant(false);

    final group = await (_db.select(_db.groups)..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) return const Constant(false);

    if (group.type == 'static') {
      return _songs.id.isInQuery(
        _db.selectOnly(_db.groupStaticItems)
          ..addColumns([_db.groupStaticItems.songId])
          ..where(_db.groupStaticItems.groupId.equals(groupId)),
      );
    }

    final rules = await loadRules(groupId);
    return compileRules(
      rules,
      matchModeOverride: group.matchMode == 'any' ? MatchMode.any : MatchMode.all,
      visiting: seen,
    );
  }

  Future<SmartRules> loadRules(int groupId) async {
    final group = await (_db.select(_db.groups)..where((g) => g.id.equals(groupId))).getSingle();
    final conds = await (_db.select(_db.groupConditions)
          ..where((c) => c.groupId.equals(groupId))
          ..orderBy([(c) => OrderingTerm.asc(c.position)]))
        .get();
    final refs = await (_db.select(_db.groupRefs)..where((r) => r.groupId.equals(groupId))).get();
    final overrides = await (_db.select(_db.groupOverrides)..where((o) => o.groupId.equals(groupId))).get();
    return SmartRules(
      matchMode: group.matchMode == 'any' ? MatchMode.any : MatchMode.all,
      conditions: [
        for (final c in conds)
          RuleCondition(
            RuleField.values.byName(c.field),
            RuleOperator.values.byName(c.operator),
            RuleCondition.decodeValue(c.valueJson),
          ),
      ],
      includeGroupIds: [for (final r in refs) if (r.kind == 'include') r.refGroupId],
      excludeGroupIds: [for (final r in refs) if (r.kind == 'exclude') r.refGroupId],
      pinnedSongIds: [for (final o in overrides) if (o.kind == 'pin') o.songId],
      excludedSongIds: [for (final o in overrides) if (o.kind == 'exclude') o.songId],
    );
  }

  /// Compiles an in-memory rule set (also used for unsaved editor previews).
  Future<Expression<bool>> compileRules(
    SmartRules rules, {
    MatchMode? matchModeOverride,
    Set<int> visiting = const {},
  }) async {
    final mode = matchModeOverride ?? rules.matchMode;

    // 1. conditions
    final condExprs = [for (final c in rules.conditions) _condition(c)];
    Expression<bool> positive = condExprs.isEmpty
        ? const Constant(false)
        : (mode == MatchMode.all ? condExprs.reduce((a, b) => a & b) : condExprs.reduce((a, b) => a | b));

    // 2. + included groups
    for (final id in rules.includeGroupIds) {
      positive = positive | await membership(id, visiting: visiting);
    }
    // 3. + manual pins
    if (rules.pinnedSongIds.isNotEmpty) {
      positive = positive | _songs.id.isIn(rules.pinnedSongIds);
    }

    // 4. - excluded groups
    Expression<bool> result = positive;
    for (final id in rules.excludeGroupIds) {
      result = result & (await membership(id, visiting: visiting)).not();
    }
    // 5. - manual excludes
    if (rules.excludedSongIds.isNotEmpty) {
      result = result & _songs.id.isIn(rules.excludedSongIds).not();
    }
    return result;
  }

  // --- single conditions --------------------------------------------------

  Expression<bool> _condition(RuleCondition c) {
    switch (c.field.kind) {
      case FieldKind.text:
        return _text(_textColumn(c.field), c);
      case FieldKind.number:
        return _number(c);
      case FieldKind.date:
        return _date(c);
      case FieldKind.flag:
        return _flag(c);
    }
  }

  Expression<String> _textColumn(RuleField f) => switch (f) {
        RuleField.artist => _songs.artist,
        RuleField.albumArtist => _songs.albumArtist,
        RuleField.album => _songs.album,
        RuleField.genre => _songs.genre,
        RuleField.folderPath => _songs.folderPath,
        RuleField.title => _songs.title,
        RuleField.format => _songs.format,
        _ => throw ArgumentError('not a text field: $f'),
      };

  Expression<bool> _text(Expression<String> col, RuleCondition c) {
    final lower = FunctionCallExpression<String>('lower', [col]);
    String s() => (c.value as String).toLowerCase();
    switch (c.operator) {
      case RuleOperator.equals:
        return lower.equals(s());
      case RuleOperator.notEquals:
        return lower.equals(s()).not() & col.isNotNull();
      case RuleOperator.contains:
        return FunctionCallExpression<int>('instr', [lower, Variable<String>(s())]).isBiggerThanValue(0);
      case RuleOperator.startsWith:
        final v = s();
        return FunctionCallExpression<String>('substr', [lower, const Constant(1), Constant(v.length)]).equals(v);
      case RuleOperator.isAnyOf:
        final list = [for (final v in (c.value as List)) (v as String).toLowerCase()];
        return list.isEmpty ? const Constant(false) : lower.isIn(list);
      default:
        throw ArgumentError('operator ${c.operator} invalid for text field ${c.field}');
    }
  }

  Expression<num> _numberColumn(RuleField f) => switch (f) {
        RuleField.year => _songs.year,
        // Rule values are seconds; column is milliseconds.
        RuleField.duration => _songs.durationMs,
        RuleField.playCount => CustomExpression<int>(
            'COALESCE((SELECT ps.play_count FROM play_stats ps WHERE ps.song_id = songs.id), 0)'),
        _ => throw ArgumentError('not a number field: $f'),
      };

  Expression<bool> _number(RuleCondition c) {
    final col = _numberColumn(c.field);
    final scale = c.field == RuleField.duration ? 1000 : 1;
    num n(Object? v) => (v as num) * scale;
    switch (c.operator) {
      case RuleOperator.equals:
        return col.equals(n(c.value));
      case RuleOperator.atLeast:
        return col.isBiggerOrEqualValue(n(c.value));
      case RuleOperator.atMost:
        return col.isSmallerOrEqualValue(n(c.value));
      case RuleOperator.between:
        final l = c.value as List;
        return col.isBetweenValues(n(l[0]), n(l[1]));
      default:
        throw ArgumentError('operator ${c.operator} invalid for number field ${c.field}');
    }
  }

  int get _nowSec => _clock().millisecondsSinceEpoch ~/ 1000;

  Expression<bool> _date(RuleCondition c) {
    if (c.field == RuleField.dateAdded) {
      final col = _songs.dateAdded;
      switch (c.operator) {
        case RuleOperator.inLastDays:
          return col.isBiggerOrEqualValue(_nowSec - (c.value as num).toInt() * 86400);
        case RuleOperator.atLeast:
          return col.isBiggerOrEqualValue((c.value as num).toInt());
        case RuleOperator.atMost:
          return col.isSmallerOrEqualValue((c.value as num).toInt());
        case RuleOperator.between:
          final l = c.value as List;
          return col.isBetweenValues((l[0] as num).toInt(), (l[1] as num).toInt());
        default:
          throw ArgumentError('operator ${c.operator} invalid for date field');
      }
    }
    // lastPlayed: stored as a DateTime in play_stats.
    final ps = _db.playStats;
    Expression<bool> played(Expression<bool> Function($PlayStatsTable) where) => _songs.id.isInQuery(
          _db.selectOnly(ps)
            ..addColumns([ps.songId])
            ..where(where(ps)),
        );
    DateTime at(Object? v) => DateTime.fromMillisecondsSinceEpoch((v as num).toInt() * 1000);
    switch (c.operator) {
      case RuleOperator.inLastDays:
        final since = _clock().subtract(Duration(days: (c.value as num).toInt()));
        return played((t) => t.lastPlayedAt.isBiggerOrEqualValue(since));
      case RuleOperator.atLeast:
        return played((t) => t.lastPlayedAt.isBiggerOrEqualValue(at(c.value)));
      case RuleOperator.atMost:
        return played((t) => t.lastPlayedAt.isSmallerOrEqualValue(at(c.value)));
      case RuleOperator.between:
        final l = c.value as List;
        return played((t) => t.lastPlayedAt.isBetweenValues(at(l[0]), at(l[1])));
      default:
        throw ArgumentError('operator ${c.operator} invalid for date field');
    }
  }

  Expression<bool> _flag(RuleCondition c) {
    // `favourite` is the only flag field.
    final ps = _db.playStats;
    return _songs.id.isInQuery(
      _db.selectOnly(ps)
        ..addColumns([ps.songId])
        ..where(ps.favourite.equals(true)),
    );
  }
}
