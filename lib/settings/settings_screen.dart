import 'package:flutter/material.dart';

import '../modules/bildquiz/bildquiz_settings_sheet.dart';
import '../modules/klocka/klocka_settings_sheet.dart';
import '../modules/stavning/stavning_settings_sheet.dart';
import '../parental/pin_gate.dart';
import '../parental/screen_time_controller.dart';
import '../parental/screen_time_scope.dart';
import '../theme/palette.dart';
import 'settings_controller.dart';
import 'settings_scope.dart';

/// Parent settings home (SPEC.md §10), reached via the PIN-gated home gear.
/// Global parental controls live here; per-module options reuse each module's
/// own settings sheet.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _limitOptions = [0, 5, 10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);
    final screenTime = ScreenTimeScope.of(context);
    final settings = controller.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Inställningar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionTitle('Skärmtid'),
            const Text('Tidsgräns per pass (minuter)',
                style: TextStyle(fontSize: 16, color: Palette.text)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final minutes in _limitOptions)
                  ChoiceChip(
                    label: Text(minutes == 0 ? 'Av' : '$minutes'),
                    selected: settings.screenTimeLimitMinutes == minutes,
                    selectedColor: Palette.primary,
                    onSelected: (_) {
                      controller.update(settings.copyWith(
                          screenTimeLimitMinutes: minutes));
                      screenTime.setLimit(minutes);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Räknas ner när appen startar. När tiden är slut låses appen tills '
              'förälderkoden anges.',
              style: TextStyle(fontSize: 13, color: Palette.text),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Förälderkod'),
            OutlinedButton.icon(
              icon: const Icon(Icons.pin_rounded),
              label: const Text('Byt förälderkod'),
              onPressed: () => showSetPin(context, controller),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Moduler'),
            _ModuleButton(
              icon: Icons.schedule_rounded,
              label: 'Klocka',
              onTap: () => showKlockaSettings(context),
            ),
            _ModuleButton(
              icon: Icons.image_rounded,
              label: 'Bildquiz',
              onTap: () => showBildquizSettings(context),
            ),
            _ModuleButton(
              icon: Icons.keyboard_rounded,
              label: 'Stavning',
              onTap: () => showStavningSettings(context),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Övrigt'),
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Återställ till standard'),
              onPressed: () => _confirmReset(context, controller, screenTime),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    SettingsController controller,
    ScreenTimeController screenTime,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Återställ?'),
        content: const Text(
            'Alla inställningar återställs, även förälderkoden och tidsgränsen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Avbryt')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Återställ')),
        ],
      ),
    );
    if (ok == true) {
      await controller.resetToDefaults();
      screenTime.setLimit(0);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Palette.text)),
    );
  }
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Palette.text),
        title: Text(label, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
