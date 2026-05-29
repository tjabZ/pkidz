import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:pkidz/content/content_models.dart';
import 'package:pkidz/modules/stavning/stavning_word.dart';
import 'package:pkidz/modules/stavning/word_generator.dart';
import 'package:pkidz/settings/settings.dart';

ContentItem _item(String key, [String? word]) => ContentItem(
      key: key,
      displayWord: word ?? key,
      imagePath: 'assets/content/djur/$key.png',
      imageAvailable: true,
    );

void main() {
  group('StavningWord', () {
    test('lowercases the display word into single letters', () {
      final w = StavningWord('Häst');
      expect(w.display, 'häst');
      expect(w.letters, ['h', 'ä', 's', 't']);
      expect(w.length, 4);
    });

    test('easy hints every letter', () {
      // b a m s e -> all five shown faintly
      expect(StavningWord('bamse').hintIndices(StavningDifficulty.easy),
          {0, 1, 2, 3, 4});
    });

    test('hard hints no letters', () {
      expect(
          StavningWord('bamse').hintIndices(StavningDifficulty.hard), isEmpty);
    });

    test('medium hints alternating letters from the first', () {
      // b a m s e -> b _ m _ e
      expect(StavningWord('bamse').hintIndices(StavningDifficulty.medium),
          {0, 2, 4});
      // h ä s t -> h _ s _
      expect(StavningWord('häst').hintIndices(StavningDifficulty.medium),
          {0, 2});
    });
  });

  group('WordGenerator', () {
    final items = [_item('hund'), _item('katt'), _item('ko'), _item('val')];

    test('canPlay needs at least one item', () {
      expect(WordGenerator.canPlay(const []), isFalse);
      expect(WordGenerator.canPlay(items.take(1).toList()), isTrue);
    });

    test('next() returns null for an empty list', () {
      expect(WordGenerator(random: Random(1)).next(const []), isNull);
    });

    test('next() always returns an item from the list', () {
      final gen = WordGenerator(random: Random(5));
      for (var i = 0; i < 200; i++) {
        expect(items, contains(gen.next(items)));
      }
    });

    test('avoid is not repeated when alternatives exist', () {
      final gen = WordGenerator(random: Random(9));
      for (var i = 0; i < 200; i++) {
        final first = gen.next(items)!;
        final second = gen.next(items, avoid: first)!;
        expect(second.key, isNot(first.key));
      }
    });

    test('avoid is returned anyway when it is the only item', () {
      final gen = WordGenerator(random: Random(2));
      final only = [_item('ensam')];
      expect(gen.next(only, avoid: only.first)!.key, 'ensam');
    });
  });
}
