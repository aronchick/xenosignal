import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'heatmap_database.g.dart';

/// Table for storing individual signal map points.
@DataClassName('SignalMapPointRow')
class SignalMapPoints extends Table {
  /// Unique identifier (UUID).
  TextColumn get id => text()();

  /// Latitude in degrees.
  RealColumn get latitude => real()();

  /// Longitude in degrees.
  RealColumn get longitude => real()();

  /// Altitude in meters (nullable).
  RealColumn get altitude => real().nullable()();

  /// GPS accuracy radius in meters.
  RealColumn get radiusMeters => real()();

  /// Signal quality score (0-100).
  IntColumn get qualityScore => integer()();

  /// Signal type: 'wifi' or 'cellular'.
  TextColumn get signalType => text()();

  /// Raw dBm value (nullable, Android only).
  RealColumn get dbm => real().nullable()();

  /// Network name/SSID (nullable).
  TextColumn get networkName => text().nullable()();

  /// Connection type details (nullable).
  TextColumn get connectionType => text().nullable()();

  /// When the reading was recorded.
  DateTimeColumn get recordedAt => dateTime()();

  /// Whether this is a manual pin.
  BoolColumn get isManualPin => boolean().withDefault(const Constant(false))();

  /// User label for manual pins (nullable).
  TextColumn get label => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // Indexes for efficient queries
  @override
  List<String> get customConstraints => [];
}

/// Aggregated tile data for efficient heatmap rendering.
@DataClassName('HeatmapTileRow')
class HeatmapTiles extends Table {
  /// Tile identifier based on bounds.
  TextColumn get id => text()();

  /// Northern latitude boundary.
  RealColumn get north => real()();

  /// Southern latitude boundary.
  RealColumn get south => real()();

  /// Eastern longitude boundary.
  RealColumn get east => real()();

  /// Western longitude boundary.
  RealColumn get west => real()();

  /// Average signal quality (0-100).
  RealColumn get avgSignalQuality => real()();

  /// Peak signal quality (0-100).
  RealColumn get peakSignalQuality => real()();

  /// Number of samples in this tile.
  IntColumn get sampleCount => integer()();

  /// Last update timestamp.
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The heatmap SQLite database.
@DriftDatabase(tables: [SignalMapPoints, HeatmapTiles])
class HeatmapDatabase extends _$HeatmapDatabase {
  HeatmapDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'xenosignal_heatmap');
  }

  /// Inserts or updates a signal map point.
  Future<void> upsertPoint(SignalMapPointRow point) async {
    await into(signalMapPoints).insertOnConflictUpdate(point);
  }

  /// Retrieves points within geographic bounds.
  Future<List<SignalMapPointRow>> getPointsInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    return (select(signalMapPoints)
          ..where((p) =>
              p.latitude.isBetweenValues(south, north) &
              p.longitude.isBetweenValues(west, east)))
        .get();
  }

  /// Retrieves points near a location within a radius.
  Future<List<SignalMapPointRow>> getPointsNear({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    // Approximate degree offset for radius
    // This is a rough approximation; exact haversine would be more accurate
    const metersPerDegree = 111139.0;
    final degreeOffset = radiusMeters / metersPerDegree;

    return getPointsInBounds(
      north: latitude + degreeOffset,
      south: latitude - degreeOffset,
      east: longitude + degreeOffset,
      west: longitude - degreeOffset,
    );
  }

  /// Deletes points older than the retention period.
  Future<int> pruneOldPoints({
    required Duration retentionPeriod,
    bool preserveManualPins = true,
  }) async {
    final cutoff = DateTime.now().subtract(retentionPeriod);

    final query = delete(signalMapPoints)
      ..where((p) => p.recordedAt.isSmallerThanValue(cutoff));

    if (preserveManualPins) {
      query.where((p) => p.isManualPin.equals(false));
    }

    return query.go();
  }

  /// Gets the total count of stored points.
  Future<int> getPointCount() async {
    final count = signalMapPoints.id.count();
    final query = selectOnly(signalMapPoints)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Gets manual pins only.
  Future<List<SignalMapPointRow>> getManualPins() async {
    return (select(signalMapPoints)
          ..where((p) => p.isManualPin.equals(true))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .get();
  }

  /// Inserts or updates a heatmap tile.
  Future<void> upsertTile(HeatmapTileRow tile) async {
    await into(heatmapTiles).insertOnConflictUpdate(tile);
  }

  /// Gets tiles intersecting with bounds.
  Future<List<HeatmapTileRow>> getTilesInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    // Tiles intersect if their bounds overlap with query bounds
    return (select(heatmapTiles)
          ..where((t) =>
              t.south.isSmallerOrEqualValue(north) &
              t.north.isBiggerOrEqualValue(south) &
              t.west.isSmallerOrEqualValue(east) &
              t.east.isBiggerOrEqualValue(west)))
        .get();
  }

  /// Clears all heatmap tiles (for regeneration).
  Future<int> clearTiles() async {
    return delete(heatmapTiles).go();
  }

  /// Gets database size estimate in bytes.
  Future<int> estimateDatabaseSize() async {
    // Approximate: ~200 bytes per point, ~100 bytes per tile
    final pointCount = await getPointCount();
    final tileQuery = selectOnly(heatmapTiles)
      ..addColumns([heatmapTiles.id.count()]);
    final tileResult = await tileQuery.getSingle();
    final tileCount = tileResult.read(heatmapTiles.id.count()) ?? 0;

    return (pointCount * 200) + (tileCount * 100);
  }
}
