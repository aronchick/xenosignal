import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/heatmap_history/data/heatmap_history_service.dart';
import 'package:xenosignal/features/signal_tracking/domain/signal_reading.dart';
import 'package:xenosignal/features/signal_tracking/domain/signal_type.dart';

void main() {
  group('HeatmapHistoryService', () {
    late HeatmapHistoryService service;

    setUp(() {
      service = HeatmapHistoryService(
        maxPoints: 100,
        retentionHours: 24,
        aggregationRadiusMeters: 10.0,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('recordReading', () {
      test('records reading with location', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        );

        final point = service.recordReading(reading);

        expect(point, isNotNull);
        expect(service.count, equals(1));
        expect(service.points.first.qualityScore, equals(80));
      });

      test('returns null for reading without location', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          // No location
        );

        final point = service.recordReading(reading);

        expect(point, isNull);
        expect(service.count, equals(0));
      });

      test('aggregates nearby points', () {
        final reading1 = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        );

        final reading2 = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 70,
          location: const GeoPosition(
              latitude: 37.00001, longitude: -122.00001), // Very close
        );

        service.recordReading(reading1);
        service.recordReading(reading2);

        // Should aggregate into single point
        expect(service.count, equals(1));
        // Original quality should be kept since it's higher
        expect(service.points.first.qualityScore, equals(80));
      });

      test('updates aggregated point if new quality is better', () {
        final reading1 = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 70,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        );

        final reading2 = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 90,
          location: const GeoPosition(
              latitude: 37.00001, longitude: -122.00001), // Very close
        );

        service.recordReading(reading1);
        service.recordReading(reading2);

        // Should update to better quality
        expect(service.count, equals(1));
        expect(service.points.first.qualityScore, equals(90));
      });
    });

    group('pinLocation', () {
      test('creates manual pin', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 85,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        );

        final point = service.pinLocation(reading, label: 'Good spot');

        expect(point, isNotNull);
        expect(point!.isManualPin, isTrue);
        expect(point.label, equals('Good spot'));
      });
    });

    group('point categories', () {
      test('freshPoints returns only recent points', () {
        // Add a fresh point
        service.recordReading(SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        ));

        expect(service.freshPoints.length, equals(1));
        expect(service.historicalPoints.length, equals(0));
      });
    });

    group('clearHistory', () {
      test('clears non-pinned points', () {
        // Add regular point
        service.recordReading(SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        ));

        // Add pinned point
        service.pinLocation(
          SignalReading(
            timestamp: DateTime.now(),
            type: SignalType.wifi,
            qualityScore: 90,
            location: const GeoPosition(latitude: 37.1, longitude: -122.1),
          ),
          label: 'Keep this',
        );

        expect(service.count, equals(2));

        service.clearHistory();

        // Only pinned point should remain
        expect(service.count, equals(1));
        expect(service.points.first.isManualPin, isTrue);
      });
    });

    group('clearAll', () {
      test('clears all points including pins', () {
        service.recordReading(SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        ));

        service.pinLocation(
          SignalReading(
            timestamp: DateTime.now(),
            type: SignalType.wifi,
            qualityScore: 90,
            location: const GeoPosition(latitude: 37.1, longitude: -122.1),
          ),
        );

        service.clearAll();

        expect(service.count, equals(0));
      });
    });

    group('removePoint', () {
      test('removes specific point', () {
        final point = service.recordReading(SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        ));

        final removed = service.removePoint(point!.id);

        expect(removed, isTrue);
        expect(service.count, equals(0));
      });

      test('returns false for non-existent point', () {
        final removed = service.removePoint('non-existent');

        expect(removed, isFalse);
      });
    });

    group('maxPoints limit', () {
      test('enforces max points limit', () {
        final limitedService = HeatmapHistoryService(maxPoints: 5);

        // Add more points than the limit
        for (int i = 0; i < 10; i++) {
          limitedService.recordReading(SignalReading(
            timestamp: DateTime.now(),
            type: SignalType.wifi,
            qualityScore: 80,
            location: GeoPosition(
              latitude: 37.0 + i * 0.01, // Different locations
              longitude: -122.0,
            ),
          ));
        }

        expect(limitedService.count, equals(5));
        limitedService.dispose();
      });
    });

    group('getPointsNearby', () {
      test('returns points within radius', () {
        // Add a point
        service.recordReading(SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 37.0, longitude: -122.0),
        ));

        // Add a far point
        service.recordReading(SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 80,
          location: const GeoPosition(latitude: 38.0, longitude: -122.0),
        ));

        final nearby = service.getPointsNearby(
          const GeoPosition(latitude: 37.0001, longitude: -122.0001),
          1000, // 1km radius
        );

        expect(nearby.length, equals(1));
      });
    });
  });
}
