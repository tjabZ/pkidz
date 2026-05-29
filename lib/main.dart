import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'content/content_loader.dart';
import 'content/content_models.dart';
import 'content/content_scope.dart';
import 'parental/lock_gate.dart';
import 'parental/screen_time_controller.dart';
import 'parental/screen_time_scope.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_scope.dart';
import 'shell/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load();
  final content = await ContentLoader().load();
  _logContent(content);
  final screenTime = ScreenTimeController(
      limitMinutes: settings.settings.screenTimeLimitMinutes);
  runApp(PkidzApp(
      settings: settings, content: content, screenTime: screenTime));
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
  const PkidzApp({
    super.key,
    required this.settings,
    required this.content,
    required this.screenTime,
  });

  final SettingsController settings;
  final ContentLibrary content;
  final ScreenTimeController screenTime;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      controller: settings,
      child: ContentScope(
        library: content,
        child: ScreenTimeScope(
          controller: screenTime,
          child: MaterialApp(
            title: 'p-KidZ',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            home: const HomeScreen(),
            builder: (context, child) => LockGate(child: child!),
          ),
        ),
      ),
    );
  }
}
