import 'package:flutter/material.dart';

import '../../content/content_scope.dart';
import '../../settings/settings.dart';
import '../../settings/settings_scope.dart';
import '../../theme/palette.dart';

/// Stavning settings: active category + difficulty (SPEC.md §10). Built into
/// the module per the phased plan; the parent gate that guards it arrives in
/// Phase 6.
Future<void> showStavningSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.background,
    showDragHandle: true,
    builder: (_) => const _StavningSettingsSheet(),
  );
}

const _difficultyLabels = {
  StavningDifficulty.easy: 'Lätt',
  StavningDifficulty.medium: 'Medel',
  StavningDifficulty.hard: 'Svår',
};

class _StavningSettingsSheet extends StatelessWidget {
  const _StavningSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);
    final library = ContentScope.of(context);
    final settings = controller.settings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stavning-inställningar',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          const Text('Kategori', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final category in library.categories)
                ChoiceChip(
                  label: Text(
                      '${category.displayName} (${category.playableItems.length})'),
                  selected: settings.stavningCategory == category.name,
                  selectedColor: Palette.primary,
                  onSelected: (_) => controller.update(
                      settings.copyWith(stavningCategory: category.name)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Svårighetsgrad', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final level in StavningDifficulty.values)
                ChoiceChip(
                  label: Text(_difficultyLabels[level]!),
                  selected: settings.stavningDifficulty == level,
                  selectedColor: Palette.primary,
                  onSelected: (_) => controller
                      .update(settings.copyWith(stavningDifficulty: level)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Bokstäverna visas svagt som ledtråd: Lätt alla · Medel varannan · '
            'Svår inga. Barnet skriver alltid varje bokstav själv.',
            style: TextStyle(fontSize: 14, color: Palette.text),
          ),
        ],
      ),
    );
  }
}
