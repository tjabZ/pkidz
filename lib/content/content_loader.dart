import 'dart:convert';

import 'package:flutter/services.dart';

import 'content_models.dart';

/// Loads bundled content at startup (SPEC.md §9).
///
/// Discovery is data-driven: every `assets/content/<category>/_labels.json`
/// declared in pubspec is found via the asset manifest, so adding a category
/// needs no code changes.
class ContentLoader {
  ContentLoader({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  final AssetBundle bundle;

  static const _contentRoot = 'assets/content/';
  static const _labelsFile = '_labels.json';

  Future<ContentLibrary> load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final assetPaths = manifest.listAssets().toSet();

    final labelPaths = assetPaths
        .where((p) => p.startsWith(_contentRoot) && p.endsWith('/$_labelsFile'))
        .toList()
      ..sort();

    final categories = <Category>[];
    for (final labelPath in labelPaths) {
      final folderName = labelPath
          .substring(_contentRoot.length, labelPath.length - _labelsFile.length)
          .replaceAll('/', '');
      final labelsJson = await bundle.loadString(labelPath);
      categories.add(parseCategory(
        folderName: folderName,
        labelsJson: labelsJson,
        availableAssetPaths: assetPaths,
      ));
    }
    return ContentLibrary(categories);
  }

  /// Pure parse step: turns one folder's `_labels.json` into a [Category].
  /// [availableAssetPaths] is used to flag which item images are bundled.
  static Category parseCategory({
    required String folderName,
    required String labelsJson,
    required Set<String> availableAssetPaths,
  }) {
    final data = jsonDecode(labelsJson) as Map<String, dynamic>;
    final displayName = (data['category_display'] as String?) ?? folderName;
    final rawItems = (data['items'] as Map<String, dynamic>?) ?? const {};

    final items = <ContentItem>[];
    rawItems.forEach((key, value) {
      final imagePath = '$_contentRoot$folderName/$key.png';
      items.add(ContentItem(
        key: key,
        displayWord: value as String,
        imagePath: imagePath,
        imageAvailable: availableAssetPaths.contains(imagePath),
      ));
    });
    items.sort((a, b) => a.key.compareTo(b.key));

    return Category(
      name: folderName,
      displayName: displayName,
      items: items,
    );
  }
}
