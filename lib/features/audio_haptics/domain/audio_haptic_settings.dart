/// Settings for audio and haptic feedback.
///
/// Controls whether Geiger counter clicks and haptic pulses are enabled.
class AudioHapticSettings {
  const AudioHapticSettings({
    this.audioEnabled = true,
    this.hapticEnabled = true,
    this.volume = 0.7,
  });

  /// Whether Geiger counter audio clicks are enabled.
  final bool audioEnabled;

  /// Whether haptic vibration pulses are enabled.
  final bool hapticEnabled;

  /// Audio volume from 0.0 (silent) to 1.0 (full).
  final double volume;

  /// Creates a copy with optional field overrides.
  AudioHapticSettings copyWith({
    bool? audioEnabled,
    bool? hapticEnabled,
    double? volume,
  }) {
    return AudioHapticSettings(
      audioEnabled: audioEnabled ?? this.audioEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      volume: volume ?? this.volume,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioHapticSettings &&
          audioEnabled == other.audioEnabled &&
          hapticEnabled == other.hapticEnabled &&
          volume == other.volume;

  @override
  int get hashCode => Object.hash(audioEnabled, hapticEnabled, volume);
}
