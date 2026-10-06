import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paattufy/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults match the plan (dark, purple seed, preserve-pitch off)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    final s = AppSettings.load(p);
    expect(s.themeMode, ThemeMode.dark);
    expect(s.themeSeedColor, 0xFF8B3DFF);
    expect(s.preservePitch, isFalse);
    expect(s.skipBackWindowMs, 3000);
    expect(s.volumeNormalisation, isFalse);
    expect(s.downloadCatalogueUrl, contains('paattufy-catalogue'));
  });

  test('save/load round-trips and json merge ignores bad types', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    final s = const AppSettings().copyWith(
      themeMode: ThemeMode.light,
      suggestionMode: SuggestionMode.metadata,
      lyricsProviderOrder: ['a', 'b'],
      defaultSpeed: 1.25,
    );
    await s.save(p);
    final back = AppSettings.load(p);
    expect(back.themeMode, ThemeMode.light);
    expect(back.suggestionMode, SuggestionMode.metadata);
    expect(back.lyricsProviderOrder, ['a', 'b']);
    expect(back.defaultSpeed, 1.25);

    final merged = back.mergeJson({'defaultSpeed': 'oops', 'crossfade': true});
    expect(merged.defaultSpeed, 1.25);
    expect(merged.crossfade, isTrue);
  });
}
