import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xenosignal/features/radar_display/presentation/radar_painter.dart';

void main() {
  group('RadarPainter', () {
    test('creates with default values', () {
      final painter = RadarPainter(sweepAngle: 0);

      expect(painter.sweepAngle, 0);
      expect(painter.compassHeading, 0);
      expect(painter.ringCount, 4);
    });

    test('creates with custom values', () {
      final painter = RadarPainter(
        sweepAngle: math.pi,
        compassHeading: math.pi / 2,
        ringCount: 6,
      );

      expect(painter.sweepAngle, math.pi);
      expect(painter.compassHeading, math.pi / 2);
      expect(painter.ringCount, 6);
    });

    group('shouldRepaint', () {
      test('returns true when sweepAngle changes', () {
        final painter1 = RadarPainter(sweepAngle: 0);
        final painter2 = RadarPainter(sweepAngle: math.pi);

        expect(painter2.shouldRepaint(painter1), isTrue);
      });

      test('returns true when compassHeading changes', () {
        final painter1 = RadarPainter(sweepAngle: 0, compassHeading: 0);
        final painter2 = RadarPainter(sweepAngle: 0, compassHeading: math.pi);

        expect(painter2.shouldRepaint(painter1), isTrue);
      });

      test('returns true when primaryColor changes', () {
        final painter1 = RadarPainter(
          sweepAngle: 0,
          primaryColor: Colors.green,
        );
        final painter2 = RadarPainter(
          sweepAngle: 0,
          primaryColor: Colors.amber,
        );

        expect(painter2.shouldRepaint(painter1), isTrue);
      });

      test('returns false when nothing changes', () {
        final painter1 = RadarPainter(
          sweepAngle: math.pi,
          compassHeading: math.pi / 4,
          primaryColor: Colors.green,
        );
        final painter2 = RadarPainter(
          sweepAngle: math.pi,
          compassHeading: math.pi / 4,
          primaryColor: Colors.green,
        );

        expect(painter2.shouldRepaint(painter1), isFalse);
      });
    });

    test('sweepAngle handles full rotation', () {
      // 2*pi is a full rotation
      final painter = RadarPainter(sweepAngle: 2 * math.pi);
      expect(painter.sweepAngle, 2 * math.pi);
    });

    test('sweepAngle handles values beyond 2*pi', () {
      // Animation might overshoot
      final painter = RadarPainter(sweepAngle: 3 * math.pi);
      expect(painter.sweepAngle, 3 * math.pi);
    });
  });
}
