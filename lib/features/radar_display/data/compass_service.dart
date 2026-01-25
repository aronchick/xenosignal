import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';

import '../domain/compass_smoother.dart';

/// Status of the compass service.
enum CompassStatus {
  /// Compass is working and providing readings.
  active,

  /// Compass permission not granted.
  permissionDenied,

  /// Device has no compass hardware.
  unavailable,

  /// Compass is offline (no readings received).
  offline,
}

/// Service for accessing device compass with smoothed heading data.
///
/// Wraps [FlutterCompass] and applies Kalman filtering for stable readings.
/// Provides heading as degrees clockwise from North (0° = North, 90° = East).
class CompassService {
  final CompassSmoother _smoother = CompassSmoother();
  StreamSubscription<CompassEvent>? _subscription;
  Timer? _offlineTimer;

  CompassStatus _status = CompassStatus.offline;
  double _lastRawHeading = 0;
  double _accuracy = 0;

  /// Timeout before marking compass as offline (no readings).
  static const Duration offlineTimeout = Duration(seconds: 3);

  /// Stream of smoothed heading values in degrees (0-360).
  final StreamController<double> _headingController =
      StreamController<double>.broadcast();

  /// Stream of compass status changes.
  final StreamController<CompassStatus> _statusController =
      StreamController<CompassStatus>.broadcast();

  /// Stream of smoothed compass headings.
  Stream<double> get headingStream => _headingController.stream;

  /// Stream of status changes.
  Stream<CompassStatus> get statusStream => _statusController.stream;

  /// Current compass status.
  CompassStatus get status => _status;

  /// Current smoothed heading in degrees.
  double get heading => _smoother.currentHeading;

  /// Last raw (unfiltered) heading from sensor.
  double get rawHeading => _lastRawHeading;

  /// Compass accuracy in degrees (lower is better).
  double get accuracy => _accuracy;

  /// Whether compass is providing valid readings.
  bool get isActive => _status == CompassStatus.active;

  /// Starts the compass service and begins streaming headings.
  void start() {
    // Check if compass is available (events stream is null if not supported)
    final events = FlutterCompass.events;
    if (events == null) {
      _setStatus(CompassStatus.unavailable);
      return;
    }

    // Subscribe to compass events
    _subscription = events.listen(
      _onCompassEvent,
      onError: _onCompassError,
    );

    // Start offline detection timer
    _startOfflineTimer();
  }

  /// Stops the compass service.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _offlineTimer?.cancel();
    _offlineTimer = null;
    _setStatus(CompassStatus.offline);
  }

  /// Disposes of all resources.
  void dispose() {
    stop();
    _headingController.close();
    _statusController.close();
  }

  void _onCompassEvent(CompassEvent event) {
    // Handle null heading (permission issue or sensor error)
    if (event.heading == null) {
      _setStatus(CompassStatus.permissionDenied);
      return;
    }

    _lastRawHeading = event.heading!;
    _accuracy = event.accuracy ?? 0;

    // Apply smoothing
    final smoothedHeading = _smoother.filter(_lastRawHeading);

    // Update status to active
    if (_status != CompassStatus.active) {
      _setStatus(CompassStatus.active);
    }

    // Emit smoothed heading
    _headingController.add(smoothedHeading);

    // Reset offline timer
    _startOfflineTimer();
  }

  void _onCompassError(Object error) {
    _setStatus(CompassStatus.unavailable);
  }

  void _setStatus(CompassStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }

  void _startOfflineTimer() {
    _offlineTimer?.cancel();
    _offlineTimer = Timer(offlineTimeout, () {
      if (_status == CompassStatus.active) {
        _setStatus(CompassStatus.offline);
      }
    });
  }
}
