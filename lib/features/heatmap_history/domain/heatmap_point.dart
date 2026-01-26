import 'dart:math' as math;

import '../../signal_tracking/domain/signal_reading.dart';

/// A recorded signal point for heatmap visualization.
///
/// Captures a signal reading at a specific location with temporal
/// metadata for aging calculations.
class HeatmapPoint {
  /// Creates a heatmap point from a signal reading.
  const HeatmapPoint({
    required this.id,
    required this.position,
    required this.qualityScore,
    required this.recordedAt,
    this.isManualPin = false,
    this.label,
  });

  /// Creates a heatmap point from a SignalReading.
  factory HeatmapPoint.fromReading(SignalReading reading, {String? label}) {
    if (reading.location == null) {
      throw ArgumentError('SignalReading must have a location');
    }
    return HeatmapPoint(
      id: '${reading.timestamp.microsecondsSinceEpoch}',
      position: reading.location!,
      qualityScore: reading.qualityScore,
      recordedAt: reading.timestamp,
      label: label,
    );
  }

  /// Unique identifier for this point.
  final String id;

  /// Geographic position of this reading.
  final GeoPosition position;

  /// Normalized quality score (0-100).
  final int qualityScore;

  /// When this reading was recorded.
  final DateTime recordedAt;

  /// Whether this was manually pinned by the user.
  final bool isManualPin;

  /// Optional user label for manual pins.
  final String? label;

  /// Duration since this point was recorded.
  Duration get age => DateTime.now().difference(recordedAt);

  /// Age in minutes for convenience.
  double get ageMinutes => age.inMilliseconds / 60000.0;

  /// The aging window in minutes (1 hour).
  static const double agingWindowMinutes = 60.0;

  /// Calculates the opacity/alpha for this point based on age.
  ///
  /// - Fresh (0 min): 1.0 (full opacity)
  /// - Aging (0-60 min): Linear fade from 1.0 to 0.3
  /// - Historical (>60 min): 0.2 (ghost/historical indicator)
  ///
  /// Manual pins don't fade as quickly.
  double get temporalAlpha {
    final minutes = ageMinutes;

    if (minutes <= 0) return 1.0;

    if (minutes < agingWindowMinutes) {
      // Linear fade from 1.0 to 0.3 over the aging window
      // Manual pins fade slower (1.0 to 0.5)
      final minAlpha = isManualPin ? 0.5 : 0.3;
      return 1.0 - ((1.0 - minAlpha) * (minutes / agingWindowMinutes));
    }

    // Historical - faded but still visible as "memory"
    return isManualPin ? 0.4 : 0.2;
  }

  /// Whether this point is considered "fresh" (within aging window).
  bool get isFresh => ageMinutes < agingWindowMinutes;

  /// Whether this point is historical (past aging window).
  bool get isHistorical => !isFresh;

  /// Calculates bearing from one point to another in radians.
  ///
  /// Returns angle from north (0 = north, π/2 = east, etc.)
  static double bearingBetween(GeoPosition from, GeoPosition to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return math.atan2(y, x);
  }

  /// Calculates distance between two points in meters using Haversine formula.
  static double distanceBetween(GeoPosition from, GeoPosition to) {
    const earthRadius = 6371000.0; // meters

    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLat = lat2 - lat1;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  String toString() =>
      'HeatmapPoint(quality: $qualityScore%, age: ${ageMinutes.toStringAsFixed(1)}min, alpha: ${temporalAlpha.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HeatmapPoint && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
