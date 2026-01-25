import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/audio_haptics/data/geiger_audio_service.dart';

void main() {
  group('GeigerAudioService', () {
    late GeigerAudioService service;

    setUp(() {
      service = GeigerAudioService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('creates with default state', () {
      expect(service.isEnabled, isFalse);
      expect(service.volume, 0.7);
    });

    test('isEnabled is false before start', () {
      expect(service.isEnabled, isFalse);
    });

    test('start without initialize does not enable (player is null)', () {
      // When initialize() hasn't been called, _player is null
      // and start() should return early without enabling
      service.start(50);
      expect(service.isEnabled, isFalse);
    });

    test('updateSignalQuality does nothing when not enabled', () {
      // Should not throw
      service.updateSignalQuality(50);
      expect(service.isEnabled, isFalse);
    });

    test('stop sets isEnabled to false', () {
      // Even if start failed (no player), stop should work
      service.stop();
      expect(service.isEnabled, isFalse);
    });

    test('dispose can be called multiple times', () async {
      await service.dispose();
      await service.dispose(); // Should not throw
      expect(service.isEnabled, isFalse);
    });

    test('volume can be set', () async {
      await service.setVolume(0.5);
      expect(service.volume, 0.5);
    });

    test('volume is clamped to valid range', () async {
      await service.setVolume(-0.5);
      expect(service.volume, 0.0);

      await service.setVolume(1.5);
      expect(service.volume, 1.0);
    });
  });
}
