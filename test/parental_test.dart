import 'package:flutter_test/flutter_test.dart';

import 'package:pkidz/parental/screen_time_controller.dart';

void main() {
  group('ScreenTimeController', () {
    test('limit 0 is inactive and never locks', () {
      final c = ScreenTimeController(limitMinutes: 0);
      addTearDown(c.dispose);
      expect(c.active, isFalse);
      expect(c.locked, isFalse);
      expect(c.remainingSeconds, 0);
    });

    test('a positive limit is active with a full allowance', () {
      final c = ScreenTimeController(limitMinutes: 5);
      addTearDown(c.dispose);
      expect(c.active, isTrue);
      expect(c.remainingSeconds, 5 * 60);
      expect(c.locked, isFalse);
    });

    test('setLimit restarts the allowance', () {
      final c = ScreenTimeController(limitMinutes: 5);
      addTearDown(c.dispose);
      c.setLimit(10);
      expect(c.limitMinutes, 10);
      expect(c.remainingSeconds, 10 * 60);
      expect(c.locked, isFalse);
    });

    test('unlock clears the lock and refills', () {
      final c = ScreenTimeController(limitMinutes: 1);
      addTearDown(c.dispose);
      c.unlock();
      expect(c.locked, isFalse);
      expect(c.remainingSeconds, 60);
    });
  });
}
