import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../domain/domain_exports.dart';

/// Manages audio playback for Geiger counter clicks and alerts.
///
/// Handles audio session management, sound pooling for low-latency clicks,
/// and respects system audio policies (calls, DND, etc.).
class AudioService {
  AudioService({FeedbackSettings? settings})
      : _settings = settings ?? const FeedbackSettings();

  FeedbackSettings _settings;
  AudioPlayer? _clickPlayer;
  AudioPlayer? _pingPlayer;
  AudioPlayer? _alertPlayer;

  bool _isInitialized = false;
  bool _isMutedBySystem = false;

  /// Current settings
  FeedbackSettings get settings => _settings;

  /// Whether audio can currently play
  bool get canPlay => _isInitialized && !_isMutedBySystem && _settings.isAudioActive;

  /// Initialize audio players and load sounds.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _clickPlayer = AudioPlayer();
      _pingPlayer = AudioPlayer();
      _alertPlayer = AudioPlayer();

      // Configure for low latency
      await _clickPlayer!.setReleaseMode(ReleaseMode.stop);
      await _pingPlayer!.setReleaseMode(ReleaseMode.stop);
      await _alertPlayer!.setReleaseMode(ReleaseMode.stop);

      // Pre-load click sound for low latency
      await _preloadClickSound();

      _isInitialized = true;
    } catch (e) {
      debugPrint('AudioService initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Update settings and reload sounds if theme changed.
  Future<void> updateSettings(FeedbackSettings newSettings) async {
    final themeChanged = _settings.soundTheme != newSettings.soundTheme;
    _settings = newSettings;

    if (themeChanged && _isInitialized) {
      await _preloadClickSound();
    }
  }

  /// Play a single click sound.
  ///
  /// [pitchMultiplier] adjusts playback rate (0.9-1.1 typical)
  Future<void> playClick({double pitchMultiplier = 1.0}) async {
    if (!canPlay) return;

    try {
      await _clickPlayer?.setVolume(_settings.effectiveClickVolume);
      await _clickPlayer?.setPlaybackRate(pitchMultiplier.clamp(0.5, 2.0));
      await _clickPlayer?.resume();
    } catch (e) {
      debugPrint('Click playback failed: $e');
    }
  }

  /// Play the proximity ping sound.
  Future<void> playPing() async {
    if (!canPlay) return;

    try {
      await _pingPlayer?.setVolume(_settings.effectivePingVolume);
      // TODO: Load ping asset when available
      // await _pingPlayer?.play(AssetSource('audio/ping.wav'));
    } catch (e) {
      debugPrint('Ping playback failed: $e');
    }
  }

  /// Play an alert sound (signal found/lost).
  Future<void> playAlert(AlertType type) async {
    if (!canPlay) return;

    try {
      await _alertPlayer?.setVolume(_settings.effectiveAlertVolume);
      // TODO: Load alert assets when available
      // final asset = type == AlertType.signalFound
      //     ? 'audio/alert_found.wav'
      //     : 'audio/alert_lost.wav';
      // await _alertPlayer?.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Alert playback failed: $e');
    }
  }

  /// Mute audio (e.g., during phone call).
  void muteBySystem() {
    _isMutedBySystem = true;
  }

  /// Unmute audio after system mute.
  void unmuteBySystem() {
    _isMutedBySystem = false;
  }

  /// Release all audio resources.
  Future<void> dispose() async {
    await _clickPlayer?.dispose();
    await _pingPlayer?.dispose();
    await _alertPlayer?.dispose();
    _clickPlayer = null;
    _pingPlayer = null;
    _alertPlayer = null;
    _isInitialized = false;
  }

  Future<void> _preloadClickSound() async {
    if (_clickPlayer == null) return;

    try {
      // For MVP, use a generated tone. In production, load from assets.
      // await _clickPlayer!.setSource(
      //   AssetSource(_settings.soundTheme.clickAssetPath),
      // );

      // Temporary: Use a URL-based beep for testing
      // In production, replace with bundled assets
      await _clickPlayer!.setSource(
        UrlSource(
          'https://www.soundjay.com/buttons/beep-01a.mp3',
        ),
      );
    } catch (e) {
      debugPrint('Failed to preload click sound: $e');
    }
  }
}

/// Types of alert sounds.
enum AlertType {
  /// Signal improved from poor to good
  signalFound,

  /// Signal dropped from good to poor
  signalLost,

  /// Arrived at navigation destination
  destinationReached,
}
