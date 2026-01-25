import 'package:flutter_test/flutter_test.dart';
import 'package:xenosignal/features/audio_haptics/domain/feedback_settings.dart';
import 'package:xenosignal/features/audio_haptics/domain/sound_theme.dart';

void main() {
  group('FeedbackSettings', () {
    test('has sensible defaults', () {
      const settings = FeedbackSettings();

      expect(settings.audioEnabled, isTrue);
      expect(settings.hapticEnabled, isTrue);
      expect(settings.masterVolume, equals(0.7));
      expect(settings.soundTheme, equals(SoundTheme.classicM314));
      expect(settings.silentMode, isFalse);
    });

    group('isAudioActive', () {
      test('returns true when audio enabled and not silent', () {
        const settings = FeedbackSettings(audioEnabled: true, silentMode: false);
        expect(settings.isAudioActive, isTrue);
      });

      test('returns false when audio disabled', () {
        const settings = FeedbackSettings(audioEnabled: false, silentMode: false);
        expect(settings.isAudioActive, isFalse);
      });

      test('returns false when in silent mode', () {
        const settings = FeedbackSettings(audioEnabled: true, silentMode: true);
        expect(settings.isAudioActive, isFalse);
      });
    });

    group('isHapticActive', () {
      test('returns true when haptic enabled', () {
        const settings = FeedbackSettings(hapticEnabled: true, silentMode: false);
        expect(settings.isHapticActive, isTrue);
      });

      test('returns true when in silent mode even if haptic disabled', () {
        const settings = FeedbackSettings(hapticEnabled: false, silentMode: true);
        expect(settings.isHapticActive, isTrue);
      });

      test('returns false when haptic disabled and not silent', () {
        const settings = FeedbackSettings(hapticEnabled: false, silentMode: false);
        expect(settings.isHapticActive, isFalse);
      });
    });

    group('effective volumes', () {
      test('calculates effective click volume', () {
        const settings = FeedbackSettings(masterVolume: 0.5, clickVolume: 0.8);
        expect(settings.effectiveClickVolume, equals(0.4));
      });

      test('calculates effective ping volume', () {
        const settings = FeedbackSettings(masterVolume: 0.5, pingVolume: 0.6);
        expect(settings.effectivePingVolume, equals(0.3));
      });

      test('calculates effective alert volume', () {
        const settings = FeedbackSettings(masterVolume: 1.0, alertVolume: 1.0);
        expect(settings.effectiveAlertVolume, equals(1.0));
      });
    });

    group('copyWith', () {
      test('creates copy with updated values', () {
        const original = FeedbackSettings();
        final copy = original.copyWith(
          masterVolume: 0.5,
          soundTheme: SoundTheme.minimal,
        );

        expect(copy.masterVolume, equals(0.5));
        expect(copy.soundTheme, equals(SoundTheme.minimal));
        // Unchanged values preserved
        expect(copy.audioEnabled, equals(original.audioEnabled));
        expect(copy.hapticEnabled, equals(original.hapticEnabled));
      });

      test('preserves all values when no arguments passed', () {
        const original = FeedbackSettings(
          masterVolume: 0.3,
          silentMode: true,
        );
        final copy = original.copyWith();

        expect(copy.masterVolume, equals(original.masterVolume));
        expect(copy.silentMode, equals(original.silentMode));
      });
    });
  });

  group('SoundTheme', () {
    test('all themes have display names', () {
      for (final theme in SoundTheme.values) {
        expect(theme.displayName, isNotEmpty);
      }
    });

    test('all themes have click assets', () {
      for (final theme in SoundTheme.values) {
        expect(theme.clickAsset, endsWith('.wav'));
      }
    });

    test('clickAssetPath includes directory', () {
      expect(
        SoundTheme.classicM314.clickAssetPath,
        equals('assets/audio/click_classic.wav'),
      );
    });
  });
}
