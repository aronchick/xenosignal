import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../signal_tracking/domain/signal_reading.dart';
import '../domain/heatmap_point.dart';

/// Renders heatmap blips with temporal aging effects.
///
/// Blips are rendered with:
/// - Brightness based on signal quality (0-100)
/// - Opacity based on age (fresh = bright, fading over 1 hour)
/// - Historical points shown as dim "ghosts"
/// - Manual pins with distinctive markers
class HeatmapPainter extends CustomPainter {
  /// Creates a heatmap painter.
  HeatmapPainter({
    required this.blips,
    required this.currentPosition,
    required this.compassHeading,
    this.radarRangeMeters = 200.0,
    this.primaryColor = XenoColors.primaryGreen,
    this.historicalColor = const Color(0xFF1A3A1A), // Dim green for old data
  });

  /// List of heatmap points to render.
  final List<HeatmapPoint> blips;

  /// Current device position for relative calculations.
  final GeoPosition? currentPosition;

  /// Current compass heading in radians.
  final double compassHeading;

  /// Maximum range shown on radar in meters.
  final double radarRangeMeters;

  /// Primary color for fresh blips.
  final Color primaryColor;

  /// Color for historical (>1 hour) blips.
  final Color historicalColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (blips.isEmpty || currentPosition == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // Clip to radar circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Draw historical blips first (underneath fresh ones)
    for (final blip in blips.where((b) => b.isHistorical)) {
      _drawBlip(canvas, center, radius, blip);
    }

    // Draw fresh blips on top
    for (final blip in blips.where((b) => b.isFresh)) {
      _drawBlip(canvas, center, radius, blip);
    }

    canvas.restore();
  }

  void _drawBlip(Canvas canvas, Offset center, double radius, HeatmapPoint blip) {
    // Calculate position relative to current location
    final distance = HeatmapPoint.distanceBetween(currentPosition!, blip.position);
    final normalizedDistance = (distance / radarRangeMeters).clamp(0.0, 1.0);

    // Skip blips outside radar range
    if (normalizedDistance > 1.0) return;

    // Calculate bearing from current position to blip
    final bearing = HeatmapPoint.bearingBetween(currentPosition!, blip.position);

    // Adjust for compass heading (rotate display to match orientation)
    final adjustedAngle = bearing - compassHeading - math.pi / 2;

    // Calculate pixel position on radar
    final blipX = center.dx + (radius * normalizedDistance) * math.cos(adjustedAngle);
    final blipY = center.dy + (radius * normalizedDistance) * math.sin(adjustedAngle);
    final blipPos = Offset(blipX, blipY);

    // Determine blip appearance based on age and quality
    final blipColor = _getBlipColor(blip);
    final blipSize = _getBlipSize(blip);

    // Draw blip glow (for fresh blips)
    if (blip.isFresh && blip.temporalAlpha > 0.5) {
      final glowPaint = Paint()
        ..color = blipColor.withValues(alpha: blip.temporalAlpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(blipPos, blipSize * 2, glowPaint);
    }

    // Draw blip core
    final corePaint = Paint()
      ..color = blipColor.withValues(alpha: blip.temporalAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(blipPos, blipSize, corePaint);

    // Draw ring for manual pins
    if (blip.isManualPin) {
      final ringPaint = Paint()
        ..color = blipColor.withValues(alpha: blip.temporalAlpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(blipPos, blipSize + 3, ringPaint);
    }

    // Draw quality indicator (pulsing effect for high quality)
    if (blip.qualityScore > 80 && blip.isFresh) {
      final pulsePaint = Paint()
        ..color = blipColor.withValues(alpha: blip.temporalAlpha * 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(blipPos, blipSize * 3, pulsePaint);
    }
  }

  /// Gets the blip color based on quality and age.
  Color _getBlipColor(HeatmapPoint blip) {
    if (blip.isHistorical) {
      // Historical blips: dim version of quality-based color
      // Good historical spots are slightly brighter
      final brightness = 0.2 + (blip.qualityScore / 100) * 0.15;
      return Color.lerp(
        XenoColors.background,
        primaryColor,
        brightness,
      )!;
    }

    // Fresh blips: full color based on quality
    // Quality maps to color intensity
    if (blip.qualityScore > 80) {
      return primaryColor; // Full brightness
    } else if (blip.qualityScore > 60) {
      return Color.lerp(primaryColor, XenoColors.classicGreen, 0.3)!;
    } else if (blip.qualityScore > 40) {
      return Color.lerp(primaryColor, XenoColors.amber, 0.4)!;
    } else {
      return XenoColors.amber.withValues(alpha: 0.7);
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

  @override
  bool shouldRepaint(HeatmapPainter oldDelegate) {
    return blips != oldDelegate.blips ||
        currentPosition != oldDelegate.currentPosition ||
        compassHeading != oldDelegate.compassHeading;
  }
}

/// Extension to support heatmap rendering in the radar display.
extension HeatmapRadarPainterMixin on HeatmapPainter {
  /// Creates a layered painter that renders heatmap under radar sweep.
  CustomPainter withRadar({
    required double sweepAngle,
    required Color radarColor,
  }) {
    return _CompositeRadarPainter(
      heatmapPainter: this,
      sweepAngle: sweepAngle,
      primaryColor: radarColor,
    );
  }
}

/// Internal composite painter (placeholder for integration).
class _CompositeRadarPainter extends CustomPainter {
  _CompositeRadarPainter({
    required this.heatmapPainter,
    required this.sweepAngle,
    required this.primaryColor,
  });

  final HeatmapPainter heatmapPainter;
  final double sweepAngle;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Heatmap renders first (underneath)
    heatmapPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_CompositeRadarPainter oldDelegate) {
    return heatmapPainter.shouldRepaint(oldDelegate.heatmapPainter) ||
        sweepAngle != oldDelegate.sweepAngle;
  }
}
