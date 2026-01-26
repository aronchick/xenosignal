import 'dart:async';

import '../../signal_tracking/domain/signal_reading.dart';
import '../domain/heatmap_point.dart';

/// Service for managing heatmap history data.
///
/// Maintains an in-memory collection of signal readings with location data.
/// Provides streaming access to the history and handles pruning of old data.
class HeatmapHistoryService {
  /// Creates a heatmap history service.
  HeatmapHistoryService({
    this.maxPoints = 1000,
    this.retentionHours = 24,
    this.aggregationRadiusMeters = 10.0,
  });

  /// Maximum number of points to retain in memory.
  final int maxPoints;

  /// How long to retain historical data (hours).
  final int retentionHours;

  /// Minimum distance between points to avoid clustering (meters).
  final double aggregationRadiusMeters;

  /// Internal storage of heatmap points.
  final List<HeatmapPoint> _points = [];

  /// Stream controller for broadcasting changes.
  final _pointsController = StreamController<List<HeatmapPoint>>.broadcast();

  /// Stream of all current heatmap points.
  Stream<List<HeatmapPoint>> get pointsStream => _pointsController.stream;

  /// Current snapshot of all points.
  List<HeatmapPoint> get points => List.unmodifiable(_points);

  /// Number of stored points.
  int get count => _points.length;

  /// Records a new signal reading to the heatmap.
  ///
  /// Returns null if the reading has no location or was aggregated
  /// into an existing point.
  HeatmapPoint? recordReading(SignalReading reading, {String? label}) {
    if (reading.location == null) return null;

    // Check for nearby existing points to aggregate
    final nearby = _findNearbyPoint(reading.location!);
    if (nearby != null && !reading.qualityScore.isNaN) {
      // Update existing point if this reading is better
      if (reading.qualityScore > nearby.qualityScore) {
        _points.remove(nearby);
        final updated = HeatmapPoint(
          id: nearby.id,
          position: reading.location!,
          qualityScore: reading.qualityScore,
          recordedAt: DateTime.now(),
          isManualPin: nearby.isManualPin,
          label: label ?? nearby.label,
        );
        _points.add(updated);
        _notifyListeners();
        return updated;
      }
      return null; // Aggregated into existing point
    }

    // Create new point
    final point = HeatmapPoint(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      position: reading.location!,
      qualityScore: reading.qualityScore,
      recordedAt: DateTime.now(),
      label: label,
    );

    _addPoint(point);
    return point;
  }

  /// Manually pins the current location with a label.
  HeatmapPoint? pinLocation(SignalReading reading, {String? label}) {
    if (reading.location == null) return null;

    final point = HeatmapPoint(
      id: 'pin_${DateTime.now().microsecondsSinceEpoch}',
      position: reading.location!,
      qualityScore: reading.qualityScore,
      recordedAt: DateTime.now(),
      isManualPin: true,
      label: label,
    );

    _addPoint(point);
    return point;
  }

  /// Finds a nearby point within aggregation radius.
  HeatmapPoint? _findNearbyPoint(GeoPosition position) {
    for (final point in _points) {
      final distance = HeatmapPoint.distanceBetween(position, point.position);
      if (distance <= aggregationRadiusMeters) {
        return point;
      }
    }
    return null;
  }

  /// Adds a point, enforcing limits.
  void _addPoint(HeatmapPoint point) {
    _points.add(point);

    // Enforce max points limit (remove oldest non-pinned first)
    while (_points.length > maxPoints) {
      final oldest = _points
          .where((p) => !p.isManualPin)
          .reduce((a, b) => a.recordedAt.isBefore(b.recordedAt) ? a : b);
      _points.remove(oldest);
    }

    _notifyListeners();
  }

  /// Prunes points older than retention period.
  ///
  /// Manual pins are preserved regardless of age.
  int pruneOldPoints() {
    final cutoff = DateTime.now().subtract(Duration(hours: retentionHours));
    final before = _points.length;

    _points.removeWhere((point) =>
        !point.isManualPin && point.recordedAt.isBefore(cutoff));

    final removed = before - _points.length;
    if (removed > 0) {
      _notifyListeners();
    }
    return removed;
  }

  /// Gets points within a certain distance of the current position.
  List<HeatmapPoint> getPointsNearby(GeoPosition position, double radiusMeters) {
    return _points.where((point) {
      final distance = HeatmapPoint.distanceBetween(position, point.position);
      return distance <= radiusMeters;
    }).toList();
  }

  /// Gets points that are "fresh" (within aging window).
  List<HeatmapPoint> get freshPoints => _points.where((p) => p.isFresh).toList();

  /// Gets points that are "historical" (past aging window).
  List<HeatmapPoint> get historicalPoints =>
      _points.where((p) => p.isHistorical).toList();

  /// Removes a specific point.
  bool removePoint(String id) {
    final lengthBefore = _points.length;
    _points.removeWhere((p) => p.id == id);
    final removed = _points.length < lengthBefore;
    if (removed) {
      _notifyListeners();
    }
    return removed;
  }

  /// Clears all non-pinned points.
  void clearHistory() {
    _points.removeWhere((p) => !p.isManualPin);
    _notifyListeners();
  }

  /// Clears all points including manual pins.
  void clearAll() {
    _points.clear();
    _notifyListeners();
  }

  void _notifyListeners() {
    _pointsController.add(List.unmodifiable(_points));
  }

  /// Disposes the service.
  void dispose() {
    _pointsController.close();
  }
}
