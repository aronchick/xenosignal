import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/core/theme/colors.dart';
import 'package:xenosignal/features/radar/radar_exports.dart';

void main() {
  group('RadarTheme', () {
    test('default theme uses correct colors', () {
      const theme = RadarTheme();

      expect(theme.primaryColor, equals(XenoColors.primaryGreen));
      expect(theme.ringCount, equals(4));
      expect(theme.gridLineWidth, equals(1.0));
      expect(theme.sweepLineWidth, equals(2.0));
    });

    test('resolvedGridLineColor returns correct default', () {
      const theme = RadarTheme();

      expect(
        theme.resolvedGridLineColor,
        equals(XenoColors.primaryGreen.withValues(alpha: 0.3)),
      );
    });

    test('resolvedGridLineColor returns custom color when specified', () {
      const customColor = Colors.red;
      const theme = RadarTheme(gridLineColor: customColor);

      expect(theme.resolvedGridLineColor, equals(customColor));
    });

    test('resolvedSweepLineColor returns primary by default', () {
      const theme = RadarTheme();

      expect(theme.resolvedSweepLineColor, equals(XenoColors.primaryGreen));
    });

    test('resolvedSweepGlowColor returns semi-transparent primary by default', () {
      const theme = RadarTheme();

      expect(
        theme.resolvedSweepGlowColor,
        equals(XenoColors.primaryGreen.withValues(alpha: 0.5)),
      );
    });

    test('accepts custom primary color', () {
      const theme = RadarTheme(primaryColor: XenoColors.amber);

      expect(theme.primaryColor, equals(XenoColors.amber));
      expect(
        theme.resolvedGridLineColor,
        equals(XenoColors.amber.withValues(alpha: 0.3)),
      );
    });
  });

  group('RadarPainter', () {
    test('creates with required parameters', () {
      final painter = RadarPainter(sweepAngle: 0);

      expect(painter.sweepAngle, equals(0));
      expect(painter.theme, isA<RadarTheme>());
    });

    test('shouldRepaint returns true when sweepAngle changes', () {
      final oldPainter = RadarPainter(sweepAngle: 0);
      final newPainter = RadarPainter(sweepAngle: math.pi);

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns false when sweepAngle is same', () {
      final oldPainter = RadarPainter(sweepAngle: math.pi);
      final newPainter = RadarPainter(sweepAngle: math.pi);

      expect(newPainter.shouldRepaint(oldPainter), isFalse);
    });

    test('shouldRepaint returns true when theme changes', () {
      const theme1 = RadarTheme(ringCount: 4);
      const theme2 = RadarTheme(ringCount: 5);

      final oldPainter = RadarPainter(sweepAngle: 0, theme: theme1);
      final newPainter = RadarPainter(sweepAngle: 0, theme: theme2);

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('paint does not throw', () {
      final painter = RadarPainter(sweepAngle: math.pi / 4);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(300, 300)),
        returnsNormally,
      );
    });

    test('paint handles small sizes without error', () {
      final painter = RadarPainter(sweepAngle: 0);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(50, 50)),
        returnsNormally,
      );
    });

    test('paint handles non-square sizes', () {
      final painter = RadarPainter(sweepAngle: 0);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(400, 200)),
        returnsNormally,
      );
    });
  });

  group('RadarWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RadarWidget(size: 200),
          ),
        ),
      );

      expect(find.byType(RadarWidget), findsOneWidget);
      // CustomPaint is a descendant of RadarWidget
      expect(
        find.descendant(
          of: find.byType(RadarWidget),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses default sweep duration of 3 seconds', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RadarWidget(size: 200),
          ),
        ),
      );

      final widget = tester.widget<RadarWidget>(find.byType(RadarWidget));
      expect(widget.sweepDuration, equals(const Duration(seconds: 3)));
    });

    testWidgets('animation progresses over time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RadarWidget(size: 200),
          ),
        ),
      );

      // Pump frames to advance animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be present and animating
      expect(find.byType(RadarWidget), findsOneWidget);
    });

    testWidgets('can be stopped and started', (tester) async {
      bool running = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    RadarWidget(size: 200, running: running),
                    ElevatedButton(
                      onPressed: () => setState(() => running = !running),
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially running
      final initialWidget = tester.widget<RadarWidget>(find.byType(RadarWidget));
      expect(initialWidget.running, isTrue);

      // Tap to stop
      await tester.tap(find.text('Toggle'));
      await tester.pump();

      final stoppedWidget = tester.widget<RadarWidget>(find.byType(RadarWidget));
      expect(stoppedWidget.running, isFalse);
    });

    testWidgets('expands to fill available space when size is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: RadarWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(RadarWidget), findsOneWidget);
    });

    testWidgets('applies custom theme', (tester) async {
      const customTheme = RadarTheme(
        primaryColor: XenoColors.amber,
        ringCount: 6,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RadarWidget(
              size: 200,
              theme: customTheme,
            ),
          ),
        ),
      );

      final widget = tester.widget<RadarWidget>(find.byType(RadarWidget));
      expect(widget.theme.primaryColor, equals(XenoColors.amber));
      expect(widget.theme.ringCount, equals(6));
    });
  });

  group('ControlledRadarWidget', () {
    testWidgets('renders with specified angle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ControlledRadarWidget(
              sweepAngle: math.pi,
              size: 200,
            ),
          ),
        ),
      );

      expect(find.byType(ControlledRadarWidget), findsOneWidget);
    });

    testWidgets('updates when angle changes', (tester) async {
      double angle = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ControlledRadarWidget(sweepAngle: angle, size: 200),
                    ElevatedButton(
                      onPressed: () => setState(() => angle = math.pi),
                      child: const Text('Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial angle
      var widget = tester.widget<ControlledRadarWidget>(
        find.byType(ControlledRadarWidget),
      );
      expect(widget.sweepAngle, equals(0));

      // Update angle
      await tester.tap(find.text('Update'));
      await tester.pump();

      widget = tester.widget<ControlledRadarWidget>(
        find.byType(ControlledRadarWidget),
      );
      expect(widget.sweepAngle, equals(math.pi));
    });
  });
}
