import 'package:flutter/material.dart';

import '../shell/module_scaffold.dart';
import 'module_placeholder.dart';

class KlockaScreen extends StatelessWidget {
  const KlockaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Klocka',
      child: ModulePlaceholder(icon: Icons.schedule_rounded, label: 'Klocka'),
    );
  }
}
