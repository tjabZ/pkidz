import 'package:flutter/material.dart';

import '../shell/module_scaffold.dart';
import 'module_placeholder.dart';

class BildquizScreen extends StatelessWidget {
  const BildquizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Bildquiz',
      child:
          ModulePlaceholder(icon: Icons.image_rounded, label: 'Bildquiz'),
    );
  }
}
