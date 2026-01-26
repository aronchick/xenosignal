import 'dart:async';

import '../../signal_tracking/data/signal_repository.dart';
import '../../signal_tracking/domain/signal_reading.dart';
import '../domain/signal_map_point.dart';
import 'heatmap_repository.dart';
import 'location_service.dart';

/// Automatic signal recording service.
///
/// Records signal readings at regular intervals when enabled,
/// associating them with the current GPS location.
class SignalRecorder {
  SignalRecorder({
    required HeatmapRepository repository,
    required SignalRepository signalRepository,
    LocationService? locationService,
  })  : _repository = repository,
        _signalRepository = signalRepository,
        _locationService = locationService ?? LocationService();

  final HeatmapRepository _repository;
  final SignalRepository _signalRepository;
  final LocationService _locationService;

  Timer? _recordingTimer;
  StreamSubscription<GeoPosition>? _locationSubscription;

  GeoPosition? _lastPosition;
  bool _isRecording = false;

  /// Whether automatic recording is active.
  bool get isRecording => _isRecording;

  /// Recording interval in seconds.
  int _intervalSeconds = HeatmapRepository.defaultRecordingIntervalSeconds;

  /// Gets the current recording interval.
  int get intervalSeconds => _intervalSeconds;

  /// Sets the recording interval.
  set intervalSeconds(int value) {
    _intervalSeconds = value;
    if (_isRecording) {
      // Restart with new interval
      stopRecording();
      startRecording();
    }
  }

  /// Starts automatic recording.
  ///
  /// Requests location permission if not already granted.
  /// Returns true if recording started successfully.
  Future<bool> startRecording() async {
    if (_isRecording) return true;

    // Check location permission
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      return false;
    }

    // Start location tracking
    await _locationService.startTracking();
    _locationSubscription = _locationService.positionStream.listen(
      (position) {
        _lastPosition = position;
      },
    );

    // Get initial position
    try {
      _lastPosition = await _locationService.getCurrentPosition();
    } catch (e) {
      // Will get position from stream
    }

    // Start periodic recording
    _recordingTimer = Timer.periodic(
      Duration(seconds: _intervalSeconds),
      (_) => _recordReading(),
    );

    _isRecording = true;
    return true;
  }

  /// Stops automatic recording.
  Future<void> stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    await _locationService.stopTracking();

    _isRecording = false;
  }

  /// Manually records the current signal at the current location.
  ///
  /// Can be used when automatic recording is off, or to mark
  /// a location with a label.
  Future<SignalMapPoint?> recordManualPin({
    String? label,
  }) async {
    GeoPosition? position = _lastPosition;
    if (position == null) {
      try {
        position = await _locationService.getCurrentPosition();
      } catch (_) {
        return null;
      }
    }

    final reading = await _getBestSignal();
    if (reading == null) return null;

    return _repository.recordReading(
      reading: reading,
      position: position,
      accuracyMeters: position.accuracy ?? 10.0,
      isManualPin: true,
      label: label,
    );
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await stopRecording();
    await _locationService.dispose();
  }

  Future<void> _recordReading() async {
    if (_lastPosition == null) return;

    try {
      final reading = await _getBestSignal();
      if (reading == null) return;

      await _repository.recordReading(
        reading: reading,
        position: _lastPosition!,
        accuracyMeters: _lastPosition!.accuracy ?? 10.0,
      );
    } catch (e) {
      // Silently ignore recording errors to avoid disrupting the app
    }
  }

  /// Gets the best available signal reading (WiFi preferred over cellular).
  Future<SignalReading?> _getBestSignal() async {
    final signals = await _signalRepository.getAllSignals();

    // Prefer WiFi if available and connected
    if (signals.wifi != null) {
      return signals.wifi;
    }

    // Fall back to cellular
    return signals.cellular;
  }
}
