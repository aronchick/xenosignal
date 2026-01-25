import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/data_exports.dart';
import '../domain/domain_exports.dart';

/// Coordinates audio and haptic feedback based on signal strength.
///
/// Manages the click timing loop, tracks signal trends for pitch adjustment,
/// and triggers alerts on significant signal changes.
class FeedbackController extends ChangeNotifier {
  FeedbackController({
    AudioService? audioService,
    HapticService? hapticService,
    FeedbackSettings? settings,
  })  : _audioService = audioService ?? AudioService(),
        _hapticService = hapticService ?? HapticService(),
        _settings = settings ?? const FeedbackSettings(),
        _clickCalculator = const ClickCalculator();

  final AudioService _audioService;
  final HapticService _hapticService;
  final ClickCalculator _clickCalculator;
  FeedbackSettings _settings;

  Timer? _clickTimer;
  double _currentSignalQuality = 0.0;
  double _signalTrend = 0.0;
  final List<_SignalSample> _signalHistory = [];
  bool _isRunning = false;

  // Alert debouncing
  DateTime? _lastAlertTime;
  static const _alertCooldown = Duration(seconds: 30);

  // Signal state tracking for alerts
  _SignalState _lastSignalState = _SignalState.unknown;

  /// Current settings
  FeedbackSettings get settings => _settings;

  /// Whether feedback is currently running
  bool get isRunning => _isRunning;

  /// Current signal quality being tracked
  double get currentSignalQuality => _currentSignalQuality;

  /// Initialize both audio and haptic services.
  Future<void> initialize() async {
    await Future.wait([
      _audioService.initialize(),
      _hapticService.initialize(),
    ]);
  }

  /// Update settings for both services.
  Future<void> updateSettings(FeedbackSettings newSettings) async {
    _settings = newSettings;
    await _audioService.updateSettings(newSettings);
    _hapticService.updateSettings(newSettings);
    notifyListeners();
  }

  /// Start the feedback loop.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _scheduleNextClick();
    notifyListeners();
  }

  /// Stop the feedback loop.
  void stop() {
    _clickTimer?.cancel();
    _clickTimer = null;
    _isRunning = false;
    notifyListeners();
  }

  /// Update with a new signal quality reading.
  ///
  /// [quality] should be 0.0 to 1.0 (0% to 100%)
  void updateSignalQuality(double quality) {
    final clamped = quality.clamp(0.0, 1.0);
    _currentSignalQuality = clamped;

    // Record for trend calculation
    _signalHistory.add(_SignalSample(clamped, DateTime.now()));
    _pruneOldSamples();
    _calculateTrend();

    // Check for alert conditions
    _checkAlertConditions(clamped);

    // Reschedule click with new timing
    if (_isRunning) {
      _scheduleNextClick();
    }
  }

  /// Mute audio due to system event (phone call, etc.).
  void muteBySystem() {
    _audioService.muteBySystem();
  }

  /// Unmute audio after system event.
  void unmuteBySystem() {
    _audioService.unmuteBySystem();
  }

  /// Release all resources.
  @override
  Future<void> dispose() async {
    stop();
    await _audioService.dispose();
    await _hapticService.dispose();
    super.dispose();
  }

  void _scheduleNextClick() {
    _clickTimer?.cancel();

    final interval = _clickCalculator.clickInterval(_currentSignalQuality);

    _clickTimer = Timer(interval, () {
      _fireClick();
      if (_isRunning) {
        _scheduleNextClick();
      }
    });
  }

  Future<void> _fireClick() async {
    final pitchMultiplier = _clickCalculator.pitchMultiplier(_signalTrend);

    // Fire audio and haptic in parallel
    await Future.wait([
      _audioService.playClick(pitchMultiplier: pitchMultiplier),
      _hapticService.clickPulse(intensity: _currentSignalQuality),
    ]);
  }

  void _pruneOldSamples() {
    final cutoff = DateTime.now().subtract(const Duration(seconds: 5));
    _signalHistory.removeWhere((sample) => sample.timestamp.isBefore(cutoff));
  }

  void _calculateTrend() {
    if (_signalHistory.length < 2) {
      _signalTrend = 0.0;
      return;
    }

    // Calculate trend over last 3 seconds
    final now = DateTime.now();
    final threeSecondsAgo = now.subtract(const Duration(seconds: 3));
    final recentSamples = _signalHistory
        .where((s) => s.timestamp.isAfter(threeSecondsAgo))
        .toList();

    if (recentSamples.length < 2) {
      _signalTrend = 0.0;
      return;
    }

    // Simple linear trend: (newest - oldest) / time_span
    final oldest = recentSamples.first;
    final newest = recentSamples.last;
    final timeDelta =
        newest.timestamp.difference(oldest.timestamp).inMilliseconds / 1000.0;

    if (timeDelta < 0.5) {
      _signalTrend = 0.0;
      return;
    }

    _signalTrend = (newest.quality - oldest.quality) / timeDelta;
    // Clamp to reasonable range
    _signalTrend = _signalTrend.clamp(-1.0, 1.0);
  }

  void _checkAlertConditions(double quality) {
    final newState = _classifySignalState(quality);

    // Skip if no state change or same state
    if (newState == _lastSignalState || newState == _SignalState.unknown) {
      return;
    }

    // Check alert cooldown
    if (_lastAlertTime != null &&
        DateTime.now().difference(_lastAlertTime!) < _alertCooldown) {
      _lastSignalState = newState;
      return;
    }

    // Check for significant transitions
    if (_lastSignalState == _SignalState.poor && newState == _SignalState.good) {
      _fireSignalFoundAlert();
    } else if (_lastSignalState == _SignalState.good &&
        newState == _SignalState.poor) {
      _fireSignalLostAlert();
    }

    _lastSignalState = newState;
  }

  _SignalState _classifySignalState(double quality) {
    if (quality > 0.6) return _SignalState.good;
    if (quality < 0.3) return _SignalState.poor;
    return _SignalState.fair;
  }

  Future<void> _fireSignalFoundAlert() async {
    _lastAlertTime = DateTime.now();
    await Future.wait([
      _audioService.playAlert(AlertType.signalFound),
      _hapticService.alertPulse(AlertHapticType.signalFound),
    ]);
  }

  Future<void> _fireSignalLostAlert() async {
    _lastAlertTime = DateTime.now();
    await Future.wait([
      _audioService.playAlert(AlertType.signalLost),
      _hapticService.alertPulse(AlertHapticType.signalLost),
    ]);
  }
}

class _SignalSample {
  const _SignalSample(this.quality, this.timestamp);
  final double quality;
  final DateTime timestamp;
}

enum _SignalState { unknown, poor, fair, good }
