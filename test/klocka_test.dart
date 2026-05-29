import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:pkidz/modules/klocka/clock_time.dart';
import 'package:pkidz/modules/klocka/settable_clock.dart';
import 'package:pkidz/modules/klocka/time_generator.dart';

void main() {
  group('ClockTime', () {
    test('12-hour face number', () {
      expect(const ClockTime(0, 0).hour12, 12); // midnight
      expect(const ClockTime(12, 0).hour12, 12); // noon
      expect(const ClockTime(13, 0).hour12, 1);
      expect(const ClockTime(9, 0).hour12, 9);
    });

    test('AM is morning (sun), PM is moon', () {
      expect(const ClockTime(9, 0).isMorning, isTrue);
      expect(const ClockTime(15, 0).isMorning, isFalse);
    });

    test('digital is zero-padded 24-hour', () {
      expect(const ClockTime(8, 5).digital, '08:05');
      expect(const ClockTime(15, 30).digital, '15:30');
    });
  });

  group('TimeGenerator', () {
    test('minute sets grow with difficulty', () {
      expect(TimeGenerator.minutesFor(1), [0]);
      expect(TimeGenerator.minutesFor(2), [0, 30]);
      expect(TimeGenerator.minutesFor(3), [0, 15, 30, 45]);
      expect(TimeGenerator.minutesFor(4).length, 12);
    });

    test('next() respects hour range and difficulty minute set', () {
      final gen = TimeGenerator(random: Random(42));
      for (final difficulty in const [1, 2, 3, 4]) {
        final allowed = TimeGenerator.minutesFor(difficulty);
        for (var i = 0; i < 200; i++) {
          final t = gen.next(difficulty);
          expect(t.hour, inInclusiveRange(TimeGenerator.minHour, TimeGenerator.maxHour));
          expect(allowed, contains(t.minute));
        }
      }
    });

    test('choices() yields 4 unique options including the correct one', () {
      final gen = TimeGenerator(random: Random(7));
      for (var i = 0; i < 100; i++) {
        final correct = gen.next(3);
        final choices = gen.choices(correct, 3);
        expect(choices, hasLength(4));
        expect(choices.toSet(), hasLength(4)); // all distinct
        expect(choices, contains(correct));
        // every distractor is from the same difficulty band
        for (final c in choices) {
          expect(TimeGenerator.minutesFor(3), contains(c.minute));
        }
      }
    });

    test('12-hour mode keeps the hour in 1–12', () {
      final gen = TimeGenerator(random: Random(11));
      for (final difficulty in const [1, 2, 3, 4]) {
        for (var i = 0; i < 200; i++) {
          final t = gen.next(difficulty, twelveHour: true);
          expect(t.hour, inInclusiveRange(1, 12));
          expect(TimeGenerator.minutesFor(difficulty), contains(t.minute));
        }
      }
    });
  });

  group('SettableClock', () {
    test('hourFromAngle maps angles to 1–12 (12 at the top)', () {
      expect(SettableClock.hourFromAngle(0), 12);
      expect(SettableClock.hourFromAngle(30), 1);
      expect(SettableClock.hourFromAngle(90), 3);
      expect(SettableClock.hourFromAngle(180), 6);
      expect(SettableClock.hourFromAngle(360), 12);
    });

    test('snapMinute picks the nearest allowed value (wrapping at 60)', () {
      const quarters = [0, 15, 30, 45];
      expect(SettableClock.snapMinute(40, quarters), 45);
      expect(SettableClock.snapMinute(7, quarters), 0);
      expect(SettableClock.snapMinute(58, quarters), 0); // wraps past 60 to 0
      expect(SettableClock.snapMinute(20, quarters), 15);
      expect(SettableClock.snapMinute(8, const [0, 5, 10, 15]), 10);
    });
  });
}
