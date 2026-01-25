import 'dart:math' as math;

/// Kalman filter for smoothing compass readings.
///
/// Raw compass data is noisy, especially indoors. This filter provides
/// smooth heading changes while remaining responsive to real direction changes.
/// Uses a 1D Kalman filter with angular wrapping to handle the 0°/360° boundary.
class CompassSmoother {
  /// Current estimate of the heading.
  double _estimate = 0;

  /// Current error in the estimate.
  double _errorEstimate = 1;

  /// Measurement error (sensor noise).
  final double _errorMeasure;

  /// Process noise (how much we expect the heading to change).
  final double _processNoise;

  /// Creates a compass smoother with configurable noise parameters.
  ///
  /// Lower [measurementError] = trust sensor more (faster response, more jitter).
  /// Higher [processNoise] = expect more movement (faster response).
  CompassSmoother({
    double measurementError = 0.5,
    double processNoise = 0.1,
  })  : _errorMeasure = measurementError,
        _processNoise = processNoise;

  /// Filters a raw compass reading and returns smoothed heading.
  ///
  /// [measurement] should be in degrees (0-360).
  /// Returns smoothed heading in degrees (0-360).
  double filter(double measurement) {
    // Handle angular wrapping (e.g., 359° to 1° should not jump through 180°)
    double diff = _angleDifference(measurement, _estimate);

    // Kalman gain
    double kalmanGain = _errorEstimate / (_errorEstimate + _errorMeasure);

    // Update estimate (add the angular difference, not absolute value)
    _estimate = _normalizeAngle(_estimate + kalmanGain * diff);

    // Update error estimate
    _errorEstimate = (1 - kalmanGain) * _errorEstimate + _processNoise;

    return _estimate;
  }

  /// Resets the filter to a specific heading.
  ///
  /// Use when the filter should immediately adopt a new heading
  /// without smoothing (e.g., on app resume or major location change).
  void reset(double heading) {
    _estimate = _normalizeAngle(heading);
    _errorEstimate = 1;
  }

  /// Gets the current smoothed heading.
  double get currentHeading => _estimate;

  /// Calculates the shortest angular difference between two angles.
  ///
  /// Returns value in range [-180, 180].
  double _angleDifference(double a, double b) {
    double diff = a - b;
    // Normalize to [-180, 180]
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    return diff;
  }

  /// Normalizes an angle to [0, 360).
  double _normalizeAngle(double angle) {
    angle = angle % 360;
    if (angle < 0) angle += 360;
    return angle;
  }
}

/// Converts degrees to radians.
double degreesToRadians(double degrees) => degrees * (math.pi / 180);

/// Converts radians to degrees.
double radiansToDegrees(double radians) => radians * (180 / math.pi);
