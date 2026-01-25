import 'dart:math' as math;

/// Represents a signal blip to be rendered on the radar display.
///
/// Blips can be either centered (representing current signal strength)
/// or directional (representing historical signals at known locations).
class SignalBlip {
  /// Creates a signal blip.
  const SignalBlip({
    required this.intensity,
    required this.createdAtSweepCount,
    this.angle,
    this.distance,
    this.isCurrentSignal = false,
  }) : assert(
          intensity >= 0 && intensity <= 1,
          'intensity must be between 0 and 1',
        ),
       assert(
          distance == null || (distance >= 0 && distance <= 1),
          'distance must be between 0 and 1',
        );

  /// Creates a center blip representing the current signal.
  ///
  /// [intensity] is derived from signal quality (0-1, where 1 is excellent).
  /// [sweepCount] is the current sweep count when this reading was taken.
  factory SignalBlip.current({
    required double intensity,
    required int sweepCount,
  }) {
    return SignalBlip(
      intensity: intensity,
      createdAtSweepCount: sweepCount,
      isCurrentSignal: true,
    );
  }

  /// Creates a directional blip representing a historical signal.
  ///
  /// [angle] is the direction in radians (0 = up/north, clockwise).
  /// [distance] is the relative distance from center (0-1, where 1 is edge).
  /// [intensity] is derived from signal quality (0-1).
  /// [sweepCount] is the sweep count when this reading was taken.
  factory SignalBlip.directional({
    required double angle,
    required double distance,
    required double intensity,
    required int sweepCount,
  }) {
    return SignalBlip(
      angle: angle,
      distance: distance,
      intensity: intensity,
      createdAtSweepCount: sweepCount,
      isCurrentSignal: false,
    );
  }

  /// Signal intensity from 0 (no signal) to 1 (excellent).
  ///
  /// This controls both the brightness and size of the blip.
  final double intensity;

  /// The sweep count when this blip was created.
  ///
  /// Used to calculate fade: blips fade out over [kFadeSweepCount] sweeps.
  final int createdAtSweepCount;

  /// Direction of the blip in radians (0 = up, clockwise).
  ///
  /// Null for center/current signal blips.
  final double? angle;

  /// Distance from center as fraction of radius (0 = center, 1 = edge).
  ///
  /// Null for center/current signal blips.
  final double? distance;

  /// Whether this blip represents the current signal (drawn at center).
  final bool isCurrentSignal;

  /// Number of sweep rotations before a blip fully fades.
  static const int kFadeSweepCount = 4;

  /// Minimum intensity multiplier at full fade.
  static const double kMinFadeIntensity = 0.1;

  /// Base blip radius as fraction of radar radius.
  static const double kBaseBlipRadius = 0.04;

  /// Maximum blip radius multiplier for strong signals.
  static const double kMaxBlipRadiusMultiplier = 2.0;

  /// Calculates the current opacity based on sweep count.
  ///
  /// Returns a value from 0 (fully faded) to 1 (fully visible).
  double calculateOpacity(int currentSweepCount) {
    final sweepsSinceCreation = currentSweepCount - createdAtSweepCount;

    if (sweepsSinceCreation < 0) {
      // Blip from the future? Shouldn't happen, but handle gracefully.
      return 1.0;
    }

    if (sweepsSinceCreation >= kFadeSweepCount) {
      return 0.0;
    }

    // Linear fade over kFadeSweepCount sweeps
    final fadeProgress = sweepsSinceCreation / kFadeSweepCount;
    return 1.0 - fadeProgress;
  }

  /// Calculates the effective intensity (intensity * fade).
  double effectiveIntensity(int currentSweepCount) {
    final opacity = calculateOpacity(currentSweepCount);
    return intensity * math.max(opacity, kMinFadeIntensity);
  }

  /// Whether this blip should still be rendered.
  bool isVisible(int currentSweepCount) {
    return calculateOpacity(currentSweepCount) > 0;
  }

  /// Calculates the blip radius based on intensity.
  ///
  /// Stronger signals have larger blips.
  double calculateRadius(double radarRadius) {
    final baseRadius = radarRadius * kBaseBlipRadius;
    final intensityMultiplier = 1.0 + (intensity * (kMaxBlipRadiusMultiplier - 1.0));
    return baseRadius * intensityMultiplier;
  }

  @override
  String toString() {
    if (isCurrentSignal) {
      return 'SignalBlip.current(intensity: $intensity, sweep: $createdAtSweepCount)';
    }
    return 'SignalBlip.directional(angle: $angle, distance: $distance, '
        'intensity: $intensity, sweep: $createdAtSweepCount)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignalBlip &&
          intensity == other.intensity &&
          createdAtSweepCount == other.createdAtSweepCount &&
          angle == other.angle &&
          distance == other.distance &&
          isCurrentSignal == other.isCurrentSignal;

  @override
  int get hashCode => Object.hash(
        intensity,
        createdAtSweepCount,
        angle,
        distance,
        isCurrentSignal,
      );
}
