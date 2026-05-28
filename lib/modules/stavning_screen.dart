import 'package:flutter/material.dart';

import '../shell/module_scaffold.dart';
import 'module_placeholder.dart';

class StavningScreen extends StatelessWidget {
  const StavningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Stavning',
      child:
          ModulePlaceholder(icon: Icons.keyboard_rounded, label: 'Stavning'),
    );
  }
}
