import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../heatmap_history/domain/heatmap_point.dart';
import '../../signal_tracking/domain/signal_reading.dart';

/// CustomPainter for the radar display with heatmap overlay.
///
/// Renders the M314 Motion Tracker-inspired radar with:
/// - Concentric circle grid for distance reference
/// - Crosshair lines (N/S/E/W)
/// - Heatmap blips with temporal aging (fading over 1 hour)
/// - Animated sweep line with fade trail
/// - Center reticle
///
/// Heatmap blips fade based on age:
/// - Fresh (0-60 min): Full brightness → fading
/// - Historical (>60 min): Dim "ghost" indicating past good signal
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

  /// Heatmap points to render as blips.
  final List<HeatmapPoint> heatmapPoints;

  /// Current device position for relative blip positioning.
  final GeoPosition? currentPosition;

  /// Maximum range shown on radar in meters.
  final double radarRangeMeters;

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
    this.heatmapPoints = const [],
    this.currentPosition,
    this.radarRangeMeters = 200.0,
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

    // Draw in order: background, grid, heatmap, sweep trail, sweep line, reticle
    _drawBackground(canvas, center, radius);
    _drawGridRings(canvas, center, radius);
    _drawCrossHairs(canvas, center, radius);
    _drawHeatmapBlips(canvas, center, radius); // Heatmap under sweep
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

  /// Draws heatmap blips with temporal aging.
  ///
  /// Blips are rendered with:
  /// - Brightness based on signal quality (0-100)
  /// - Opacity based on age (fading over 1 hour)
  /// - Historical points as dim "ghosts"
  void _drawHeatmapBlips(Canvas canvas, Offset center, double radius) {
    if (heatmapPoints.isEmpty || currentPosition == null) return;

    // Clip to radar circle
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Sort: historical first (underneath), then fresh (on top)
    final sorted = [...heatmapPoints]
      ..sort((a, b) => a.isHistorical == b.isHistorical
          ? 0
          : a.isHistorical
              ? -1
              : 1);

    for (final blip in sorted) {
      _drawSingleBlip(canvas, center, radius, blip);
    }

    canvas.restore();
  }

  /// Draws a single heatmap blip.
  void _drawSingleBlip(
      Canvas canvas, Offset center, double radius, HeatmapPoint blip) {
    // Calculate position relative to current location
    final distance =
        HeatmapPoint.distanceBetween(currentPosition!, blip.position);
    final normalizedDistance = (distance / radarRangeMeters).clamp(0.0, 1.0);

    // Skip blips outside radar range
    if (normalizedDistance >= 1.0) return;

    // Calculate bearing from current position to blip
    final bearing =
        HeatmapPoint.bearingBetween(currentPosition!, blip.position);

    // Adjust for compass heading and canvas coordinates
    // Canvas: 0° = right (3 o'clock), increases counterclockwise
    // Bearing: 0° = north (12 o'clock), increases clockwise
    // We subtract π/2 to rotate from "right" to "up"
    final adjustedAngle = bearing - compassHeading - math.pi / 2;

    // Calculate pixel position on radar
    final blipX =
        center.dx + (radius * normalizedDistance) * math.cos(adjustedAngle);
    final blipY =
        center.dy + (radius * normalizedDistance) * math.sin(adjustedAngle);
    final blipPos = Offset(blipX, blipY);

    // Get visual properties based on age and quality
    final blipColor = _getBlipColor(blip);
    final blipSize = _getBlipSize(blip);
    final alpha = blip.temporalAlpha;

    // Draw blip glow (for fresh, high-alpha blips)
    if (blip.isFresh && alpha > 0.5) {
      final glowPaint = Paint()
        ..color = blipColor.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(blipPos, blipSize * 2, glowPaint);
    }

    // Draw blip core
    final corePaint = Paint()
      ..color = blipColor.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(blipPos, blipSize, corePaint);

    // Draw ring for manual pins
    if (blip.isManualPin) {
      final ringPaint = Paint()
        ..color = blipColor.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(blipPos, blipSize + 3, ringPaint);
    }

    // Draw quality indicator (pulsing effect for high quality fresh blips)
    if (blip.qualityScore > 80 && blip.isFresh) {
      final pulsePaint = Paint()
        ..color = blipColor.withValues(alpha: alpha * 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(blipPos, blipSize * 3, pulsePaint);
    }
  }

  /// Gets the blip color based on quality and age.
  Color _getBlipColor(HeatmapPoint blip) {
    if (blip.isHistorical) {
      // Historical blips: dim version based on quality
      // Good historical spots are slightly brighter (light green "memory")
      final brightness = 0.2 + (blip.qualityScore / 100) * 0.15;
      return Color.lerp(
        XenoColors.background,
        primaryColor,
        brightness,
      )!;
    }

    // Fresh blips: full color based on quality
    if (blip.qualityScore > 80) {
      return primaryColor; // Full brightness - "CRITICAL HIT"
    } else if (blip.qualityScore > 60) {
      return Color.lerp(primaryColor, XenoColors.classicGreen, 0.3)!;
    } else if (blip.qualityScore > 40) {
      return Color.lerp(primaryColor, XenoColors.amber, 0.4)!;
    } else {
      return XenoColors.amber.withValues(alpha: 0.7); // Poor signal
    }
  }

  /// Gets the blip size based on quality and type.
  double _getBlipSize(HeatmapPoint blip) {
    // Manual pins are larger
    final baseSize = blip.isManualPin ? 6.0 : 4.0;

    // Historical blips are smaller
    if (blip.isHistorical) {
      return baseSize * 0.7;
    }

    // Quality affects size slightly
    return baseSize + (blip.qualityScore / 100) * 2;
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
    // or when heatmap data changes
    return sweepAngle != oldDelegate.sweepAngle ||
        compassHeading != oldDelegate.compassHeading ||
        primaryColor != oldDelegate.primaryColor ||
        heatmapPoints != oldDelegate.heatmapPoints ||
        currentPosition != oldDelegate.currentPosition;
  }
}
