import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'content/content_loader.dart';
import 'content/content_models.dart';
import 'content/content_scope.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_scope.dart';
import 'shell/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load();
  final content = await ContentLoader().load();
  _logContent(content);
  runApp(PkidzApp(settings: settings, content: content));
}

/// Phase 2 smoke output: confirms what the loader found at startup.
void _logContent(ContentLibrary content) {
  if (!kDebugMode) return;
  debugPrint('Loaded ${content.categories.length} content categories:');
  for (final c in content.categories) {
    final withImages = c.playableItems.length;
    debugPrint(
        '  ${c.name} ("${c.displayName}"): ${c.items.length} items, '
        '$withImages with images');
  }
}

class PkidzApp extends StatelessWidget {
  const PkidzApp({super.key, required this.settings, required this.content});

  final SettingsController settings;
  final ContentLibrary content;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      controller: settings,
      child: ContentScope(
        library: content,
        child: MaterialApp(
          title: 'p-KidZ',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
