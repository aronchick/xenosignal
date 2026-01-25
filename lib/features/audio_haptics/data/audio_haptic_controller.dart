import 'dart:async';

import '../../signal_tracking/domain/signal_reading.dart';
import '../domain/audio_haptic_settings.dart';
import 'geiger_audio_service.dart';
import 'haptic_service.dart';

/// Coordinates audio and haptic feedback based on signal readings.
///
/// Listens to a signal stream and updates the Geiger counter clicks
/// and haptic pulses accordingly. Manages settings and lifecycle.
class AudioHapticController {
  AudioHapticController({
    GeigerAudioService? audioService,
    HapticService? hapticService,
  })  : _audioService = audioService ?? GeigerAudioService(),
        _hapticService = hapticService ?? HapticService();

  final GeigerAudioService _audioService;
  final HapticService _hapticService;

  StreamSubscription<SignalReading>? _signalSubscription;
  AudioHapticSettings _settings = const AudioHapticSettings();

  /// Current settings.
  AudioHapticSettings get settings => _settings;

  /// Whether haptic feedback is supported on this device.
  bool get isHapticSupported => _hapticService.isSupported;

  /// Initializes audio and haptic services.
  ///
  /// Must be called before [start].
  Future<void> initialize() async {
    await _audioService.initialize();
    await _hapticService.initialize();
  }

  /// Starts listening to the signal stream.
  ///
  /// Begins audio/haptic feedback based on current settings.
  void start(Stream<SignalReading> signalStream) {
    _signalSubscription?.cancel();
    _signalSubscription = signalStream.listen(_onSignalReading);

    // Start with default quality until first reading
    if (_settings.audioEnabled) {
      _audioService.start(50);
    }
    if (_settings.hapticEnabled) {
      _hapticService.start(50);
    }
  }

  /// Stops audio/haptic feedback.
  void stop() {
    _signalSubscription?.cancel();
    _signalSubscription = null;
    _audioService.stop();
    _hapticService.stop();
  }

  /// Updates the settings.
  Future<void> updateSettings(AudioHapticSettings newSettings) async {
    final oldSettings = _settings;
    _settings = newSettings;

    // Handle audio enable/disable
    if (newSettings.audioEnabled != oldSettings.audioEnabled) {
      if (newSettings.audioEnabled) {
        _audioService.start(50);
      } else {
        _audioService.stop();
      }
    }

    // Handle haptic enable/disable
    if (newSettings.hapticEnabled != oldSettings.hapticEnabled) {
      if (newSettings.hapticEnabled) {
        _hapticService.start(50);
      } else {
        _hapticService.stop();
      }
    }

    // Update volume
    if (newSettings.volume != oldSettings.volume) {
      await _audioService.setVolume(newSettings.volume);
    }
  }

  /// Enables or disables audio feedback.
  Future<void> setAudioEnabled(bool enabled) async {
    await updateSettings(_settings.copyWith(audioEnabled: enabled));
  }

  /// Enables or disables haptic feedback.
  Future<void> setHapticEnabled(bool enabled) async {
    await updateSettings(_settings.copyWith(hapticEnabled: enabled));
  }

  /// Sets the audio volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    await updateSettings(_settings.copyWith(volume: volume));
  }

  /// Releases all resources.
  Future<void> dispose() async {
    stop();
    await _audioService.dispose();
    _hapticService.dispose();
  }

  void _onSignalReading(SignalReading reading) {
    final quality = reading.qualityScore;

    if (_settings.audioEnabled) {
      _audioService.updateSignalQuality(quality);
    }

    if (_settings.hapticEnabled) {
      _hapticService.updateSignalQuality(quality);
    }
  }
}
