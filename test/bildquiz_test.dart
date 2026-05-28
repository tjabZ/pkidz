import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:pkidz/content/content_models.dart';
import 'package:pkidz/modules/bildquiz/quiz_generator.dart';

ContentItem _item(String key) => ContentItem(
      key: key,
      displayWord: key,
      imagePath: 'assets/content/djur/$key.png',
      imageAvailable: true,
    );

final _items = [
  _item('hund'),
  _item('katt'),
  _item('hast'),
  _item('ko'),
  _item('gris'),
  _item('far'),
];

void main() {
  group('QuizGenerator', () {
    test('canPlay needs at least 4 items', () {
      expect(QuizGenerator.canPlay(_items.take(3).toList()), isFalse);
      expect(QuizGenerator.canPlay(_items.take(4).toList()), isTrue);
    });

    test('next() returns null when there are too few items', () {
      final gen = QuizGenerator(random: Random(1));
      expect(gen.next(_items.take(3).toList()), isNull);
    });

    test('next() yields 4 distinct options containing the target', () {
      final gen = QuizGenerator(random: Random(3));
      for (var i = 0; i < 100; i++) {
        final q = gen.next(_items)!;
        expect(q.options, hasLength(4));
        expect(q.options.map((o) => o.key).toSet(), hasLength(4));
        expect(q.options.map((o) => o.key), contains(q.target.key));
      }
    });

    test('avoidTarget is not reused as the answer when alternatives exist', () {
      final gen = QuizGenerator(random: Random(9));
      final first = gen.next(_items)!;
      for (var i = 0; i < 50; i++) {
        final q = gen.next(_items, avoidTarget: first.target);
        // With 6 items and 4 options, an alternative target always exists.
        expect(q!.target.key, isNot(first.target.key));
      }
    });
  });
}
