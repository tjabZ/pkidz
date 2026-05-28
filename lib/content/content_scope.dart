import 'package:flutter/widgets.dart';

import 'content_models.dart';

/// Exposes the loaded [ContentLibrary] to the widget tree. Content is loaded
/// once at startup and is immutable, so a plain [InheritedWidget] is enough.
class ContentScope extends InheritedWidget {
  const ContentScope({
    super.key,
    required this.library,
    required super.child,
  });

  final ContentLibrary library;

  static ContentLibrary of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ContentScope>();
    assert(scope != null, 'No ContentScope found in the widget tree');
    return scope!.library;
  }

  @override
  bool updateShouldNotify(ContentScope oldWidget) =>
      library != oldWidget.library;
}
