import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/radar/presentation/direction_arrow.dart';
import 'package:xenosignal/features/radar/presentation/radar_painter.dart';

void main() {
  group('SignalTarget', () {
    test('creates with required parameters', () {
      const target = SignalTarget(
        angle: math.pi / 4,
        distance: 0.5,
        signalStrength: 0.9,
      );

      expect(target.angle, math.pi / 4);
      expect(target.distance, 0.5);
      expect(target.signalStrength, 0.9);
      expect(target.distanceMeters, isNull);
    });

    test('creates with optional distanceMeters', () {
      const target = SignalTarget(
        angle: 0,
        distance: 0.3,
        signalStrength: 0.8,
        distanceMeters: 45.0,
      );

      expect(target.distanceMeters, 45.0);
    });
  });

  group('DirectionArrowState', () {
    test('has correct enum values', () {
      expect(DirectionArrowState.values.length, 3);
      expect(DirectionArrowState.values, contains(DirectionArrowState.pointing));
      expect(DirectionArrowState.values, contains(DirectionArrowState.optimal));
      expect(DirectionArrowState.values, contains(DirectionArrowState.unknown));
    });
  });

  group('DirectionArrow widget', () {
    testWidgets('renders in pointing state with target', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                target: SignalTarget(
                  angle: math.pi / 2,
                  distance: 0.5,
                  signalStrength: 0.9,
                  distanceMeters: 50,
                ),
                state: DirectionArrowState.pointing,
              ),
            ),
          ),
        ),
      );

      // Should find the widget
      expect(find.byType(DirectionArrow), findsOneWidget);

      // Should show distance text
      expect(find.text('50M'), findsOneWidget);
    });

    testWidgets('renders in optimal state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                state: DirectionArrowState.optimal,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DirectionArrow), findsOneWidget);
      expect(find.text('POSITION OPTIMAL'), findsOneWidget);
    });

    testWidgets('renders in unknown state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                state: DirectionArrowState.unknown,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DirectionArrow), findsOneWidget);
      expect(find.text('SCANNING...'), findsOneWidget);
    });

    testWidgets('hides distance when showDistance is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                target: SignalTarget(
                  angle: 0,
                  distance: 0.5,
                  signalStrength: 0.9,
                  distanceMeters: 50,
                ),
                state: DirectionArrowState.pointing,
                showDistance: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('50M'), findsNothing);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                state: DirectionArrowState.optimal,
                size: 120,
              ),
            ),
          ),
        ),
      );

      // Find the SizedBox with the specified size
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(DirectionArrow),
          matching: find.byType(SizedBox).first,
        ),
      );

      expect(sizedBox.width, 120);
      expect(sizedBox.height, 120);
    });

    testWidgets('applies custom theme', (tester) async {
      const customTheme = RadarTheme(
        primaryColor: Colors.amber,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                state: DirectionArrowState.optimal,
                theme: customTheme,
              ),
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(DirectionArrow), findsOneWidget);
    });

    group('distance formatting', () {
      testWidgets('formats distances under 10m', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: DirectionArrow(
                  target: SignalTarget(
                    angle: 0,
                    distance: 0.1,
                    signalStrength: 0.9,
                    distanceMeters: 5,
                  ),
                  state: DirectionArrowState.pointing,
                ),
              ),
            ),
          ),
        );

        expect(find.text('< 10M'), findsOneWidget);
      });

      testWidgets('formats distances under 100m', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: DirectionArrow(
                  target: SignalTarget(
                    angle: 0,
                    distance: 0.3,
                    signalStrength: 0.9,
                    distanceMeters: 75,
                  ),
                  state: DirectionArrowState.pointing,
                ),
              ),
            ),
          ),
        );

        expect(find.text('75M'), findsOneWidget);
      });

      testWidgets('formats distances in kilometers', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: DirectionArrow(
                  target: SignalTarget(
                    angle: 0,
                    distance: 0.9,
                    signalStrength: 0.9,
                    distanceMeters: 1500,
                  ),
                  state: DirectionArrowState.pointing,
                ),
              ),
            ),
          ),
        );

        expect(find.text('1.5KM'), findsOneWidget);
      });

      testWidgets('shows TRACKING when distance unknown', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: DirectionArrow(
                  target: SignalTarget(
                    angle: 0,
                    distance: 0.5,
                    signalStrength: 0.9,
                  ),
                  state: DirectionArrowState.pointing,
                ),
              ),
            ),
          ),
        );

        expect(find.text('TRACKING'), findsOneWidget);
      });
    });

    testWidgets('animation runs when enabled and pointing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                target: SignalTarget(
                  angle: 0,
                  distance: 0.5,
                  signalStrength: 0.9,
                ),
                state: DirectionArrowState.pointing,
                enabled: true,
              ),
            ),
          ),
        ),
      );

      // Pump some frames to verify animation runs without errors
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DirectionArrow), findsOneWidget);
    });

    testWidgets('animation stops when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionArrow(
                target: SignalTarget(
                  angle: 0,
                  distance: 0.5,
                  signalStrength: 0.9,
                ),
                state: DirectionArrowState.pointing,
                enabled: false,
              ),
            ),
          ),
        ),
      );

      // Should render without animation issues
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DirectionArrow), findsOneWidget);
    });
  });
}
