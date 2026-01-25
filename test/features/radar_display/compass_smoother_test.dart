import 'package:flutter_test/flutter_test.dart';

import 'package:xenosignal/features/radar_display/domain/compass_smoother.dart';

void main() {
  group('CompassSmoother', () {
    late CompassSmoother smoother;

    setUp(() {
      smoother = CompassSmoother();
    });

    test('initial heading is 0', () {
      expect(smoother.currentHeading, 0);
    });

    test('filter returns smoothed value', () {
      // First reading should be partially adopted
      final result = smoother.filter(90);
      expect(result, greaterThan(0));
      expect(result, lessThan(90));
    });

    test('filter converges to steady value over time', () {
      // Feed the same value repeatedly
      double result = 0;
      for (int i = 0; i < 20; i++) {
        result = smoother.filter(180);
      }
      // Should be close to 180 after many iterations
      expect(result, closeTo(180, 5));
    });

    test('handles 0/360 wraparound correctly', () {
      // Start near 0
      smoother.reset(350);

      // Filter a reading just past 0 (10 degrees)
      // Should move toward 10, not toward 180
      final result = smoother.filter(10);

      // Result should be between 350 and 360, or between 0 and 10
      // Not somewhere around 180 (which would be wrong)
      expect(result, anyOf(
        greaterThanOrEqualTo(350),
        lessThanOrEqualTo(20),
      ));
    });

    test('reset sets heading immediately', () {
      smoother.filter(90);
      smoother.filter(90);

      smoother.reset(270);

      expect(smoother.currentHeading, 270);
    });

    test('normalizes output to 0-360 range', () {
      // Reset to a value, then filter values that might push past 360
      smoother.reset(350);
      final result = smoother.filter(370); // Should wrap to 10

      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThan(360));
    });
  });

  group('degreesToRadians', () {
    test('converts 0 degrees', () {
      expect(degreesToRadians(0), 0);
    });

    test('converts 180 degrees to pi', () {
      expect(degreesToRadians(180), closeTo(3.14159, 0.001));
    });

    test('converts 360 degrees to 2*pi', () {
      expect(degreesToRadians(360), closeTo(6.28318, 0.001));
    });
  });

  group('radiansToDegrees', () {
    test('converts 0 radians', () {
      expect(radiansToDegrees(0), 0);
    });

    test('converts pi to 180 degrees', () {
      expect(radiansToDegrees(3.14159), closeTo(180, 0.01));
    });

    test('converts 2*pi to 360 degrees', () {
      expect(radiansToDegrees(6.28318), closeTo(360, 0.01));
    });
  });
}
