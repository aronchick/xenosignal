import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../signal_tracking/domain/signal_reading.dart';

/// Service for accessing device location.
///
/// Wraps the geolocator package and handles permission requests.
class LocationService {
  LocationService();

  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<GeoPosition>.broadcast();

  /// Stream of position updates.
  Stream<GeoPosition> get positionStream => _positionController.stream;

  /// Current location settings.
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Minimum distance (meters) before update
  );

  /// Checks and requests location permissions.
  ///
  /// Returns true if permission is granted.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Gets the current position.
  ///
  /// Throws if permission is not granted.
  Future<GeoPosition> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: _settings,
    );
    return _toGeoPosition(position);
  }

  /// Starts streaming position updates.
  Future<void> startTracking() async {
    await stopTracking();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _settings,
    ).listen(
      (position) {
        _positionController.add(_toGeoPosition(position));
      },
      onError: (error) {
        _positionController.addError(error);
      },
    );
  }

  /// Stops streaming position updates.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calculates distance between two positions in meters.
  double distanceBetween(GeoPosition from, GeoPosition to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Calculates bearing from one position to another in degrees.
  double bearingBetween(GeoPosition from, GeoPosition to) {
    return Geolocator.bearingBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await stopTracking();
    await _positionController.close();
  }

  GeoPosition _toGeoPosition(Position position) {
    return GeoPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
    );
  }
}
