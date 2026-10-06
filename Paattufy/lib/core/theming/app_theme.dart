import 'package:flutter/material.dart';

/// Seed-colour presets (AP §3.7b). Index doubles as the launcher-icon
/// colourway (AP §7.3: 9 colourways), so theme and icon can match.
class SeedPreset {
  const SeedPreset(this.name, this.color);
  final String name;
  final Color color;
}

const List<SeedPreset> seedPresets = [
  SeedPreset('Electric purple', Color(0xFF8B3DFF)),
  SeedPreset('Ocean blue', Color(0xFF1E6BFF)),
  SeedPreset('Teal', Color(0xFF00A8A8)),
  SeedPreset('Emerald', Color(0xFF12B76A)),
  SeedPreset('Amber', Color(0xFFF5A300)),
  SeedPreset('Sunset orange', Color(0xFFFF6A2B)),
  SeedPreset('Crimson', Color(0xFFE5243B)),
  SeedPreset('Rose', Color(0xFFFF4D9D)),
  SeedPreset('Slate', Color(0xFF5B6B8C)),
];

/// Material 3 theme built from a seed colour (TP §5.8). Dark-first: the dark
/// scheme pushes surfaces towards near-black.
ThemeData buildTheme(Color seed, Brightness brightness) {
  var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  if (brightness == Brightness.dark) {
    scheme = scheme.copyWith(
      surface: const Color(0xFF0B0B0F),
      surfaceContainerLowest: const Color(0xFF060609),
      surfaceContainerLow: const Color(0xFF121218),
      surfaceContainer: const Color(0xFF16161D),
      surfaceContainerHigh: const Color(0xFF1C1C25),
      surfaceContainerHighest: const Color(0xFF23232E),
    );
  }
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final text = base.textTheme;
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium:
          text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 3,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}
