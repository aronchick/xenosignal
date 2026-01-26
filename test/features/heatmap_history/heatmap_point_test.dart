import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/heatmap_history/domain/heatmap_point.dart';
import 'package:xenosignal/features/signal_tracking/domain/signal_reading.dart';
import 'package:xenosignal/features/signal_tracking/domain/signal_type.dart';

void main() {
  group('HeatmapPoint', () {
    group('temporal aging', () {
      test('fresh point has full alpha', () {
        final point = HeatmapPoint(
          id: 'test',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now(),
        );

        expect(point.temporalAlpha, closeTo(1.0, 0.01));
        expect(point.isFresh, isTrue);
        expect(point.isHistorical, isFalse);
      });

      test('30-minute old point has reduced alpha', () {
        final point = HeatmapPoint(
          id: 'test',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // At 30 min (half of 60 min window), alpha should be ~0.65 (midway between 1.0 and 0.3)
        expect(point.temporalAlpha, closeTo(0.65, 0.05));
        expect(point.isFresh, isTrue);
        expect(point.isHistorical, isFalse);
      });

      test('55-minute old point has low alpha but still fresh', () {
        final point = HeatmapPoint(
          id: 'test',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 55)),
        );

        // Near end of aging window
        expect(point.temporalAlpha, lessThan(0.4));
        expect(point.temporalAlpha, greaterThan(0.3));
        expect(point.isFresh, isTrue);
      });

      test('historical point (>60 min) has ghost alpha', () {
        final point = HeatmapPoint(
          id: 'test',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 90)),
        );

        expect(point.temporalAlpha, equals(0.2)); // Historical ghost alpha
        expect(point.isFresh, isFalse);
        expect(point.isHistorical, isTrue);
      });

      test('manual pin has slower fade rate', () {
        final regularPoint = HeatmapPoint(
          id: 'regular',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        final pinnedPoint = HeatmapPoint(
          id: 'pinned',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          isManualPin: true,
        );

        // Manual pin fades to 0.5 instead of 0.3, so higher alpha
        expect(pinnedPoint.temporalAlpha, greaterThan(regularPoint.temporalAlpha));
      });

      test('historical manual pin has higher ghost alpha', () {
        final regularHistorical = HeatmapPoint(
          id: 'regular',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        final pinnedHistorical = HeatmapPoint(
          id: 'pinned',
          position: const GeoPosition(latitude: 37.0, longitude: -122.0),
          qualityScore: 80,
          recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
          isManualPin: true,
        );

        expect(regularHistorical.temporalAlpha, equals(0.2));
        expect(pinnedHistorical.temporalAlpha, equals(0.4));
      });
    });

    group('distance calculations', () {
      test('distanceBetween returns correct distance', () {
        // San Francisco to Oakland - roughly 13km
        const sf = GeoPosition(latitude: 37.7749, longitude: -122.4194);
        const oakland = GeoPosition(latitude: 37.8044, longitude: -122.2712);

        final distance = HeatmapPoint.distanceBetween(sf, oakland);

        // Should be approximately 13km (13000m)
        expect(distance, closeTo(13000, 1000));
      });

      test('distanceBetween returns 0 for same point', () {
        const point = GeoPosition(latitude: 37.7749, longitude: -122.4194);

        final distance = HeatmapPoint.distanceBetween(point, point);

        expect(distance, equals(0));
      });
    });

    group('bearing calculations', () {
      test('bearingBetween returns correct bearing for north', () {
        const from = GeoPosition(latitude: 37.0, longitude: -122.0);
        const to = GeoPosition(latitude: 38.0, longitude: -122.0);

        final bearing = HeatmapPoint.bearingBetween(from, to);

        // Should be approximately 0 (north)
        expect(bearing.abs(), lessThan(0.1));
      });

      test('bearingBetween returns correct bearing for east', () {
        const from = GeoPosition(latitude: 37.0, longitude: -122.0);
        const to = GeoPosition(latitude: 37.0, longitude: -121.0);

        final bearing = HeatmapPoint.bearingBetween(from, to);

        // Should be approximately π/2 (east)
        expect(bearing, closeTo(1.5708, 0.1));
      });
    });

    group('factory constructor', () {
      test('fromReading creates point from SignalReading', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 85,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        );

        final point = HeatmapPoint.fromReading(reading, label: 'Test spot');

        expect(point.position, equals(reading.location));
        expect(point.qualityScore, equals(85));
        expect(point.label, equals('Test spot'));
      });

      test('fromReading throws if no location', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 85,
          // No location
        );

        expect(
          () => HeatmapPoint.fromReading(reading),
          throwsArgumentError,
        );
      });
    });
  });
}
