import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../domain/signal_blip.dart';

/// Configuration for radar visual appearance.
class RadarTheme {
  const RadarTheme({
    this.primaryColor = XenoColors.primaryGreen,
    this.gridLineColor,
    this.sweepLineColor,
    this.sweepGlowColor,
    this.gridLineWidth = 1.0,
    this.sweepLineWidth = 2.0,
    this.ringCount = 4,
    this.crosshairExtension = 0.1,
  });

  /// Primary color for radar elements.
  final Color primaryColor;

  /// Color for grid lines. Defaults to primaryColor at 30% opacity.
  final Color? gridLineColor;

  /// Color for the sweep line. Defaults to primaryColor.
  final Color? sweepLineColor;

  /// Glow color for sweep line. Defaults to primaryColor at 50% opacity.
  final Color? sweepGlowColor;

  /// Width of grid lines.
  final double gridLineWidth;

  /// Width of the sweep line.
  final double sweepLineWidth;

  /// Number of concentric rings to draw.
  final int ringCount;

  /// How far crosshairs extend beyond the outer ring (as fraction of radius).
  final double crosshairExtension;

  /// Resolved grid line color.
  Color get resolvedGridLineColor =>
      gridLineColor ?? primaryColor.withValues(alpha: 0.3);

  /// Resolved sweep line color.
  Color get resolvedSweepLineColor => sweepLineColor ?? primaryColor;

  /// Resolved sweep glow color.
  Color get resolvedSweepGlowColor =>
      sweepGlowColor ?? primaryColor.withValues(alpha: 0.5);
}

/// CustomPainter for the radar display.
///
/// Renders:
/// - Background grid with concentric circles and crosshairs
/// - Animated sweep line with glow effect
/// - Signal blips with intensity-based size and fade
/// - Center reticle
///
/// The sweep animates clockwise from the top (12 o'clock position).
class RadarPainter extends CustomPainter {
  RadarPainter({
    required this.sweepAngle,
    this.theme = const RadarTheme(),
    this.blips = const [],
    this.sweepCount = 0,
  });

  /// Current sweep angle in radians (0 = top, clockwise).
  final double sweepAngle;

  /// Visual configuration.
  final RadarTheme theme;

  /// Signal blips to render on the radar.
  final List<SignalBlip> blips;

  /// Current sweep count for calculating blip fade.
  final int sweepCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;

    _drawGrid(canvas, center, radius);
    _drawSweepLine(canvas, center, radius);
    _drawBlips(canvas, center, radius);
    _drawCenterReticle(canvas, center, radius);
  }

  /// Draws concentric circles and crosshairs.
  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = theme.resolvedGridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.gridLineWidth;

    // Draw concentric circles
    for (int i = 1; i <= theme.ringCount; i++) {
      final ringRadius = radius * (i / theme.ringCount);
      canvas.drawCircle(center, ringRadius, gridPaint);
    }

    // Draw crosshairs extending slightly beyond outer ring
    final extension = radius * theme.crosshairExtension;
    final totalLength = radius + extension;

    // Vertical crosshair (top to bottom)
    canvas.drawLine(
      Offset(center.dx, center.dy - totalLength),
      Offset(center.dx, center.dy + totalLength),
      gridPaint,
    );

    // Horizontal crosshair (left to right)
    canvas.drawLine(
      Offset(center.dx - totalLength, center.dy),
      Offset(center.dx + totalLength, center.dy),
      gridPaint,
    );

    // Draw diagonal crosshairs at 45-degree angles (dimmer)
    final diagonalPaint = Paint()
      ..color = theme.resolvedGridLineColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.gridLineWidth;

    final diagonalOffset = totalLength * math.sqrt(2) / 2;

    // Top-left to bottom-right
    canvas.drawLine(
      Offset(center.dx - diagonalOffset, center.dy - diagonalOffset),
      Offset(center.dx + diagonalOffset, center.dy + diagonalOffset),
      diagonalPaint,
    );

    // Top-right to bottom-left
    canvas.drawLine(
      Offset(center.dx + diagonalOffset, center.dy - diagonalOffset),
      Offset(center.dx - diagonalOffset, center.dy + diagonalOffset),
      diagonalPaint,
    );
  }

  /// Draws the animated sweep line with glow effect.
  void _drawSweepLine(Canvas canvas, Offset center, double radius) {
    // Adjust angle: sweepAngle 0 = top (subtract pi/2 to rotate)
    final adjustedAngle = sweepAngle - math.pi / 2;

    final endPoint = Offset(
      center.dx + math.cos(adjustedAngle) * radius,
      center.dy + math.sin(adjustedAngle) * radius,
    );

    // Draw glow (thicker, semi-transparent)
    final glowPaint = Paint()
      ..color = theme.resolvedSweepGlowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.sweepLineWidth * 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(center, endPoint, glowPaint);

    // Draw the main sweep line
    final sweepPaint = Paint()
      ..color = theme.resolvedSweepLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.sweepLineWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, endPoint, sweepPaint);

    // Draw sweep trail (fading arc behind the sweep line)
    _drawSweepTrail(canvas, center, radius, adjustedAngle);
  }

  /// Draws a fading trail behind the sweep line.
  void _drawSweepTrail(
    Canvas canvas,
    Offset center,
    double radius,
    double currentAngle,
  ) {
    const trailLength = math.pi / 3; // 60 degrees of trail
    const trailSegments = 20;

    for (int i = 0; i < trailSegments; i++) {
      final progress = i / trailSegments;
      final segmentAngle = currentAngle - (trailLength * progress);
      final nextAngle = currentAngle - (trailLength * (progress + 1 / trailSegments));

      // Fade from current opacity to zero
      final alpha = (1.0 - progress) * 0.3;

      final trailPaint = Paint()
        ..color = theme.primaryColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        nextAngle,
        (segmentAngle - nextAngle).abs(),
        false,
        trailPaint,
      );
    }
  }

  /// Draws all signal blips on the radar.
  void _drawBlips(Canvas canvas, Offset center, double radius) {
    for (final blip in blips) {
      if (!blip.isVisible(sweepCount)) continue;

      final effectiveIntensity = blip.effectiveIntensity(sweepCount);
      final blipRadius = blip.calculateRadius(radius);

      // Calculate blip position
      final Offset blipCenter;
      if (blip.isCurrentSignal) {
        // Current signal blip at center
        blipCenter = center;
      } else {
        // Directional blip at angle/distance
        final angle = blip.angle! - math.pi / 2; // Adjust for canvas coords
        final distance = blip.distance! * radius * 0.85; // Stay inside grid
        blipCenter = Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance,
        );
      }

      _drawSingleBlip(canvas, blipCenter, blipRadius, effectiveIntensity);
    }
  }

  /// Draws a single blip with glow effect.
  void _drawSingleBlip(
    Canvas canvas,
    Offset center,
    double radius,
    double intensity,
  ) {
    // Outer glow
    final glowPaint = Paint()
      ..color = theme.primaryColor.withValues(alpha: intensity * 0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8);

    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Main blip body
    final bodyPaint = Paint()
      ..color = theme.primaryColor.withValues(alpha: intensity * 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bodyPaint);

    // Bright center core
    final corePaint = Paint()
      ..color = theme.primaryColor.withValues(alpha: intensity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, corePaint);
  }

  /// Draws the center reticle/crosshair.
  void _drawCenterReticle(Canvas canvas, Offset center, double radius) {
    final reticleSize = radius * 0.08;

    // Outer circle
    final outerPaint = Paint()
      ..color = theme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, reticleSize, outerPaint);

    // Inner dot
    final innerPaint = Paint()
      ..color = theme.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, reticleSize * 0.3, innerPaint);

    // Small crosshairs on the reticle
    final crossPaint = Paint()
      ..color = theme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final crossLength = reticleSize * 1.8;

    // Vertical
    canvas.drawLine(
      Offset(center.dx, center.dy - crossLength),
      Offset(center.dx, center.dy - reticleSize * 1.2),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + reticleSize * 1.2),
      Offset(center.dx, center.dy + crossLength),
      crossPaint,
    );

    // Horizontal
    canvas.drawLine(
      Offset(center.dx - crossLength, center.dy),
      Offset(center.dx - reticleSize * 1.2, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx + reticleSize * 1.2, center.dy),
      Offset(center.dx + crossLength, center.dy),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.theme != theme ||
        oldDelegate.sweepCount != sweepCount ||
        !_blipsEqual(oldDelegate.blips, blips);
  }

  /// Compares two blip lists for equality.
  bool _blipsEqual(List<SignalBlip> a, List<SignalBlip> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
