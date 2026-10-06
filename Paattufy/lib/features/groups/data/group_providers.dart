import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/entities.dart';
import '../../../core/providers/core_providers.dart';
import '../../library/data/library_providers.dart';
import 'group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepository(ref.watch(databaseProvider), ref.watch(libraryRepositoryProvider)),
);

final groupSummariesProvider = StreamProvider<List<GroupSummary>>(
  (ref) => ref.watch(groupRepositoryProvider).watchSummaries(),
);

/// Members of a group in its own default order.
final groupSongsProvider = StreamProvider.family<List<Song>, int>(
  (ref, id) => ref.watch(groupRepositoryProvider).watchSongsIn(id),
);

final groupByIdProvider = FutureProvider.family<SongGroup?, int>(
  (ref, id) => ref.watch(groupRepositoryProvider).groupById(id),
);
