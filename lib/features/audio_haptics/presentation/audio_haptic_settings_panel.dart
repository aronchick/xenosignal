import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../data/audio_haptic_controller.dart';

/// Settings panel for audio and haptic feedback.
///
/// Provides toggles for enabling/disabling Geiger counter audio
/// and haptic pulses, plus volume control.
class AudioHapticSettingsPanel extends StatelessWidget {
  const AudioHapticSettingsPanel({
    required this.controller,
    super.key,
  });

  final AudioHapticController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AUDIO / HAPTICS', style: XenoTypography.overline()),
        const SizedBox(height: XenoTheme.spacing1x),
        Card(
          child: Column(
            children: [
              _buildAudioToggle(),
              const Divider(height: 1),
              _buildHapticToggle(),
              const Divider(height: 1),
              _buildVolumeSlider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioToggle() {
    return _SettingTile(
      title: 'GEIGER AUDIO',
      subtitle: 'Click sounds based on signal',
      value: controller.settings.audioEnabled,
      onChanged: (value) => controller.setAudioEnabled(value),
    );
  }

  Widget _buildHapticToggle() {
    return _SettingTile(
      title: 'HAPTIC FEEDBACK',
      subtitle: controller.isHapticSupported
          ? 'Vibration pulses matching clicks'
          : 'Not supported on this device',
      value: controller.settings.hapticEnabled,
      enabled: controller.isHapticSupported,
      onChanged: (value) => controller.setHapticEnabled(value),
    );
  }

  Widget _buildVolumeSlider() {
    return Padding(
      padding: const EdgeInsets.all(XenoTheme.spacing2x),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up,
                size: 20,
                color: XenoColors.primaryGreen,
              ),
              const SizedBox(width: XenoTheme.spacing1x),
              Text('VOLUME', style: XenoTypography.body()),
              const Spacer(),
              Text(
                '${(controller.settings.volume * 100).round()}%',
                style: XenoTypography.caption(),
              ),
            ],
          ),
          const SizedBox(height: XenoTheme.spacing1x),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: XenoColors.primaryGreen,
              inactiveTrackColor: XenoColors.primaryGreen.withValues(alpha: 0.2),
              thumbColor: XenoColors.primaryGreen,
              overlayColor: XenoColors.primaryGreen.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: controller.settings.volume,
              onChanged: controller.settings.audioEnabled
                  ? (value) => controller.setVolume(value)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: XenoTypography.body().copyWith(
          color: enabled ? null : XenoColors.textDisabled,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: XenoTypography.caption().copyWith(
          color: enabled ? null : XenoColors.textDisabled,
        ),
      ),
      value: value && enabled,
      onChanged: enabled ? onChanged : null,
      activeTrackColor: XenoColors.primaryGreen.withValues(alpha: 0.5),
      activeThumbColor: XenoColors.primaryGreen,
    );
  }
}
