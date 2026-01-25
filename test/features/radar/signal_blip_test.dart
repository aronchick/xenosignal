import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/radar/domain/signal_blip.dart';

void main() {
  group('SignalBlip', () {
    group('factory constructors', () {
      test('SignalBlip.current creates center blip', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 5);

        expect(blip.isCurrentSignal, isTrue);
        expect(blip.intensity, 0.8);
        expect(blip.createdAtSweepCount, 5);
        expect(blip.angle, isNull);
        expect(blip.distance, isNull);
      });

      test('SignalBlip.directional creates positioned blip', () {
        final blip = SignalBlip.directional(
          angle: math.pi / 4,
          distance: 0.6,
          intensity: 0.7,
          sweepCount: 3,
        );

        expect(blip.isCurrentSignal, isFalse);
        expect(blip.angle, math.pi / 4);
        expect(blip.distance, 0.6);
        expect(blip.intensity, 0.7);
        expect(blip.createdAtSweepCount, 3);
      });
    });

    group('intensity validation', () {
      test('throws for intensity below 0', () {
        expect(
          () => SignalBlip.current(intensity: -0.1, sweepCount: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws for intensity above 1', () {
        expect(
          () => SignalBlip.current(intensity: 1.1, sweepCount: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts intensity at boundaries', () {
        expect(
          () => SignalBlip.current(intensity: 0, sweepCount: 0),
          returnsNormally,
        );
        expect(
          () => SignalBlip.current(intensity: 1, sweepCount: 0),
          returnsNormally,
        );
      });
    });

    group('distance validation', () {
      test('throws for distance below 0', () {
        expect(
          () => SignalBlip.directional(
            angle: 0,
            distance: -0.1,
            intensity: 0.5,
            sweepCount: 0,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws for distance above 1', () {
        expect(
          () => SignalBlip.directional(
            angle: 0,
            distance: 1.1,
            intensity: 0.5,
            sweepCount: 0,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('calculateOpacity', () {
      test('returns 1.0 when just created', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 5);

        expect(blip.calculateOpacity(5), 1.0);
      });

      test('returns 0.75 after 1 sweep', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.calculateOpacity(1), 0.75);
      });

      test('returns 0.5 after 2 sweeps', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.calculateOpacity(2), 0.5);
      });

      test('returns 0.0 after kFadeSweepCount sweeps', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.calculateOpacity(SignalBlip.kFadeSweepCount), 0.0);
      });

      test('returns 0.0 after more than kFadeSweepCount sweeps', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.calculateOpacity(10), 0.0);
      });

      test('returns 1.0 for future sweep counts', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 10);

        expect(blip.calculateOpacity(5), 1.0);
      });
    });

    group('effectiveIntensity', () {
      test('equals intensity when just created', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.effectiveIntensity(0), 0.8);
      });

      test('decreases with fade but never below min', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        // After full fade, should be at minimum
        final fadedIntensity = blip.effectiveIntensity(10);
        expect(fadedIntensity, greaterThanOrEqualTo(0.8 * SignalBlip.kMinFadeIntensity));
      });
    });

    group('isVisible', () {
      test('returns true when just created', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.isVisible(0), isTrue);
      });

      test('returns true before full fade', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.isVisible(SignalBlip.kFadeSweepCount - 1), isTrue);
      });

      test('returns false after full fade', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 0);

        expect(blip.isVisible(SignalBlip.kFadeSweepCount), isFalse);
      });
    });

    group('calculateRadius', () {
      test('returns base radius for zero intensity', () {
        final blip = SignalBlip.current(intensity: 0, sweepCount: 0);

        const radarRadius = 100.0;
        final expectedBase = radarRadius * SignalBlip.kBaseBlipRadius;
        expect(blip.calculateRadius(radarRadius), expectedBase);
      });

      test('returns larger radius for high intensity', () {
        final lowIntensity = SignalBlip.current(intensity: 0.2, sweepCount: 0);
        final highIntensity = SignalBlip.current(intensity: 0.9, sweepCount: 0);

        const radarRadius = 100.0;
        expect(
          highIntensity.calculateRadius(radarRadius),
          greaterThan(lowIntensity.calculateRadius(radarRadius)),
        );
      });

      test('returns max radius for full intensity', () {
        final blip = SignalBlip.current(intensity: 1.0, sweepCount: 0);

        const radarRadius = 100.0;
        final expectedMax = radarRadius *
            SignalBlip.kBaseBlipRadius *
            SignalBlip.kMaxBlipRadiusMultiplier;
        expect(blip.calculateRadius(radarRadius), expectedMax);
      });
    });

    group('equality', () {
      test('equal blips are equal', () {
        final blip1 = SignalBlip.current(intensity: 0.8, sweepCount: 5);
        final blip2 = SignalBlip.current(intensity: 0.8, sweepCount: 5);

        expect(blip1, equals(blip2));
        expect(blip1.hashCode, equals(blip2.hashCode));
      });

      test('different intensities are not equal', () {
        final blip1 = SignalBlip.current(intensity: 0.8, sweepCount: 5);
        final blip2 = SignalBlip.current(intensity: 0.7, sweepCount: 5);

        expect(blip1, isNot(equals(blip2)));
      });

      test('different sweep counts are not equal', () {
        final blip1 = SignalBlip.current(intensity: 0.8, sweepCount: 5);
        final blip2 = SignalBlip.current(intensity: 0.8, sweepCount: 6);

        expect(blip1, isNot(equals(blip2)));
      });

      test('current vs directional are not equal', () {
        final current = SignalBlip.current(intensity: 0.8, sweepCount: 5);
        final directional = SignalBlip.directional(
          angle: 0,
          distance: 0,
          intensity: 0.8,
          sweepCount: 5,
        );

        expect(current, isNot(equals(directional)));
      });
    });

    group('toString', () {
      test('current blip has descriptive string', () {
        final blip = SignalBlip.current(intensity: 0.8, sweepCount: 5);

        expect(blip.toString(), contains('current'));
        expect(blip.toString(), contains('0.8'));
        expect(blip.toString(), contains('5'));
      });

      test('directional blip has descriptive string', () {
        final blip = SignalBlip.directional(
          angle: math.pi / 4,
          distance: 0.6,
          intensity: 0.7,
          sweepCount: 3,
        );

        expect(blip.toString(), contains('directional'));
        expect(blip.toString(), contains('0.6'));
        expect(blip.toString(), contains('0.7'));
      });
    });
  });
}
