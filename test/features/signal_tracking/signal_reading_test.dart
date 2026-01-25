import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/signal_tracking/domain/domain_exports.dart';

void main() {
  group('SignalType', () {
    test('displayName returns correct values', () {
      expect(SignalType.wifi.displayName, 'WIFI');
      expect(SignalType.cellular.displayName, 'CELLULAR');
    });

    test('hasDirectDbmOnAndroid is true for both types', () {
      expect(SignalType.wifi.hasDirectDbmOnAndroid, isTrue);
      expect(SignalType.cellular.hasDirectDbmOnAndroid, isTrue);
    });

    test('hasDirectDbmOnIOS is false for both types', () {
      expect(SignalType.wifi.hasDirectDbmOnIOS, isFalse);
      expect(SignalType.cellular.hasDirectDbmOnIOS, isFalse);
    });
  });

  group('GeoPosition', () {
    test('creates with required fields', () {
      const pos = GeoPosition(latitude: 37.7749, longitude: -122.4194);

      expect(pos.latitude, 37.7749);
      expect(pos.longitude, -122.4194);
      expect(pos.altitude, isNull);
      expect(pos.accuracy, isNull);
    });

    test('creates with all fields', () {
      const pos = GeoPosition(
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 10.5,
        accuracy: 5.0,
      );

      expect(pos.altitude, 10.5);
      expect(pos.accuracy, 5.0);
    });

    test('equality works correctly', () {
      const pos1 = GeoPosition(latitude: 37.7749, longitude: -122.4194);
      const pos2 = GeoPosition(latitude: 37.7749, longitude: -122.4194);
      const pos3 = GeoPosition(latitude: 37.7750, longitude: -122.4194);

      expect(pos1, equals(pos2));
      expect(pos1, isNot(equals(pos3)));
    });
  });

  group('SignalReading', () {
    test('creates with required fields', () {
      final reading = SignalReading(
        timestamp: DateTime(2024, 1, 1, 12, 0),
        type: SignalType.wifi,
        qualityScore: 75,
      );

      expect(reading.type, SignalType.wifi);
      expect(reading.qualityScore, 75);
      expect(reading.dbm, isNull);
      expect(reading.latencyMs, isNull);
    });

    test('creates with all fields', () {
      final reading = SignalReading(
        timestamp: DateTime(2024, 1, 1, 12, 0),
        type: SignalType.wifi,
        dbm: -55.0,
        latencyMs: 15.0,
        qualityScore: 85,
        networkName: 'TestNetwork',
        connectionType: '5 GHz',
        location: const GeoPosition(latitude: 37.7749, longitude: -122.4194),
      );

      expect(reading.dbm, -55.0);
      expect(reading.latencyMs, 15.0);
      expect(reading.networkName, 'TestNetwork');
      expect(reading.connectionType, '5 GHz');
      expect(reading.location, isNotNull);
    });

    test('throws assertion error for invalid quality score', () {
      expect(
        () => SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: -1,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 101,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('qualityLabel', () {
      test('returns CRITICAL HIT for score > 80', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 85,
        );
        expect(reading.qualityLabel, 'CRITICAL HIT');
      });

      test('returns FULLY LEVELED for score 61-80', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 70,
        );
        expect(reading.qualityLabel, 'FULLY LEVELED');
      });

      test('returns LOW HP for score 41-60', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 50,
        );
        expect(reading.qualityLabel, 'LOW HP');
      });

      test('returns GAME OVER for score <= 40', () {
        final reading = SignalReading(
          timestamp: DateTime.now(),
          type: SignalType.wifi,
          qualityScore: 30,
        );
        expect(reading.qualityLabel, 'GAME OVER');
      });
    });

    test('copyWith creates new instance with overrides', () {
      final original = SignalReading(
        timestamp: DateTime(2024, 1, 1),
        type: SignalType.wifi,
        qualityScore: 75,
        networkName: 'Original',
      );

      final copied = original.copyWith(
        qualityScore: 85,
        networkName: 'Copied',
      );

      expect(copied.qualityScore, 85);
      expect(copied.networkName, 'Copied');
      expect(copied.type, SignalType.wifi); // Unchanged
      expect(copied.timestamp, original.timestamp); // Unchanged
    });

    test('equality works correctly', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0);

      final reading1 = SignalReading(
        timestamp: timestamp,
        type: SignalType.wifi,
        qualityScore: 75,
      );

      final reading2 = SignalReading(
        timestamp: timestamp,
        type: SignalType.wifi,
        qualityScore: 75,
      );

      final reading3 = SignalReading(
        timestamp: timestamp,
        type: SignalType.wifi,
        qualityScore: 80,
      );

      expect(reading1, equals(reading2));
      expect(reading1, isNot(equals(reading3)));
    });
  });

  group('SignalNormalizer', () {
    group('normalizeWifiDbm', () {
      test('returns 80-100 for excellent signal (> -50 dBm)', () {
        expect(SignalNormalizer.normalizeWifiDbm(-30), inInclusiveRange(80, 100));
        expect(SignalNormalizer.normalizeWifiDbm(-40), inInclusiveRange(80, 100));
        expect(SignalNormalizer.normalizeWifiDbm(-50), inInclusiveRange(80, 100));
      });

      test('returns 60-80 for good signal (-50 to -60 dBm)', () {
        expect(SignalNormalizer.normalizeWifiDbm(-55), inInclusiveRange(60, 80));
        expect(SignalNormalizer.normalizeWifiDbm(-60), inInclusiveRange(60, 80));
      });

      test('returns 40-60 for fair signal (-60 to -70 dBm)', () {
        expect(SignalNormalizer.normalizeWifiDbm(-65), inInclusiveRange(40, 60));
        expect(SignalNormalizer.normalizeWifiDbm(-70), inInclusiveRange(40, 60));
      });

      test('returns 0-40 for poor signal (< -70 dBm)', () {
        expect(SignalNormalizer.normalizeWifiDbm(-75), inInclusiveRange(0, 40));
        expect(SignalNormalizer.normalizeWifiDbm(-90), inInclusiveRange(0, 40));
      });

      test('clamps to valid range', () {
        expect(SignalNormalizer.normalizeWifiDbm(-20), lessThanOrEqualTo(100));
        expect(SignalNormalizer.normalizeWifiDbm(-100), greaterThanOrEqualTo(0));
      });
    });

    group('normalizeCellularDbm', () {
      test('returns 80-100 for excellent signal (> -70 dBm)', () {
        expect(SignalNormalizer.normalizeCellularDbm(-50), inInclusiveRange(80, 100));
        expect(SignalNormalizer.normalizeCellularDbm(-60), inInclusiveRange(80, 100));
        expect(SignalNormalizer.normalizeCellularDbm(-70), inInclusiveRange(80, 100));
      });

      test('returns 60-80 for good signal (-70 to -85 dBm)', () {
        expect(SignalNormalizer.normalizeCellularDbm(-75), inInclusiveRange(60, 80));
        expect(SignalNormalizer.normalizeCellularDbm(-85), inInclusiveRange(60, 80));
      });

      test('returns 40-60 for fair signal (-85 to -100 dBm)', () {
        expect(SignalNormalizer.normalizeCellularDbm(-90), inInclusiveRange(40, 60));
        expect(SignalNormalizer.normalizeCellularDbm(-100), inInclusiveRange(40, 60));
      });

      test('returns 0-40 for poor signal (< -100 dBm)', () {
        expect(SignalNormalizer.normalizeCellularDbm(-105), inInclusiveRange(0, 40));
        expect(SignalNormalizer.normalizeCellularDbm(-120), inInclusiveRange(0, 40));
      });
    });

    group('normalizeLatency', () {
      test('returns 80-100 for excellent latency (< 20ms)', () {
        expect(SignalNormalizer.normalizeLatency(5), inInclusiveRange(80, 100));
        expect(SignalNormalizer.normalizeLatency(15), inInclusiveRange(80, 100));
        expect(SignalNormalizer.normalizeLatency(20), inInclusiveRange(80, 100));
      });

      test('returns 60-80 for good latency (20-50ms)', () {
        expect(SignalNormalizer.normalizeLatency(30), inInclusiveRange(60, 80));
        expect(SignalNormalizer.normalizeLatency(50), inInclusiveRange(60, 80));
      });

      test('returns 40-60 for fair latency (50-100ms)', () {
        expect(SignalNormalizer.normalizeLatency(75), inInclusiveRange(40, 60));
        expect(SignalNormalizer.normalizeLatency(100), inInclusiveRange(40, 60));
      });

      test('returns 0-40 for poor latency (> 100ms)', () {
        expect(SignalNormalizer.normalizeLatency(150), inInclusiveRange(0, 40));
        expect(SignalNormalizer.normalizeLatency(300), inInclusiveRange(0, 40));
      });

      test('handles very high latency gracefully', () {
        // Should cap at some reasonable value, not go negative
        expect(SignalNormalizer.normalizeLatency(1000), greaterThanOrEqualTo(0));
        expect(SignalNormalizer.normalizeLatency(5000), greaterThanOrEqualTo(0));
      });
    });

    group('normalizeDbm', () {
      test('dispatches to correct normalizer based on type', () {
        // WiFi at -55 dBm should be in good range (60-80)
        expect(
          SignalNormalizer.normalizeDbm(-55, SignalType.wifi),
          inInclusiveRange(60, 80),
        );

        // Cellular at -55 dBm should be in excellent range (80-100)
        expect(
          SignalNormalizer.normalizeDbm(-55, SignalType.cellular),
          inInclusiveRange(80, 100),
        );
      });
    });

    group('cross-platform consistency', () {
      test('same quality level produces similar scores for WiFi and cellular', () {
        // "Excellent" ranges should both produce 80-100
        final wifiExcellent = SignalNormalizer.normalizeWifiDbm(-45);
        final cellularExcellent = SignalNormalizer.normalizeCellularDbm(-60);

        expect(wifiExcellent, inInclusiveRange(80, 100));
        expect(cellularExcellent, inInclusiveRange(80, 100));

        // "Poor" ranges should both produce 0-40
        final wifiPoor = SignalNormalizer.normalizeWifiDbm(-85);
        final cellularPoor = SignalNormalizer.normalizeCellularDbm(-110);

        expect(wifiPoor, inInclusiveRange(0, 40));
        expect(cellularPoor, inInclusiveRange(0, 40));
      });

      test('latency-based score comparable to dBm-based score', () {
        // Excellent latency should match excellent dBm
        final latencyExcellent = SignalNormalizer.normalizeLatency(10);
        final dbmExcellent = SignalNormalizer.normalizeWifiDbm(-40);

        expect(latencyExcellent, inInclusiveRange(80, 100));
        expect(dbmExcellent, inInclusiveRange(80, 100));
      });
    });
  });
}
