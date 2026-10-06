import 'dart:async';

import 'package:drift/drift.dart';

/// Tests deliberately open several independent in-memory databases (e.g. "old
/// install" vs "fresh install"); each has its own executor, so drift's
/// multiple-instance warning is noise here.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
