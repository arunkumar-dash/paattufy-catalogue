import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:paattufy/core/database/app_database.dart';
import 'package:paattufy/core/providers/core_providers.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:paattufy/features/playback/data/playback_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_audio_engine.dart';

Future<ProviderContainer> makeContainer(
  AppDatabase db,
  FakeAudioEngine engine, {
  Map<String, Object> prefs = const {},
  List<Override> extra = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    audioEngineProvider.overrideWithValue(engine),
    sharedPreferencesProvider.overrideWithValue(sp),
    ...extra,
  ]);
  return c;
}
