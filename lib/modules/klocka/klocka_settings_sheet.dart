import 'package:flutter/material.dart';

import '../../settings/settings.dart';
import '../../settings/settings_scope.dart';
import '../../theme/palette.dart';

/// Opens the Klocka settings panel (difficulty + answer method). Built into
/// the module per the phased plan; the parent gate that guards it arrives in
/// Phase 6.
Future<void> showKlockaSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.background,
    showDragHandle: true,
    builder: (_) => const _KlockaSettingsSheet(),
  );
}

const _difficultyLabels = {
  1: 'Hela timmar',
  2: 'Halvtimmar',
  3: 'Kvart',
  4: 'Avancerat',
};

class _KlockaSettingsSheet extends StatelessWidget {
  const _KlockaSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);
    final settings = controller.settings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Klocka-inställningar',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          const Text('Svårighetsgrad', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final level in const [1, 2, 3, 4])
                ChoiceChip(
                  label: Text('$level · ${_difficultyLabels[level]}'),
                  selected: settings.klockaDifficulty == level,
                  selectedColor: Palette.primary,
                  onSelected: (_) => controller
                      .update(settings.copyWith(klockaDifficulty: level)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Svarssätt', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Flerval'),
                selected: settings.klockaAnswerMethod ==
                    KlockaAnswerMethod.multipleChoice,
                selectedColor: Palette.primary,
                onSelected: (_) => controller.update(settings.copyWith(
                    klockaAnswerMethod: KlockaAnswerMethod.multipleChoice)),
              ),
              ChoiceChip(
                label: const Text('Rulla siffror'),
                selected:
                    settings.klockaAnswerMethod == KlockaAnswerMethod.freeText,
                selectedColor: Palette.primary,
                onSelected: (_) => controller.update(settings.copyWith(
                    klockaAnswerMethod: KlockaAnswerMethod.freeText)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
