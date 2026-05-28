import 'dart:math';

import '../../content/content_models.dart';

/// One Bildquiz question: a target word and 4 image options, one of which is
/// the target (SPEC.md §7).
class Question {
  const Question({required this.options, required this.target});

  final List<ContentItem> options;
  final ContentItem target;
}

/// Builds questions from a category's playable (image-backed) items.
class QuizGenerator {
  QuizGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const int optionCount = 4;

  /// Whether [items] has enough image-backed entries to form a question.
  static bool canPlay(List<ContentItem> items) => items.length >= optionCount;

  /// Returns a fresh question, or null if there aren't enough playable items.
  /// [avoidTarget] is skipped as the answer when possible, to reduce immediate
  /// repeats.
  Question? next(List<ContentItem> items, {ContentItem? avoidTarget}) {
    if (!canPlay(items)) return null;

    final pool = List<ContentItem>.of(items)..shuffle(_random);
    final options = pool.take(optionCount).toList();

    final candidates = options.where((i) => i.key != avoidTarget?.key).toList();
    final targetPool = candidates.isEmpty ? options : candidates;
    final target = targetPool[_random.nextInt(targetPool.length)];

    return Question(options: options, target: target);
  }
}
