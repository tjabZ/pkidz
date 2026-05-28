import 'package:flutter/material.dart';

import '../../content/content_scope.dart';
import '../../settings/settings_scope.dart';
import '../../theme/palette.dart';

/// Bildquiz settings: pick the active category (SPEC.md §10). Parent gate
/// arrives in Phase 6.
Future<void> showBildquizSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.background,
    showDragHandle: true,
    builder: (_) => const _BildquizSettingsSheet(),
  );
}

class _BildquizSettingsSheet extends StatelessWidget {
  const _BildquizSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);
    final library = ContentScope.of(context);
    final active = controller.settings.bildquizCategory;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bildquiz-inställningar',
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
                  selected: active == category.name,
                  selectedColor: Palette.primary,
                  onSelected: (_) => controller.update(
                      controller.settings.copyWith(bildquizCategory: category.name)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Siffran visar hur många bilder kategorin har.',
            style: TextStyle(fontSize: 14, color: Palette.text),
          ),
        ],
      ),
    );
  }
}
