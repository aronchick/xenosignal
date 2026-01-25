import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback service for tactile signal indication.
///
/// Produces vibration pulses that mirror Geiger counter audio,
/// allowing silent operation while maintaining signal awareness.
///
/// Pulse patterns:
/// - Poor signal: Soft, slow pulses
/// - Excellent signal: Rapid, crisp pulses
class HapticService {
  HapticService();

  Timer? _pulseTimer;
  bool _isEnabled = false;
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;
  int _currentQuality = 0;

  /// Whether the haptic service is currently active.
  bool get isEnabled => _isEnabled;

  /// Whether the device supports vibration.
  bool get isSupported => _hasVibrator;

  /// Initializes the haptic service and checks device capabilities.
  Future<void> initialize() async {
    _hasVibrator = await Vibration.hasVibrator();
    _hasAmplitudeControl = await Vibration.hasAmplitudeControl();
  }

  /// Starts haptic pulses with the given signal quality.
  ///
  /// [qualityScore] should be 0-100.
  void start(int qualityScore) {
    if (!_hasVibrator) return;

    _isEnabled = true;
    _currentQuality = qualityScore;
    _scheduleNextPulse();
  }

  /// Updates the signal quality, adjusting pulse frequency.
  void updateSignalQuality(int qualityScore) {
    if (!_isEnabled) return;

    _currentQuality = qualityScore.clamp(0, 100);
    // Timer will adjust on next tick
  }

  /// Stops haptic pulses.
  void stop() {
    _isEnabled = false;
    _pulseTimer?.cancel();
    _pulseTimer = null;
  }

  /// Triggers a single haptic pulse.
  ///
  /// Useful for discrete events like "signal acquired" or "on target".
  Future<void> pulse({int durationMs = 50, int? amplitude}) async {
    if (!_hasVibrator) return;

    if (_hasAmplitudeControl && amplitude != null) {
      await Vibration.vibrate(
        duration: durationMs,
        amplitude: amplitude.clamp(1, 255),
      );
    } else {
      await Vibration.vibrate(duration: durationMs);
    }
  }

  /// Triggers a pattern for significant events.
  ///
  /// [pattern] is a list of durations in milliseconds,
  /// alternating between vibrate and pause.
  Future<void> pattern(List<int> pattern, {int? amplitude}) async {
    if (!_hasVibrator) return;

    if (_hasAmplitudeControl && amplitude != null) {
      await Vibration.vibrate(
        pattern: pattern,
        amplitude: amplitude.clamp(1, 255),
      );
    } else {
      await Vibration.vibrate(pattern: pattern);
    }
  }

  /// Triggers a light haptic feedback using system APIs.
  ///
  /// More subtle than vibration, preferred for UI interactions.
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Triggers a medium haptic feedback.
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Triggers a heavy haptic feedback.
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Releases resources.
  void dispose() {
    stop();
  }

  void _scheduleNextPulse() {
    if (!_isEnabled || !_hasVibrator) return;

    final interval = _calculateInterval(_currentQuality);
    final pulseDuration = _calculatePulseDuration(_currentQuality);
    final amplitude = _calculateAmplitude(_currentQuality);

    _pulseTimer?.cancel();
    _pulseTimer = Timer(Duration(milliseconds: interval), () async {
      if (!_isEnabled) return;

      // Trigger pulse
      await pulse(durationMs: pulseDuration, amplitude: amplitude);

      // Schedule next
      _scheduleNextPulse();
    });
  }

  /// Calculates pulse interval matching audio click frequency.
  int _calculateInterval(int quality) {
    const minInterval = 100; // Slightly slower than audio to avoid motor wear
    const maxInterval = 2000;

    final ratio = quality / 100.0;
    final interval = maxInterval * math.pow(minInterval / maxInterval, ratio);

    return interval.round().clamp(minInterval, maxInterval);
  }

  /// Calculates pulse duration based on signal quality.
  ///
  /// Stronger signals get crisper, shorter pulses.
  int _calculatePulseDuration(int quality) {
    // Strong signal: short, crisp 20ms pulses
    // Weak signal: longer 50ms pulses
    const minDuration = 20;
    const maxDuration = 50;

    return (maxDuration - (quality / 100.0 * (maxDuration - minDuration)))
        .round()
        .clamp(minDuration, maxDuration);
  }

  /// Calculates vibration amplitude based on signal quality.
  ///
  /// Returns value 1-255 for devices with amplitude control.
  int _calculateAmplitude(int quality) {
    // Stronger signal: stronger vibration
    const minAmplitude = 64;
    const maxAmplitude = 200;

    return (minAmplitude + (quality / 100.0 * (maxAmplitude - minAmplitude)))
        .round()
        .clamp(minAmplitude, maxAmplitude);
  }
}
