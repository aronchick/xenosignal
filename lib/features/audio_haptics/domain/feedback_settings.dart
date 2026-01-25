import 'sound_theme.dart';

/// User preferences for audio and haptic feedback.
///
/// Controls volume levels, enabled states, and audio theme selection.
/// Settings persist across app sessions.
class FeedbackSettings {
  const FeedbackSettings({
    this.audioEnabled = true,
    this.hapticEnabled = true,
    this.masterVolume = 0.7,
    this.clickVolume = 1.0,
    this.pingVolume = 0.8,
    this.alertVolume = 1.0,
    this.soundTheme = SoundTheme.classicM314,
    this.silentMode = false,
  });

  /// Whether audio feedback is enabled
  final bool audioEnabled;

  /// Whether haptic feedback is enabled
  final bool hapticEnabled;

  /// Master volume (0.0 to 1.0)
  final double masterVolume;

  /// Click sound volume relative to master (0.0 to 1.0)
  final double clickVolume;

  /// Ping sound volume relative to master (0.0 to 1.0)
  final double pingVolume;

  /// Alert sound volume relative to master (0.0 to 1.0)
  final double alertVolume;

  /// Selected sound theme
  final SoundTheme soundTheme;

  /// Silent mode - audio off, haptics enhanced
  final bool silentMode;

  /// Effective audio enabled state (considers silent mode)
  bool get isAudioActive => audioEnabled && !silentMode;

  /// Effective haptic enabled state (enhanced in silent mode)
  bool get isHapticActive => hapticEnabled || silentMode;

  /// Calculate effective volume for clicks
  double get effectiveClickVolume => masterVolume * clickVolume;

  /// Calculate effective volume for pings
  double get effectivePingVolume => masterVolume * pingVolume;

  /// Calculate effective volume for alerts
  double get effectiveAlertVolume => masterVolume * alertVolume;

  FeedbackSettings copyWith({
    bool? audioEnabled,
    bool? hapticEnabled,
    double? masterVolume,
    double? clickVolume,
    double? pingVolume,
    double? alertVolume,
    SoundTheme? soundTheme,
    bool? silentMode,
  }) {
    return FeedbackSettings(
      audioEnabled: audioEnabled ?? this.audioEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      clickVolume: clickVolume ?? this.clickVolume,
      pingVolume: pingVolume ?? this.pingVolume,
      alertVolume: alertVolume ?? this.alertVolume,
      soundTheme: soundTheme ?? this.soundTheme,
      silentMode: silentMode ?? this.silentMode,
    );
  }
}
