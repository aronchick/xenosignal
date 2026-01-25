import 'dart:math' as math;

/// Calculates click timing based on signal strength.
///
/// Maps signal quality (0-100%) to click frequency following the spec:
/// - Excellent (>80%): 8-12 clicks/second
/// - Good (50-80%): 4-8 clicks/second
/// - Fair (30-50%): 1-4 clicks/second
/// - Poor (<30%): 0.5-1 clicks/second
class ClickCalculator {
  const ClickCalculator();

  /// Minimum clicks per second (poor signal)
  static const double minClicksPerSecond = 0.5;

  /// Maximum clicks per second (excellent signal)
  static const double maxClicksPerSecond = 12.0;

  /// Calculate clicks per second for a given signal quality.
  ///
  /// [signalQuality] should be 0.0 to 1.0 (0% to 100%)
  double clicksPerSecond(double signalQuality) {
    final clamped = signalQuality.clamp(0.0, 1.0);

    // Use exponential curve for more dramatic response
    // This gives slow clicks at low signal, rapid at high
    final exponent = 2.5;
    final normalized = math.pow(clamped, 1 / exponent);

    return minClicksPerSecond +
        (maxClicksPerSecond - minClicksPerSecond) * normalized;
  }

  /// Calculate interval between clicks in milliseconds.
  ///
  /// [signalQuality] should be 0.0 to 1.0 (0% to 100%)
  Duration clickInterval(double signalQuality) {
    final cps = clicksPerSecond(signalQuality);
    final intervalMs = (1000 / cps).round();
    return Duration(milliseconds: intervalMs);
  }

  /// Calculate pitch adjustment for signal trends.
  ///
  /// Returns a multiplier for playback rate:
  /// - Improving signal: 1.0 to 1.1 (slightly higher pitch)
  /// - Degrading signal: 0.9 to 1.0 (slightly lower pitch)
  /// - Stable signal: 1.0
  ///
  /// [trend] is the signal change over the last 3 seconds (-1.0 to 1.0)
  double pitchMultiplier(double trend) {
    final clampedTrend = trend.clamp(-1.0, 1.0);
    return 1.0 + (clampedTrend * 0.1);
  }

  /// Determine if a warning undertone should play.
  ///
  /// True when signal is critically low (<15%) and degrading.
  bool shouldPlayWarningUndertone(double signalQuality, double trend) {
    return signalQuality < 0.15 && trend < 0;
  }
}
