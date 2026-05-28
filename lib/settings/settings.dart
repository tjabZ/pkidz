/// How the kid answers in the Klocka module (SPEC.md §6).
enum KlockaAnswerMethod { multipleChoice, freeText }

/// Stavning difficulty (SPEC.md §8).
enum StavningDifficulty { easy, medium, hard }

/// All persisted user settings (SPEC.md §10).
/// Categories are stored as folder-name strings; modules validate them
/// against loaded content once the content system exists (Phase 2).
class Settings {
  const Settings({
    this.klockaDifficulty = 1,
    this.klockaAnswerMethod = KlockaAnswerMethod.multipleChoice,
    this.bildquizCategory = 'djur',
    this.stavningCategory = 'djur',
    this.stavningDifficulty = StavningDifficulty.easy,
  });

  /// Klocka difficulty band, 1–4 (SPEC.md §6).
  final int klockaDifficulty;
  final KlockaAnswerMethod klockaAnswerMethod;
  final String bildquizCategory;
  final String stavningCategory;
  final StavningDifficulty stavningDifficulty;

  static const Settings defaults = Settings();

  Settings copyWith({
    int? klockaDifficulty,
    KlockaAnswerMethod? klockaAnswerMethod,
    String? bildquizCategory,
    String? stavningCategory,
    StavningDifficulty? stavningDifficulty,
  }) {
    return Settings(
      klockaDifficulty: klockaDifficulty ?? this.klockaDifficulty,
      klockaAnswerMethod: klockaAnswerMethod ?? this.klockaAnswerMethod,
      bildquizCategory: bildquizCategory ?? this.bildquizCategory,
      stavningCategory: stavningCategory ?? this.stavningCategory,
      stavningDifficulty: stavningDifficulty ?? this.stavningDifficulty,
    );
  }

  Map<String, Object> toMap() => {
        'klockaDifficulty': klockaDifficulty,
        'klockaAnswerMethod': klockaAnswerMethod.name,
        'bildquizCategory': bildquizCategory,
        'stavningCategory': stavningCategory,
        'stavningDifficulty': stavningDifficulty.name,
      };

  factory Settings.fromMap(Map<String, Object?> map) {
    return Settings(
      klockaDifficulty: (map['klockaDifficulty'] as int?) ?? 1,
      klockaAnswerMethod: _enumByName(
        KlockaAnswerMethod.values,
        map['klockaAnswerMethod'] as String?,
        KlockaAnswerMethod.multipleChoice,
      ),
      bildquizCategory: (map['bildquizCategory'] as String?) ?? 'djur',
      stavningCategory: (map['stavningCategory'] as String?) ?? 'djur',
      stavningDifficulty: _enumByName(
        StavningDifficulty.values,
        map['stavningDifficulty'] as String?,
        StavningDifficulty.easy,
      ),
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
