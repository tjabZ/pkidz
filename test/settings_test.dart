import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pkidz/settings/settings.dart';
import 'package:pkidz/settings/settings_controller.dart';

void main() {
  test('new settings persist across reloads', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final controller = await SettingsController.load();
    await controller.update(controller.settings.copyWith(
      stavningUppercase: true,
      klocka12Hour: true,
      klockaDirection: KlockaDirection.setClock,
      parentalPin: '1234',
      screenTimeLimitMinutes: 20,
    ));

    final reloaded = await SettingsController.load();
    expect(reloaded.settings.stavningUppercase, isTrue);
    expect(reloaded.settings.klocka12Hour, isTrue);
    expect(reloaded.settings.klockaDirection, KlockaDirection.setClock);
    expect(reloaded.settings.parentalPin, '1234');
    expect(reloaded.settings.hasPin, isTrue);
    expect(reloaded.settings.screenTimeLimitMinutes, 20);
  });

  test('resetToDefaults clears the PIN and limit', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final controller = await SettingsController.load();
    await controller.update(controller.settings
        .copyWith(parentalPin: '4321', screenTimeLimitMinutes: 15));
    await controller.resetToDefaults();

    expect(controller.settings.hasPin, isFalse);
    expect(controller.settings.screenTimeLimitMinutes, 0);
  });
}
