import '../../signal_tracking/domain/signal_reading.dart';

/// Rectangular geographic bounds for map tiles and queries.
class GeoBounds {
  /// Creates geographic bounds.
  const GeoBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  }) : assert(north >= south, 'North must be >= south'),
       assert(east >= west || (east < 0 && west > 0), 'Invalid east/west');

  /// Northern latitude boundary.
  final double north;

  /// Southern latitude boundary.
  final double south;

  /// Eastern longitude boundary.
  final double east;

  /// Western longitude boundary.
  final double west;

  /// Creates bounds from a center point and radius in meters.
  factory GeoBounds.fromCenterAndRadius(
    GeoPosition center,
    double radiusMeters,
  ) {
    // Approximate degrees per meter at given latitude
    // 1 degree latitude ≈ 111,139 meters
    // 1 degree longitude ≈ 111,139 * cos(latitude) meters
    const metersPerDegreeLat = 111139.0;
    final metersPerDegreeLon =
        111139.0 * _cos(center.latitude * _degToRad);

    final latDelta = radiusMeters / metersPerDegreeLat;
    final lonDelta = radiusMeters / metersPerDegreeLon;

    return GeoBounds(
      north: center.latitude + latDelta,
      south: center.latitude - latDelta,
      east: center.longitude + lonDelta,
      west: center.longitude - lonDelta,
    );
  }

  /// Center point of the bounds.
  GeoPosition get center => GeoPosition(
        latitude: (north + south) / 2,
        longitude: (east + west) / 2,
      );

  /// Width in degrees longitude.
  double get width => east - west;

  /// Height in degrees latitude.
  double get height => north - south;

  /// Whether a position falls within these bounds.
  bool contains(GeoPosition position) {
    return position.latitude >= south &&
        position.latitude <= north &&
        position.longitude >= west &&
        position.longitude <= east;
  }

  /// Whether these bounds intersect with another bounds.
  bool intersects(GeoBounds other) {
    return !(other.south > north ||
        other.north < south ||
        other.west > east ||
        other.east < west);
  }

  /// Expands bounds to include a position.
  GeoBounds expandToInclude(GeoPosition position) {
    return GeoBounds(
      north: position.latitude > north ? position.latitude : north,
      south: position.latitude < south ? position.latitude : south,
      east: position.longitude > east ? position.longitude : east,
      west: position.longitude < west ? position.longitude : west,
    );
  }

  @override
  String toString() =>
      'GeoBounds(N: $north, S: $south, E: $east, W: $west)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoBounds &&
          north == other.north &&
          south == other.south &&
          east == other.east &&
          west == other.west;

  @override
  int get hashCode => Object.hash(north, south, east, west);
}

// Simple math helpers to avoid dart:math import overhead
const double _degToRad = 0.017453292519943295;

double _cos(double radians) {
  // Taylor series approximation sufficient for our geo calculations
  final x2 = radians * radians;
  final x4 = x2 * x2;
  final x6 = x4 * x2;
  return 1 - x2 / 2 + x4 / 24 - x6 / 720;
}
