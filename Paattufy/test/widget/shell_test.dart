import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

void main() {
  appTest('shell shows four tabs and switches between them', (tester, h) async {
    for (final label in ['Library', 'Groups', 'Download', 'Settings']) {
      expect(inNav(label), findsOneWidget);
    }
    expect(find.text('Kanavugal'), findsOneWidget, reason: 'Library is the first tab');
    await tester.tapAndSettle(inNav('Groups'));
    expect(find.text('Favourites'), findsOneWidget);
    await tester.tapAndSettle(inNav('Settings'));
    expect(find.text('Settings'), findsWidgets);
    await tester.tapAndSettle(inNav('Library'));
    expect(find.text('Kanavugal'), findsOneWidget);
  });

  appTest('first run goes to onboarding, not the shell', (tester, h) async {
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  }, prefs: {});
}
