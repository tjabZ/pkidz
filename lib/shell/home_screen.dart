import 'package:flutter/material.dart';

import '../modules/bildquiz_screen.dart';
import '../modules/klocka/klocka_screen.dart';
import '../modules/stavning_screen.dart';
import '../theme/palette.dart';

/// Home shell: three large tiles, one per module (SPEC.md §5).
/// Layout reflows between portrait (column) and landscape (row).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_TileData>[
      _TileData('Klocka', Icons.schedule_rounded, Palette.primary,
          (_) => const KlockaScreen()),
      _TileData('Bildquiz', Icons.image_rounded, Palette.secondary,
          (_) => const BildquizScreen()),
      _TileData('Stavning', Icons.keyboard_rounded, Palette.accent,
          (_) => const StavningScreen()),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'p-KidZ',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 44,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    final children = [
                      for (final tile in tiles)
                        Expanded(child: _HomeTile(data: tile)),
                    ];
                    const gap = SizedBox(width: 20, height: 20);
                    final spaced = <Widget>[];
                    for (var i = 0; i < children.length; i++) {
                      if (i > 0) spaced.add(gap);
                      spaced.add(children[i]);
                    }
                    return orientation == Orientation.portrait
                        ? Column(children: spaced)
                        : Row(children: spaced);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileData {
  const _TileData(this.label, this.icon, this.color, this.builder);

  final String label;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: data.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: data.builder),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 88, color: Palette.text),
              const SizedBox(height: 16),
              Text(
                data.label,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
