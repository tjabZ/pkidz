import 'package:flutter/widgets.dart';

import 'screen_time_controller.dart';

/// Exposes the [ScreenTimeController] to the widget tree. Widgets that call
/// [ScreenTimeScope.of] rebuild when the lock state changes.
class ScreenTimeScope extends InheritedNotifier<ScreenTimeController> {
  const ScreenTimeScope({
    super.key,
    required ScreenTimeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ScreenTimeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ScreenTimeScope>();
    assert(scope != null, 'No ScreenTimeScope found in the widget tree');
    return scope!.notifier!;
  }
}
