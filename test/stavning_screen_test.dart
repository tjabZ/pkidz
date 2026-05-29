import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pkidz/content/content_models.dart';
import 'package:pkidz/content/content_scope.dart';
import 'package:pkidz/modules/stavning/stavning_screen.dart';
import 'package:pkidz/settings/settings.dart';
import 'package:pkidz/settings/settings_controller.dart';
import 'package:pkidz/settings/settings_scope.dart';
import 'package:pkidz/theme/palette.dart';

ContentItem _item(String key, String word) => ContentItem(
      key: key,
      displayWord: word,
      imagePath: 'assets/content/djur/$key.png',
      imageAvailable: true,
    );

// A single real bundled image so the chosen word is deterministically "mus".
final _djur = Category(
  name: 'djur',
  displayName: 'Djur',
  items: [_item('mus', 'Mus')],
);

Widget _app(SettingsController controller) => SettingsScope(
      controller: controller,
      child: ContentScope(
        library: ContentLibrary([_djur]),
        child: const MaterialApp(home: StavningScreen()),
      ),
    );

// Letter cells turn to the correct (green) fill once the word is solved.
Finder _greenCells() => find.byWidgetPredicate((w) =>
    w is Container &&
    w.decoration is BoxDecoration &&
    (w.decoration as BoxDecoration).color == Palette.correctBg);

void main() {
  testWidgets('per-keystroke spelling: wrong key is ignored, correct word solves',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await SettingsController.load(); // default category: djur
    // Hard mode: boxes stay blank, so 'm'/'u'/'s' exist only on the keyboard
    // (no faint ghost letters to make find.text ambiguous).
    await controller
        .update(controller.settings.copyWith(stavningDifficulty: StavningDifficulty.hard));

    await tester.pumpWidget(_app(controller));
    await tester.pump();

    // Nothing solved yet.
    expect(_greenCells(), findsNothing);

    // A wrong key must not commit or advance — still nothing solved.
    await tester.tap(find.text('a'));
    await tester.pump(const Duration(milliseconds: 400)); // let the flash clear
    expect(_greenCells(), findsNothing);

    // Spell "mus": each next letter exists only on the keyboard at tap time.
    for (final letter in ['m', 'u', 's']) {
      await tester.tap(find.text(letter));
      await tester.pump();
    }

    // Word complete -> every letter cell flips to the green fill.
    expect(_greenCells(), findsWidgets);

    // Flush the 900ms next-word timer so it doesn't leak past the test.
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
