import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pkidz/content/content_models.dart';
import 'package:pkidz/main.dart';
import 'package:pkidz/settings/settings_controller.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final settings = await SettingsController.load();
  await tester.pumpWidget(
    PkidzApp(settings: settings, content: const ContentLibrary([])),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the three module tiles', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Klocka'), findsOneWidget);
    expect(find.text('Bildquiz'), findsOneWidget);
    expect(find.text('Stavning'), findsOneWidget);
  });

  testWidgets('tapping a tile opens its module and Home returns',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Stavning'));
    await tester.pumpAndSettle();
    // The real module screen opened (module scaffold shows the Home button).
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Klocka'), findsOneWidget);
  });

  testWidgets('first launch writes default settings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await SettingsController.load();

    expect(controller.settings.klockaDifficulty, 1);
    expect(controller.settings.bildquizCategory, 'djur');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings.initialized'), true);
  });
}
