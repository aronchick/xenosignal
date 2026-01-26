import 'package:uuid/uuid.dart';

import '../../signal_tracking/domain/signal_reading.dart';
import '../../signal_tracking/domain/signal_type.dart';
import '../domain/domain_exports.dart';
import 'heatmap_database.dart';

/// Repository for managing signal heatmap data.
///
/// Provides high-level operations for recording, querying, and managing
/// signal readings with geographic context.
class HeatmapRepository {
  HeatmapRepository({
    HeatmapDatabase? database,
  }) : _database = database ?? HeatmapDatabase();

  final HeatmapDatabase _database;
  final _uuid = const Uuid();

  /// Default data retention period.
  static const defaultRetentionDays = 30;

  /// Default recording interval in seconds.
  static const defaultRecordingIntervalSeconds = 5;

  /// Accuracy threshold for low-confidence readings (meters).
  static const lowConfidenceThreshold = 50.0;

  /// Records a signal reading at the current location.
  ///
  /// Automatically generates an ID and records the current timestamp.
  Future<SignalMapPoint> recordReading({
    required SignalReading reading,
    required GeoPosition position,
    required double accuracyMeters,
    bool isManualPin = false,
    String? label,
  }) async {
    final point = SignalMapPoint(
      id: _uuid.v4(),
      position: position,
      radiusMeters: accuracyMeters,
      reading: reading,
      recordedAt: DateTime.now(),
      isManualPin: isManualPin,
      label: label,
    );

    await _database.upsertPoint(_toRow(point));
    return point;
  }

  /// Gets all points within the specified bounds.
  Future<List<SignalMapPoint>> getPointsInBounds(GeoBounds bounds) async {
    final rows = await _database.getPointsInBounds(
      north: bounds.north,
      south: bounds.south,
      east: bounds.east,
      west: bounds.west,
    );
    return rows.map(_fromRow).toList();
  }

  /// Gets points near a location within the specified radius.
  Future<List<SignalMapPoint>> getPointsNear({
    required GeoPosition position,
    required double radiusMeters,
  }) async {
    final rows = await _database.getPointsNear(
      latitude: position.latitude,
      longitude: position.longitude,
      radiusMeters: radiusMeters,
    );
    return rows.map(_fromRow).toList();
  }

  /// Gets all manual pins.
  Future<List<SignalMapPoint>> getManualPins() async {
    final rows = await _database.getManualPins();
    return rows.map(_fromRow).toList();
  }

  /// Finds the best signal location within the specified radius.
  ///
  /// Returns the point with the highest quality score, or null if none found.
  Future<SignalMapPoint?> findBestSignalNear({
    required GeoPosition position,
    required double radiusMeters,
  }) async {
    final points = await getPointsNear(
      position: position,
      radiusMeters: radiusMeters,
    );

    if (points.isEmpty) return null;

    return points.reduce((best, current) =>
        current.reading.qualityScore > best.reading.qualityScore
            ? current
            : best);
  }

  /// Generates heatmap tiles for the specified bounds.
  ///
  /// Aggregates points into tiles of the specified size for efficient
  /// rendering.
  Future<List<HeatmapTile>> generateTiles({
    required GeoBounds bounds,
    required double tileSizeMeters,
  }) async {
    final points = await getPointsInBounds(bounds);
    if (points.isEmpty) return [];

    // Calculate tile grid dimensions
    const metersPerDegree = 111139.0;
    final tileSizeDegrees = tileSizeMeters / metersPerDegree;

    final tiles = <String, List<int>>{};
    final tileBounds = <String, GeoBounds>{};
    final tileUpdates = <String, DateTime>{};

    for (final point in points) {
      // Calculate tile indices
      final tileX =
          ((point.position.longitude - bounds.west) / tileSizeDegrees).floor();
      final tileY =
          ((point.position.latitude - bounds.south) / tileSizeDegrees).floor();
      final tileId = '$tileX,$tileY';

      // Initialize tile if needed
      tiles.putIfAbsent(tileId, () => []);
      tiles[tileId]!.add(point.reading.qualityScore);

      // Track bounds and update time
      final tileBound = GeoBounds(
        west: bounds.west + (tileX * tileSizeDegrees),
        east: bounds.west + ((tileX + 1) * tileSizeDegrees),
        south: bounds.south + (tileY * tileSizeDegrees),
        north: bounds.south + ((tileY + 1) * tileSizeDegrees),
      );
      tileBounds[tileId] = tileBound;

      final existing = tileUpdates[tileId];
      if (existing == null || point.recordedAt.isAfter(existing)) {
        tileUpdates[tileId] = point.recordedAt;
      }
    }

    // Build tile objects
    return tiles.entries.map((entry) {
      return HeatmapTile.aggregate(
        bounds: tileBounds[entry.key]!,
        qualityScores: entry.value,
        lastUpdated: tileUpdates[entry.key]!,
      );
    }).toList();
  }

  /// Prunes old data based on retention policy.
  ///
  /// Returns the number of points deleted.
  Future<int> pruneOldData({
    int retentionDays = defaultRetentionDays,
    bool preserveManualPins = true,
  }) async {
    return _database.pruneOldPoints(
      retentionPeriod: Duration(days: retentionDays),
      preserveManualPins: preserveManualPins,
    );
  }

  /// Gets statistics about stored data.
  Future<HeatmapStats> getStats() async {
    final pointCount = await _database.getPointCount();
    final manualPins = await _database.getManualPins();
    final sizeBytes = await _database.estimateDatabaseSize();

    return HeatmapStats(
      totalPoints: pointCount,
      manualPinCount: manualPins.length,
      estimatedSizeBytes: sizeBytes,
    );
  }

  /// Exports all points as a list for backup.
  Future<List<SignalMapPoint>> exportAllPoints() async {
    final rows = await _database.getPointsInBounds(
      north: 90,
      south: -90,
      east: 180,
      west: -180,
    );
    return rows.map(_fromRow).toList();
  }

  /// Imports points from a backup.
  Future<int> importPoints(List<SignalMapPoint> points) async {
    var imported = 0;
    for (final point in points) {
      await _database.upsertPoint(_toRow(point));
      imported++;
    }
    return imported;
  }

  /// Closes the database connection.
  Future<void> close() async {
    await _database.close();
  }

  // Conversion helpers

  SignalMapPointRow _toRow(SignalMapPoint point) {
    return SignalMapPointRow(
      id: point.id,
      latitude: point.position.latitude,
      longitude: point.position.longitude,
      altitude: point.position.altitude,
      radiusMeters: point.radiusMeters,
      qualityScore: point.reading.qualityScore,
      signalType: point.reading.type.name,
      dbm: point.reading.dbm,
      networkName: point.reading.networkName,
      connectionType: point.reading.connectionType,
      recordedAt: point.recordedAt,
      isManualPin: point.isManualPin,
      label: point.label,
    );
  }

  SignalMapPoint _fromRow(SignalMapPointRow row) {
    final position = GeoPosition(
      latitude: row.latitude,
      longitude: row.longitude,
      altitude: row.altitude,
      accuracy: row.radiusMeters,
    );

    final reading = SignalReading(
      timestamp: row.recordedAt,
      type: SignalType.values.byName(row.signalType),
      qualityScore: row.qualityScore,
      dbm: row.dbm,
      networkName: row.networkName,
      connectionType: row.connectionType,
      location: position,
    );

    return SignalMapPoint(
      id: row.id,
      position: position,
      radiusMeters: row.radiusMeters,
      reading: reading,
      recordedAt: row.recordedAt,
      isManualPin: row.isManualPin,
      label: row.label,
    );
  }
}

/// Statistics about stored heatmap data.
class HeatmapStats {
  const HeatmapStats({
    required this.totalPoints,
    required this.manualPinCount,
    required this.estimatedSizeBytes,
  });

  /// Total number of recorded points.
  final int totalPoints;

  /// Number of manual pins.
  final int manualPinCount;

  /// Estimated database size in bytes.
  final int estimatedSizeBytes;

  /// Estimated size in megabytes.
  double get estimatedSizeMb => estimatedSizeBytes / (1024 * 1024);

  @override
  String toString() =>
      'HeatmapStats(points: $totalPoints, pins: $manualPinCount, '
      'size: ${estimatedSizeMb.toStringAsFixed(2)} MB)';
}
