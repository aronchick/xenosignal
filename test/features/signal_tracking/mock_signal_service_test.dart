import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/signal_tracking/signal_tracking_exports.dart';

void main() {
  group('MockSignalService', () {
    late MockSignalService service;

    setUp(() {
      // Use seeded random for reproducible tests
      service = MockSignalService(random: Random(42));
    });

    tearDown(() {
      service.dispose();
    });

    group('getWifiSignal', () {
      test('returns a valid WiFi signal reading', () async {
        final reading = await service.getWifiSignal();

        expect(reading, isNotNull);
        expect(reading!.type, equals(SignalType.wifi));
        expect(reading.dbm, isNotNull);
        expect(reading.qualityScore, inInclusiveRange(0, 100));
        expect(reading.networkName, equals('XenoNet-5G'));
        expect(reading.connectionType, equals('5 GHz'));
        expect(reading.location, isNotNull);
      });

      test('generates varying signal over time', () async {
        final readings = <SignalReading>[];

        for (var i = 0; i < 5; i++) {
          final reading = await service.getWifiSignal();
          readings.add(reading!);
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }

        // Extract dBm values
        final dbmValues = readings.map((r) => r.dbm!).toList();

        // With noise, values should not all be identical
        final uniqueValues = dbmValues.toSet();
        expect(uniqueValues.length, greaterThan(1));
      });
    });

    group('getCellularSignal', () {
      test('returns a valid cellular signal reading', () async {
        final reading = await service.getCellularSignal();

        expect(reading, isNotNull);
        expect(reading!.type, equals(SignalType.cellular));
        expect(reading.dbm, isNotNull);
        expect(reading.qualityScore, inInclusiveRange(0, 100));
        expect(reading.networkName, equals('Weyland-Yutani'));
        expect(reading.connectionType, equals('5G'));
      });
    });

    group('getAllSignals', () {
      test('returns both WiFi and cellular readings', () async {
        final signals = await service.getAllSignals();

        expect(signals.wifi, isNotNull);
        expect(signals.cellular, isNotNull);
        expect(signals.wifi!.type, equals(SignalType.wifi));
        expect(signals.cellular!.type, equals(SignalType.cellular));
      });
    });

    group('watchSignals', () {
      test('emits signal readings at specified interval', () async {
        final readings = <SignalReading>[];
        final subscription = service
            .watchSignals(interval: const Duration(milliseconds: 100))
            .listen(readings.add);

        // Wait for a few readings
        await Future<void>.delayed(const Duration(milliseconds: 350));
        await subscription.cancel();

        // Should have received multiple readings (both WiFi and cellular)
        expect(readings.length, greaterThanOrEqualTo(4));
      });

      test('filters by signal type when specified', () async {
        final readings = <SignalReading>[];
        final subscription = service
            .watchSignals(
              interval: const Duration(milliseconds: 100),
              types: {SignalType.wifi},
            )
            .listen(readings.add);

        await Future<void>.delayed(const Duration(milliseconds: 250));
        await subscription.cancel();

        // All readings should be WiFi only
        expect(readings, isNotEmpty);
        expect(readings.every((r) => r.type == SignalType.wifi), isTrue);
      });
    });

    group('measureLatency', () {
      test('returns a valid latency value', () async {
        final latency = await service.measureLatency();

        expect(latency, isNotNull);
        expect(latency, greaterThan(0));
        expect(latency, lessThan(300));
      });
    });

    group('connectivity checks', () {
      test('isWifiEnabled returns true', () async {
        expect(await service.isWifiEnabled(), isTrue);
      });

      test('isCellularEnabled returns true', () async {
        expect(await service.isCellularEnabled(), isTrue);
      });

      test('getConnectionType returns mock identifier', () async {
        expect(await service.getConnectionType(), equals('WiFi (Mock)'));
      });
    });

    group('signal quality scores', () {
      test('quality score matches dBm normalization', () async {
        final reading = await service.getWifiSignal();

        final expectedScore = SignalNormalizer.normalizeWifiDbm(reading!.dbm!);
        expect(reading.qualityScore, equals(expectedScore));
      });
    });

    group('geographic position', () {
      test('generates positions near San Francisco', () async {
        final reading = await service.getWifiSignal();
        final location = reading!.location!;

        // Should be near SF (37.7749, -122.4194)
        expect(location.latitude, closeTo(37.7749, 0.01));
        expect(location.longitude, closeTo(-122.4194, 0.01));
        expect(location.accuracy, isNotNull);
      });
    });

    group('dispose', () {
      test('stops signal stream after dispose', () async {
        final subscription = service
            .watchSignals(interval: const Duration(milliseconds: 50))
            .listen((_) {});

        // Should not throw
        service.dispose();

        // Wait a bit then cancel - stream should be closed
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await subscription.cancel();
      });
    });
  });
}
