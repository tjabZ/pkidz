import 'dart:math';

import '../../content/content_models.dart';

/// Picks the next word to spell from a category's playable (image-backed)
/// items, avoiding an immediate repeat when possible (SPEC.md §8). Mirrors
/// Bildquiz's [QuizGenerator] avoid-repeat behaviour.
class WordGenerator {
  WordGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Spelling needs at least one image-backed item to show.
  static bool canPlay(List<ContentItem> items) => items.isNotEmpty;

  /// A random item, never equal to [avoid] when another choice exists.
  ContentItem? next(List<ContentItem> items, {ContentItem? avoid}) {
    if (items.isEmpty) return null;
    final pool = items.where((i) => i.key != avoid?.key).toList();
    final chooseFrom = pool.isEmpty ? items : pool;
    return chooseFrom[_random.nextInt(chooseFrom.length)];
  }
}
