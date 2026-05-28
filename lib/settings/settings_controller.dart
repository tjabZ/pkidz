import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

/// Loads, holds, and persists [Settings] via shared_preferences.
///
/// On first launch (no stored values) it writes the defaults so the store is
/// always populated. Listeners (modules, settings screen) rebuild when
/// settings change.
class SettingsController extends ChangeNotifier {
  SettingsController._(this._prefs, this._settings);

  final SharedPreferences _prefs;
  Settings _settings;

  Settings get settings => _settings;

  static const _firstLaunchKey = 'settings.initialized';
  static const _klockaDifficultyKey = 'settings.klockaDifficulty';
  static const _klockaAnswerMethodKey = 'settings.klockaAnswerMethod';
  static const _bildquizCategoryKey = 'settings.bildquizCategory';
  static const _stavningCategoryKey = 'settings.stavningCategory';
  static const _stavningDifficultyKey = 'settings.stavningDifficulty';

  /// Reads settings from disk, writing defaults on first launch.
  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_firstLaunchKey) ?? false)) {
      final controller = SettingsController._(prefs, Settings.defaults);
      await controller._persist();
      await prefs.setBool(_firstLaunchKey, true);
      return controller;
    }

    final settings = Settings(
      klockaDifficulty: prefs.getInt(_klockaDifficultyKey) ?? 1,
      klockaAnswerMethod: _readEnum(
        prefs.getString(_klockaAnswerMethodKey),
        KlockaAnswerMethod.values,
        KlockaAnswerMethod.multipleChoice,
      ),
      bildquizCategory: prefs.getString(_bildquizCategoryKey) ?? 'djur',
      stavningCategory: prefs.getString(_stavningCategoryKey) ?? 'djur',
      stavningDifficulty: _readEnum(
        prefs.getString(_stavningDifficultyKey),
        StavningDifficulty.values,
        StavningDifficulty.easy,
      ),
    );
    return SettingsController._(prefs, settings);
  }

  /// Replaces the current settings and persists them.
  Future<void> update(Settings settings) async {
    _settings = settings;
    await _persist();
    notifyListeners();
  }

  /// Restores defaults (SPEC.md §10 reset-to-defaults).
  Future<void> resetToDefaults() => update(Settings.defaults);

  Future<void> _persist() async {
    await _prefs.setInt(_klockaDifficultyKey, _settings.klockaDifficulty);
    await _prefs.setString(
        _klockaAnswerMethodKey, _settings.klockaAnswerMethod.name);
    await _prefs.setString(_bildquizCategoryKey, _settings.bildquizCategory);
    await _prefs.setString(_stavningCategoryKey, _settings.stavningCategory);
    await _prefs.setString(
        _stavningDifficultyKey, _settings.stavningDifficulty.name);
  }

  static T _readEnum<T extends Enum>(String? name, List<T> values, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
