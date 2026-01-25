import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/audio_haptics/domain/audio_haptic_settings.dart';

void main() {
  group('AudioHapticSettings', () {
    test('creates with default values', () {
      const settings = AudioHapticSettings();

      expect(settings.audioEnabled, isTrue);
      expect(settings.hapticEnabled, isTrue);
      expect(settings.volume, 0.7);
    });

    test('creates with custom values', () {
      const settings = AudioHapticSettings(
        audioEnabled: false,
        hapticEnabled: false,
        volume: 0.5,
      );

      expect(settings.audioEnabled, isFalse);
      expect(settings.hapticEnabled, isFalse);
      expect(settings.volume, 0.5);
    });

    test('copyWith creates new instance with overrides', () {
      const original = AudioHapticSettings();
      final modified = original.copyWith(audioEnabled: false);

      expect(modified.audioEnabled, isFalse);
      expect(modified.hapticEnabled, isTrue); // unchanged
      expect(modified.volume, 0.7); // unchanged
    });

    test('copyWith preserves original when no overrides', () {
      const original = AudioHapticSettings(
        audioEnabled: false,
        hapticEnabled: false,
        volume: 0.3,
      );
      final copy = original.copyWith();

      expect(copy.audioEnabled, isFalse);
      expect(copy.hapticEnabled, isFalse);
      expect(copy.volume, 0.3);
    });

    test('equality works correctly', () {
      const settings1 = AudioHapticSettings();
      const settings2 = AudioHapticSettings();
      const settings3 = AudioHapticSettings(volume: 0.5);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('hashCode is consistent with equality', () {
      const settings1 = AudioHapticSettings();
      const settings2 = AudioHapticSettings();

      expect(settings1.hashCode, equals(settings2.hashCode));
    });
  });
}
