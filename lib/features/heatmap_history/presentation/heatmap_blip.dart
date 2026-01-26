import 'dart:ui' as ui;

import '../domain/heatmap_point.dart';

/// A blip ready for rendering on the radar.
///
/// Pre-calculated from a HeatmapPoint with relative positioning
/// and visual properties based on temporal aging.
class HeatmapBlip {
  /// Creates a heatmap blip for rendering.
  const HeatmapBlip({
    required this.angle,
    required this.distance,
    required this.alpha,
    required this.qualityScore,
    required this.isHistorical,
    required this.isManualPin,
  });

  /// Angle in radians from north (0 = top, clockwise).
  final double angle;

  /// Normalized distance from center (0.0 = center, 1.0 = edge).
  final double distance;

  /// Opacity based on temporal aging (0.0 to 1.0).
  final double alpha;

  /// Signal quality (0-100) for color intensity.
  final int qualityScore;

  /// Whether this is a historical (>1 hour old) point.
  final bool isHistorical;

  /// Whether this was manually pinned.
  final bool isManualPin;

  /// Creates a blip from a heatmap point relative to current position.
  ///
  /// [point] The heatmap point to convert.
  /// [currentPosition] The user's current geographic position.
  /// [compassHeading] Current compass heading in radians.
  /// [radarRangeMeters] The maximum range shown on radar.
  factory HeatmapBlip.fromPoint(
    HeatmapPoint point, {
    required ui.Offset currentPosition,
    required double compassHeading,
    required double radarRangeMeters,
  }) {
    // Calculate bearing and distance from current position to point
    // For now, use simple lat/lon to offset (will be replaced with real GPS)
    final dLat = point.position.latitude - currentPosition.dx;
    final dLon = point.position.longitude - currentPosition.dy;

    // Simple angle calculation (actual implementation would use proper bearing)
    final angle = _atan2(dLon, dLat);

    // Simple distance calculation (actual would use Haversine)
    final distanceNorm = _hypot(dLat, dLon).clamp(0.0, 1.0);

    return HeatmapBlip(
      angle: angle - compassHeading, // Compensate for device heading
      distance: distanceNorm,
      alpha: point.temporalAlpha,
      qualityScore: point.qualityScore,
      isHistorical: point.isHistorical,
      isManualPin: point.isManualPin,
    );
  }

  static double _atan2(double y, double x) {
    return y.isNaN || x.isNaN ? 0.0 : (y == 0 && x == 0) ? 0.0 : _atan2Impl(y, x);
  }

  static double _atan2Impl(double y, double x) {
    // Simplified atan2 for angle calculation
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159;
    if (x == 0 && y > 0) return 3.14159 / 2;
    if (x == 0 && y < 0) return -3.14159 / 2;
    return 0;
  }

  static double _atan(double x) {
    // Taylor series approximation for small values
    if (x.abs() < 1) {
      return x - x * x * x / 3 + x * x * x * x * x / 5;
    }
    // For larger values, use identity
    final sign = x < 0 ? -1.0 : 1.0;
    return sign * (3.14159 / 2 - _atan(1 / x.abs()));
  }

  static double _hypot(double x, double y) {
    return (x * x + y * y).abs();
  }
}
