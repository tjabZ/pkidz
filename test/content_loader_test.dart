import 'package:flutter_test/flutter_test.dart';

import 'package:pkidz/content/content_loader.dart';

void main() {
  group('parseCategory', () {
    test('maps ASCII keys to Swedish display words', () {
      final category = ContentLoader.parseCategory(
        folderName: 'djur',
        labelsJson: '''
        {
          "category_display": "Djur",
          "items": {"hast": "häst", "raev": "räv"}
        }
        ''',
        availableAssetPaths: const {},
      );

      expect(category.name, 'djur');
      expect(category.displayName, 'Djur');
      expect(category.items.map((i) => i.key), ['hast', 'raev']);
      expect(category.items.first.displayWord, 'häst');
    });

    test('flags image availability and builds the asset path', () {
      final category = ContentLoader.parseCategory(
        folderName: 'mat',
        labelsJson: '{"category_display":"Mat","items":{"apple":"äpple"}}',
        availableAssetPaths: const {'assets/content/mat/apple.png'},
      );

      final item = category.items.single;
      expect(item.imagePath, 'assets/content/mat/apple.png');
      expect(item.imageAvailable, isTrue);
      expect(category.playableItems, hasLength(1));
    });

    test('marks items without a bundled image as unavailable', () {
      final category = ContentLoader.parseCategory(
        folderName: 'mat',
        labelsJson: '{"items":{"ost":"ost"}}',
        availableAssetPaths: const {},
      );

      expect(category.items.single.imageAvailable, isFalse);
      expect(category.playableItems, isEmpty);
      expect(category.displayName, 'mat'); // falls back to folder name
    });
  });

  testWidgets('load() finds all four bundled categories', (tester) async {
    final library = await ContentLoader().load();

    expect(
      library.categories.map((c) => c.name).toList()..sort(),
      ['djur', 'familj', 'fordon', 'mat'],
    );
    expect(library.byName('djur')!.items, hasLength(10));
    expect(library.byName('familj')!.items, hasLength(7));
    expect(library.byName('djur')!.displayName, 'Djur');
  });
}
