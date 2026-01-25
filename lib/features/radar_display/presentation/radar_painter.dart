import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// CustomPainter for the radar display.
///
/// Renders the M314 Motion Tracker-inspired radar with:
/// - Concentric circle grid for distance reference
/// - Crosshair lines (N/S/E/W)
/// - Animated sweep line with fade trail
/// - Center reticle
///
/// Performance optimized for 60fps with minimal allocations in paint().
class RadarPainter extends CustomPainter {
  /// Current sweep angle in radians (0 to 2*pi, clockwise from top).
  final double sweepAngle;

  /// Device compass heading in radians (used for rotating blips, not grid).
  final double compassHeading;

  /// Primary color for the radar (phosphor green or amber).
  final Color primaryColor;

  /// Number of concentric circles to draw.
  final int ringCount;

  // Pre-allocated Paint objects for performance
  late final Paint _gridPaint;
  late final Paint _sweepPaint;
  late final Paint _sweepGlowPaint;
  late final Paint _reticlePaint;

  /// Creates a RadarPainter with the current sweep position.
  RadarPainter({
    required this.sweepAngle,
    this.compassHeading = 0,
    this.primaryColor = XenoColors.primaryGreen,
    this.ringCount = 4,
  }) {
    _initPaints();
  }

  void _initPaints() {
    _gridPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _sweepPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    _sweepGlowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    _reticlePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // Draw in order: background, grid, sweep trail, sweep line, reticle
    _drawBackground(canvas, center, radius);
    _drawGridRings(canvas, center, radius);
    _drawCrossHairs(canvas, center, radius);
    _drawSweepTrail(canvas, center, radius);
    _drawSweepLine(canvas, center, radius);
    _drawCenterReticle(canvas, center);
  }

  /// Draws the dark circular background.
  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final backgroundPaint = Paint()
      ..color = XenoColors.background
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Outer ring (border)
    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Draws concentric circles for distance reference.
  void _drawGridRings(Canvas canvas, Offset center, double radius) {
    for (int i = 1; i <= ringCount; i++) {
      final ringRadius = radius * (i / ringCount);
      canvas.drawCircle(center, ringRadius, _gridPaint);
    }
  }

  /// Draws N/S/E/W crosshair lines.
  void _drawCrossHairs(Canvas canvas, Offset center, double radius) {
    // Vertical line (N-S)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      _gridPaint,
    );

    // Horizontal line (E-W)
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      _gridPaint,
    );

    // Diagonal lines (45 degree increments)
    final diagonalOffset = radius * 0.707; // cos(45°)
    final diagonalPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // NE-SW
    canvas.drawLine(
      Offset(center.dx - diagonalOffset, center.dy - diagonalOffset),
      Offset(center.dx + diagonalOffset, center.dy + diagonalOffset),
      diagonalPaint,
    );

    // NW-SE
    canvas.drawLine(
      Offset(center.dx + diagonalOffset, center.dy - diagonalOffset),
      Offset(center.dx - diagonalOffset, center.dy + diagonalOffset),
      diagonalPaint,
    );
  }

  /// Draws the fading sweep trail behind the sweep line.
  void _drawSweepTrail(Canvas canvas, Offset center, double radius) {
    // Create a gradient arc for the sweep trail
    // Trail spans ~60 degrees behind the sweep line
    const trailAngle = math.pi / 3; // 60 degrees

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Sweep gradient - fades from transparent to primary color
    final sweepGradient = ui.Gradient.sweep(
      center,
      [
        primaryColor.withValues(alpha: 0),
        primaryColor.withValues(alpha: 0.1),
        primaryColor.withValues(alpha: 0.3),
      ],
      [0.0, 0.5, 1.0],
      TileMode.clamp,
      sweepAngle - trailAngle - math.pi / 2,
      sweepAngle - math.pi / 2,
    );

    final trailPaint = Paint()
      ..shader = sweepGradient
      ..style = PaintingStyle.fill;

    // Draw arc segment for trail
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        rect,
        sweepAngle - trailAngle - math.pi / 2, // Start angle (from positive x)
        trailAngle, // Sweep angle
        false,
      )
      ..close();

    canvas.drawPath(path, trailPaint);
  }

  /// Draws the main sweep line.
  void _drawSweepLine(Canvas canvas, Offset center, double radius) {
    // Calculate end point of sweep line
    // sweepAngle is clockwise from top, but canvas 0° is at 3 o'clock
    // So we subtract pi/2 to rotate
    final adjustedAngle = sweepAngle - math.pi / 2;
    final endX = center.dx + radius * math.cos(adjustedAngle);
    final endY = center.dy + radius * math.sin(adjustedAngle);
    final end = Offset(endX, endY);

    // Draw glow (blur effect behind line)
    canvas.drawLine(center, end, _sweepGlowPaint);

    // Draw main sweep line
    canvas.drawLine(center, end, _sweepPaint);
  }

  /// Draws the center reticle/crosshair.
  void _drawCenterReticle(Canvas canvas, Offset center) {
    // Center dot
    canvas.drawCircle(center, 3, _reticlePaint);

    // Small crosshair
    final crossSize = 8.0;
    final crossPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - crossSize, center.dy),
      Offset(center.dx + crossSize, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crossSize),
      Offset(center.dx, center.dy + crossSize),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    // Repaint when sweep angle changes (every frame during animation)
    return sweepAngle != oldDelegate.sweepAngle ||
        compassHeading != oldDelegate.compassHeading ||
        primaryColor != oldDelegate.primaryColor;
  }
}
