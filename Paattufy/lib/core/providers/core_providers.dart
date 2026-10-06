import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// The single app database (TP §4). Overridden in tests with an in-memory one.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.onDisk();
  ref.onDispose(db.close);
  return db;
});
