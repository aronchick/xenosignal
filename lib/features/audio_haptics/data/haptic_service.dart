import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../domain/domain_exports.dart';

/// Manages haptic feedback for tactile signal indication.
///
/// Provides vibration patterns that mirror audio cues, with enhanced
/// intensity in silent mode. Uses the device's haptic engine when
/// available for crisp feedback.
class HapticService {
  HapticService({FeedbackSettings? settings})
      : _settings = settings ?? const FeedbackSettings();

  FeedbackSettings _settings;
  bool _isInitialized = false;
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;

  /// Current settings
  FeedbackSettings get settings => _settings;

  /// Whether haptics can fire
  bool get canVibrate => _isInitialized && _hasVibrator && _settings.isHapticActive;

  /// Initialize haptic capabilities check.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl();
      _isInitialized = true;
    } catch (e) {
      debugPrint('HapticService initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Update settings.
  void updateSettings(FeedbackSettings newSettings) {
    _settings = newSettings;
  }

  /// Fire a single click haptic.
  ///
  /// [intensity] is 0.0 to 1.0, mapped to amplitude if supported.
  Future<void> clickPulse({double intensity = 0.5}) async {
    if (!canVibrate) return;

    try {
      // Enhance intensity in silent mode
      final effectiveIntensity =
          _settings.silentMode ? (intensity * 1.5).clamp(0.0, 1.0) : intensity;

      if (_hasAmplitudeControl) {
        // Use amplitude control for precise feedback
        final amplitude = (effectiveIntensity * 255).round();
        await Vibration.vibrate(duration: 20, amplitude: amplitude);
      } else {
        // Fall back to system haptic feedback
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Click haptic failed: $e');
    }
  }

  /// Fire a ping haptic (longer, more pronounced).
  Future<void> pingPulse() async {
    if (!canVibrate) return;

    try {
      if (_hasAmplitudeControl) {
        // Double pulse pattern for ping
        await Vibration.vibrate(
          pattern: [0, 50, 30, 50],
          intensities: [0, 200, 0, 200],
        );
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      debugPrint('Ping haptic failed: $e');
    }
  }

  /// Fire an alert haptic (strong, distinctive pattern).
  Future<void> alertPulse(AlertHapticType type) async {
    if (!canVibrate) return;

    try {
      switch (type) {
        case AlertHapticType.signalFound:
          // Triumphant ascending pattern
          if (_hasAmplitudeControl) {
            await Vibration.vibrate(
              pattern: [0, 30, 20, 50, 20, 100],
              intensities: [0, 100, 0, 180, 0, 255],
            );
          } else {
            await HapticFeedback.heavyImpact();
          }
        case AlertHapticType.signalLost:
          // Warning descending pattern
          if (_hasAmplitudeControl) {
            await Vibration.vibrate(
              pattern: [0, 100, 50, 50, 50, 30],
              intensities: [0, 255, 0, 180, 0, 100],
            );
          } else {
            await HapticFeedback.heavyImpact();
          }
        case AlertHapticType.onTarget:
          // Confirmation double-tap
          if (_hasAmplitudeControl) {
            await Vibration.vibrate(
              pattern: [0, 40, 30, 40],
              intensities: [0, 200, 0, 200],
            );
          } else {
            await HapticFeedback.selectionClick();
          }
      }
    } catch (e) {
      debugPrint('Alert haptic failed: $e');
    }
  }

  /// Fire navigation confirmation when device aligns with target direction.
  Future<void> directionConfirm() async {
    if (!canVibrate) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Direction confirm haptic failed: $e');
    }
  }

  /// Release resources (no-op for haptics, but maintains interface parity).
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Types of haptic alerts.
enum AlertHapticType {
  /// Signal improved significantly
  signalFound,

  /// Signal degraded significantly
  signalLost,

  /// Device aligned with target direction
  onTarget,
}
