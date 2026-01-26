import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/heatmap_history/domain/domain_exports.dart';
import 'package:xenosignal/features/signal_tracking/domain/domain_exports.dart';

void main() {
  group('GeoBounds', () {
    test('creates from center and radius', () {
      final center = const GeoPosition(latitude: 37.7749, longitude: -122.4194);
      final bounds = GeoBounds.fromCenterAndRadius(center, 1000); // 1km

      // Should create bounds roughly 1km in each direction
      expect(bounds.center.latitude, closeTo(37.7749, 0.001));
      expect(bounds.center.longitude, closeTo(-122.4194, 0.001));
      expect(bounds.north, greaterThan(center.latitude));
      expect(bounds.south, lessThan(center.latitude));
    });

    test('contains returns true for point inside', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      expect(
        bounds.contains(const GeoPosition(latitude: 37.5, longitude: -122.5)),
        isTrue,
      );
    });

    test('contains returns false for point outside', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      expect(
        bounds.contains(const GeoPosition(latitude: 39.0, longitude: -122.5)),
        isFalse,
      );
    });

    test('intersects detects overlapping bounds', () {
      final a = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final b = const GeoBounds(
        north: 37.5,
        south: 36.5,
        east: -122.5,
        west: -123.5,
      );

      expect(a.intersects(b), isTrue);
    });

    test('intersects returns false for non-overlapping bounds', () {
      final a = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final b = const GeoBounds(
        north: 36.0,
        south: 35.0,
        east: -122.0,
        west: -123.0,
      );

      expect(a.intersects(b), isFalse);
    });
  });

  group('HeatmapTile', () {
    test('aggregate calculates correct statistics', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final tile = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [80, 60, 70, 90],
        lastUpdated: DateTime.now(),
      );

      expect(tile.avgSignalQuality, closeTo(75.0, 0.1));
      expect(tile.peakSignalQuality, equals(90.0));
      expect(tile.sampleCount, equals(4));
    });

    test('aggregate handles empty list', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final tile = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [],
        lastUpdated: DateTime.now(),
      );

      expect(tile.avgSignalQuality, equals(0));
      expect(tile.sampleCount, equals(0));
    });

    test('intensity is normalized 0-1', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final tile = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [50],
        lastUpdated: DateTime.now(),
      );

      expect(tile.intensity, equals(0.5));
    });

    test('isFresh returns true for recent data', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final tile = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [50],
        lastUpdated: DateTime.now(),
      );

      expect(tile.isFresh, isTrue);
    });

    test('isFresh returns false for old data', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final tile = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [50],
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      );

      expect(tile.isFresh, isFalse);
    });

    test('merge combines tiles correctly', () {
      final bounds = const GeoBounds(
        north: 38.0,
        south: 37.0,
        east: -122.0,
        west: -123.0,
      );

      final tile1 = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [80, 80], // avg 80, 2 samples
        lastUpdated: DateTime(2024, 1, 1),
      );

      final tile2 = HeatmapTile.aggregate(
        bounds: bounds,
        qualityScores: [60, 60], // avg 60, 2 samples
        lastUpdated: DateTime(2024, 1, 2),
      );

      final merged = tile1.merge(tile2);

      // Weighted average: (80*2 + 60*2) / 4 = 70
      expect(merged.avgSignalQuality, closeTo(70.0, 0.1));
      expect(merged.sampleCount, equals(4));
      expect(merged.peakSignalQuality, equals(80.0));
      expect(merged.lastUpdated, equals(DateTime(2024, 1, 2)));
    });
  });

  group('SignalMapPoint', () {
    test('isLowConfidence returns true for accuracy > 50m', () {
      final point = SignalMapPoint(
        id: 'test-1',
        position: const GeoPosition(latitude: 37.0, longitude: -122.0),
        radiusMeters: 75.0, // > 50m
        reading: SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
        ),
        recordedAt: DateTime.now(),
      );

      expect(point.isLowConfidence, isTrue);
    });

    test('isLowConfidence returns false for accuracy <= 50m', () {
      final point = SignalMapPoint(
        id: 'test-1',
        position: const GeoPosition(latitude: 37.0, longitude: -122.0),
        radiusMeters: 25.0, // <= 50m
        reading: SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
        ),
        recordedAt: DateTime.now(),
      );

      expect(point.isLowConfidence, isFalse);
    });

    test('copyWith creates modified copy', () {
      final original = SignalMapPoint(
        id: 'test-1',
        position: const GeoPosition(latitude: 37.0, longitude: -122.0),
        radiusMeters: 10.0,
        reading: SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
        ),
        recordedAt: DateTime.now(),
        isManualPin: false,
      );

      final modified = original.copyWith(
        isManualPin: true,
        label: 'Test pin',
      );

      expect(modified.isManualPin, isTrue);
      expect(modified.label, equals('Test pin'));
      expect(modified.id, equals(original.id)); // unchanged
    });
  });
}
