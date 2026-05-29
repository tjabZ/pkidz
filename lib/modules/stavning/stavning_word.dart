import '../../settings/settings.dart';

/// The word the child must spell: the lowercased Swedish display word plus the
/// difficulty-driven hint mask (SPEC.md §8). The kid types every letter of
/// [display] in all difficulties; hints are purely a visual tracing guide.
class StavningWord {
  factory StavningWord(String display) {
    final lower = display.toLowerCase();
    return StavningWord._(lower, lower.split(''));
  }

  const StavningWord._(this.display, this.letters);

  /// Lowercased target word, e.g. `häst` — exactly what the child types.
  final String display;

  /// [display] split into single-character letters, in order.
  final List<String> letters;

  int get length => letters.length;

  /// Indices that show a faint "ghost" letter to trace over, for [difficulty]:
  /// - easy: every letter (full word shown faintly in the boxes)
  /// - medium: alternating letters from the first (0, 2, 4, …)
  /// - hard: none (all boxes blank)
  ///
  /// Hints never auto-fill: the child still types every letter to advance.
  Set<int> hintIndices(StavningDifficulty difficulty) {
    switch (difficulty) {
      case StavningDifficulty.easy:
        return {for (var i = 0; i < length; i++) i};
      case StavningDifficulty.medium:
        return {for (var i = 0; i < length; i += 2) i};
      case StavningDifficulty.hard:
        return const {};
    }
  }
}
