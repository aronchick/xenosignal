/// Available sound themes for the Geiger counter audio feedback.
///
/// Each theme provides a different audio character while maintaining
/// the core click-frequency-to-signal-strength relationship.
enum SoundTheme {
  /// Movie-accurate M314 Motion Tracker sounds
  classicM314('Classic M314', 'click_classic.wav'),

  /// Cleaner digital scanner sounds
  modernScanner('Modern Scanner', 'click_modern.wav'),

  /// 80s synthesizer-style sounds
  retroSynth('Retro Synth', 'click_synth.wav'),

  /// Subtle, minimal clicks for discrete operation
  minimal('Minimal', 'click_minimal.wav');

  const SoundTheme(this.displayName, this.clickAsset);

  /// Human-readable name for UI display
  final String displayName;

  /// Asset filename for the click sound
  final String clickAsset;

  /// Full asset path for the click sound
  String get clickAssetPath => 'assets/audio/$clickAsset';
}
