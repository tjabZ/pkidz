/// A single learnable item: one image + the Swedish word it represents.
class ContentItem {
  const ContentItem({
    required this.key,
    required this.displayWord,
    required this.imagePath,
    required this.imageAvailable,
  });

  /// ASCII filename without extension (e.g. `hast`) — the on-disk identity.
  final String key;

  /// Swedish word shown in the UI and typed in Stavning (e.g. `häst`).
  final String displayWord;

  /// Asset path of the image (e.g. `assets/content/djur/hast.png`).
  final String imagePath;

  /// Whether the image file is actually bundled. False until the user drops
  /// the PNG in; modules should skip items whose image isn't available.
  final bool imageAvailable;
}

/// A content category, backed by one `assets/content/<name>/` folder.
class Category {
  const Category({
    required this.name,
    required this.displayName,
    required this.items,
  });

  /// Folder name, lowercase ASCII (e.g. `djur`).
  final String name;

  /// Swedish display name from `_labels.json` (e.g. `Djur`).
  final String displayName;

  final List<ContentItem> items;

  /// Items whose image is bundled — the ones modules can actually use.
  List<ContentItem> get playableItems =>
      items.where((i) => i.imageAvailable).toList();
}

/// All loaded categories, queryable by name.
class ContentLibrary {
  const ContentLibrary(this.categories);

  final List<Category> categories;

  Category? byName(String name) {
    for (final category in categories) {
      if (category.name == name) return category;
    }
    return null;
  }

  bool get isEmpty => categories.isEmpty;
}
