import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Temporary body shown inside each module before the real game is built
/// (Phases 3–5). Confirms routing and the module title.
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 96, color: Palette.primary),
          const SizedBox(height: 24),
          Text(
            '$label kommer snart',
            style: const TextStyle(fontSize: 24, color: Palette.text),
          ),
        ],
      ),
    );
  }
}
