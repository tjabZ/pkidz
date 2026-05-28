import 'package:flutter/material.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_scope.dart';
import 'shell/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load();
  runApp(PkidzApp(settings: settings));
}

class PkidzApp extends StatelessWidget {
  const PkidzApp({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      controller: settings,
      child: MaterialApp(
        title: 'p-KidZ',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
