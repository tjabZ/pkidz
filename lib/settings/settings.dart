/// How the kid answers in the Klocka module (SPEC.md §6).
enum KlockaAnswerMethod { multipleChoice, freeText }

/// Klocka practice direction (SPEC.md §6).
/// readClock: analog shown, answer the digital time (default).
/// setClock: digital shown, produce the clock (pick a face / drag the hands).
enum KlockaDirection { readClock, setClock }

/// Stavning difficulty (SPEC.md §8).
enum StavningDifficulty { easy, medium, hard }

/// All persisted user settings (SPEC.md §10).
/// Categories are stored as folder-name strings; modules validate them
/// against loaded content once the content system exists (Phase 2).
class Settings {
  const Settings({
    this.klockaDifficulty = 1,
    this.klockaAnswerMethod = KlockaAnswerMethod.multipleChoice,
    this.klockaDirection = KlockaDirection.readClock,
    this.klocka12Hour = false,
    this.bildquizCategory = 'djur',
    this.stavningCategory = 'djur',
    this.stavningDifficulty = StavningDifficulty.easy,
    this.stavningUppercase = false,
    this.parentalPin = '',
    this.screenTimeLimitMinutes = 0,
  });

  /// Klocka difficulty band, 1–4 (SPEC.md §6).
  final int klockaDifficulty;
  final KlockaAnswerMethod klockaAnswerMethod;
  final KlockaDirection klockaDirection;

  /// 12-hour mode: no sun/moon, times 00:00–12:00, answers in 12-hour.
  final bool klocka12Hour;

  final String bildquizCategory;
  final String stavningCategory;
  final StavningDifficulty stavningDifficulty;

  /// Show the Stavning keyboard/letters in uppercase (display only).
  final bool stavningUppercase;

  /// 4-digit parental PIN; empty string means not set yet.
  final String parentalPin;

  /// Per-session screen-time limit in minutes; 0 = off.
  final int screenTimeLimitMinutes;

  bool get hasPin => parentalPin.isNotEmpty;

  static const Settings defaults = Settings();

  Settings copyWith({
    int? klockaDifficulty,
    KlockaAnswerMethod? klockaAnswerMethod,
    KlockaDirection? klockaDirection,
    bool? klocka12Hour,
    String? bildquizCategory,
    String? stavningCategory,
    StavningDifficulty? stavningDifficulty,
    bool? stavningUppercase,
    String? parentalPin,
    int? screenTimeLimitMinutes,
  }) {
    return Settings(
      klockaDifficulty: klockaDifficulty ?? this.klockaDifficulty,
      klockaAnswerMethod: klockaAnswerMethod ?? this.klockaAnswerMethod,
      klockaDirection: klockaDirection ?? this.klockaDirection,
      klocka12Hour: klocka12Hour ?? this.klocka12Hour,
      bildquizCategory: bildquizCategory ?? this.bildquizCategory,
      stavningCategory: stavningCategory ?? this.stavningCategory,
      stavningDifficulty: stavningDifficulty ?? this.stavningDifficulty,
      stavningUppercase: stavningUppercase ?? this.stavningUppercase,
      parentalPin: parentalPin ?? this.parentalPin,
      screenTimeLimitMinutes:
          screenTimeLimitMinutes ?? this.screenTimeLimitMinutes,
    );
  }

  Map<String, Object> toMap() => {
        'klockaDifficulty': klockaDifficulty,
        'klockaAnswerMethod': klockaAnswerMethod.name,
        'klockaDirection': klockaDirection.name,
        'klocka12Hour': klocka12Hour,
        'bildquizCategory': bildquizCategory,
        'stavningCategory': stavningCategory,
        'stavningDifficulty': stavningDifficulty.name,
        'stavningUppercase': stavningUppercase,
        'parentalPin': parentalPin,
        'screenTimeLimitMinutes': screenTimeLimitMinutes,
      };

  factory Settings.fromMap(Map<String, Object?> map) {
    return Settings(
      klockaDifficulty: (map['klockaDifficulty'] as int?) ?? 1,
      klockaAnswerMethod: _enumByName(
        KlockaAnswerMethod.values,
        map['klockaAnswerMethod'] as String?,
        KlockaAnswerMethod.multipleChoice,
      ),
      klockaDirection: _enumByName(
        KlockaDirection.values,
        map['klockaDirection'] as String?,
        KlockaDirection.readClock,
      ),
      klocka12Hour: (map['klocka12Hour'] as bool?) ?? false,
      bildquizCategory: (map['bildquizCategory'] as String?) ?? 'djur',
      stavningCategory: (map['stavningCategory'] as String?) ?? 'djur',
      stavningDifficulty: _enumByName(
        StavningDifficulty.values,
        map['stavningDifficulty'] as String?,
        StavningDifficulty.easy,
      ),
      stavningUppercase: (map['stavningUppercase'] as bool?) ?? false,
      parentalPin: (map['parentalPin'] as String?) ?? '',
      screenTimeLimitMinutes: (map['screenTimeLimitMinutes'] as int?) ?? 0,
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
