import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Shared chrome for every module screen: a calm app bar with the module
/// title and an always-visible Home button that returns to the home screen
/// (SPEC.md §5).
class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            iconSize: 34,
            tooltip: 'Hem',
            icon: const Icon(Icons.home_rounded),
            color: Palette.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(title, style: const TextStyle(fontSize: 26)),
      ),
      body: SafeArea(child: child),
    );
  }
}
