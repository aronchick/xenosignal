import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/audio_haptics/domain/click_calculator.dart';

void main() {
  group('ClickCalculator', () {
    late ClickCalculator calculator;

    setUp(() {
      calculator = const ClickCalculator();
    });

    group('clicksPerSecond', () {
      test('returns minimum clicks for zero signal', () {
        final cps = calculator.clicksPerSecond(0.0);
        expect(cps, equals(ClickCalculator.minClicksPerSecond));
      });

      test('returns maximum clicks for full signal', () {
        final cps = calculator.clicksPerSecond(1.0);
        expect(cps, equals(ClickCalculator.maxClicksPerSecond));
      });

      test('returns value between min and max for 50% signal', () {
        final cps = calculator.clicksPerSecond(0.5);
        expect(cps, greaterThan(ClickCalculator.minClicksPerSecond));
        expect(cps, lessThan(ClickCalculator.maxClicksPerSecond));
      });

      test('clamps values above 1.0', () {
        final cps = calculator.clicksPerSecond(1.5);
        expect(cps, equals(ClickCalculator.maxClicksPerSecond));
      });

      test('clamps values below 0.0', () {
        final cps = calculator.clicksPerSecond(-0.5);
        expect(cps, equals(ClickCalculator.minClicksPerSecond));
      });

      test('produces monotonically increasing values', () {
        double lastCps = 0;
        for (var q = 0.0; q <= 1.0; q += 0.1) {
          final cps = calculator.clicksPerSecond(q);
          expect(cps, greaterThanOrEqualTo(lastCps));
          lastCps = cps;
        }
      });
    });

    group('clickInterval', () {
      test('returns longer interval for weak signal', () {
        final weakInterval = calculator.clickInterval(0.1);
        final strongInterval = calculator.clickInterval(0.9);
        expect(weakInterval, greaterThan(strongInterval));
      });

      test('returns approximately 2 seconds for minimum clicks', () {
        final interval = calculator.clickInterval(0.0);
        // 0.5 clicks/sec = 2000ms interval
        expect(interval.inMilliseconds, equals(2000));
      });

      test('returns approximately 83ms for maximum clicks', () {
        final interval = calculator.clickInterval(1.0);
        // 12 clicks/sec = ~83ms interval
        expect(interval.inMilliseconds, closeTo(83, 2));
      });
    });

    group('pitchMultiplier', () {
      test('returns 1.0 for stable signal', () {
        final multiplier = calculator.pitchMultiplier(0.0);
        expect(multiplier, equals(1.0));
      });

      test('returns higher pitch for improving signal', () {
        final multiplier = calculator.pitchMultiplier(0.5);
        expect(multiplier, greaterThan(1.0));
        expect(multiplier, lessThanOrEqualTo(1.1));
      });

      test('returns lower pitch for degrading signal', () {
        final multiplier = calculator.pitchMultiplier(-0.5);
        expect(multiplier, lessThan(1.0));
        expect(multiplier, greaterThanOrEqualTo(0.9));
      });

      test('clamps extreme values', () {
        expect(calculator.pitchMultiplier(5.0), equals(1.1));
        expect(calculator.pitchMultiplier(-5.0), equals(0.9));
      });
    });

    group('shouldPlayWarningUndertone', () {
      test('returns true for critical low and degrading', () {
        expect(calculator.shouldPlayWarningUndertone(0.1, -0.5), isTrue);
      });

      test('returns false for low but stable signal', () {
        expect(calculator.shouldPlayWarningUndertone(0.1, 0.0), isFalse);
      });

      test('returns false for good signal even if degrading', () {
        expect(calculator.shouldPlayWarningUndertone(0.5, -0.5), isFalse);
      });

      test('returns false for improving signal even if low', () {
        expect(calculator.shouldPlayWarningUndertone(0.1, 0.5), isFalse);
      });
    });
  });
}
