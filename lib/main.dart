import 'package:flutter/material.dart';

import 'core/effects/crt_effect.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme.dart';
import 'core/theme/typography.dart';
import 'features/radar/radar_exports.dart';
import 'features/radar_display/radar_display_exports.dart';

void main() {
  runApp(const XenoSignalApp());
}

/// XenoSignal - WiFi and cellular signal tracker.
///
/// A cross-platform mobile app that tracks signal strength with
/// a retro-futuristic UI inspired by the M314 Motion Tracker from Aliens.
class XenoSignalApp extends StatelessWidget {
  const XenoSignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XenoSignal',
      debugShowCheckedModeBanner: false,
      theme: XenoTheme.green,
      darkTheme: XenoTheme.green, // Always dark
      themeMode: ThemeMode.dark,
      home: const RadarScreen(),
    );
  }
}

/// Demo screen to showcase the theme system.
///
/// This is a temporary screen for testing the theme implementation.
/// Will be replaced with the actual radar/signal tracking screens.
class ThemeDemoScreen extends StatefulWidget {
  const ThemeDemoScreen({super.key});

  @override
  State<ThemeDemoScreen> createState() => _ThemeDemoScreenState();
}

class _ThemeDemoScreenState extends State<ThemeDemoScreen> {
  bool _crtEnabled = true;
  double _signalStrength = 0.75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XENOSIGNAL'),
      ),
      body: CrtOverlay(
        enabled: _crtEnabled,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(XenoTheme.spacing2x),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radar demo
                _buildSection(
                  'RADAR DISPLAY',
                  const SizedBox(
                    height: 280,
                    child: Center(
                      child: RadarWidget(
                        size: 260,
                        sweepDuration: Duration(seconds: 3),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: XenoTheme.spacing3x),

                // Typography demo
                _buildSection(
                  'TYPOGRAPHY',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display Text', style: XenoTypography.display()),
                      Text('Title Text', style: XenoTypography.title()),
                      Text('Body Large', style: XenoTypography.bodyLarge()),
                      Text('Body Text', style: XenoTypography.body()),
                      Text('Caption Text', style: XenoTypography.caption()),
                      Text('OVERLINE TEXT', style: XenoTypography.overline()),
                    ],
                  ),
                ),

                const SizedBox(height: XenoTheme.spacing3x),

                // Colors demo
                _buildSection(
                  'COLOR PALETTE',
                  Wrap(
                    spacing: XenoTheme.spacing1x,
                    runSpacing: XenoTheme.spacing1x,
                    children: [
                      _colorSwatch('Primary', XenoColors.primaryGreen),
                      _colorSwatch('Classic', XenoColors.classicGreen),
                      _colorSwatch('Amber', XenoColors.amber),
                      _colorSwatch('Danger', XenoColors.danger),
                      _colorSwatch('Surface', XenoColors.surfaceMid),
                    ],
                  ),
                ),

                const SizedBox(height: XenoTheme.spacing3x),

                // Signal strength demo
                _buildSection(
                  'SIGNAL STRENGTH',
                  Column(
                    children: [
                      _signalDisplay(),
                      const SizedBox(height: XenoTheme.spacing2x),
                      Slider(
                        value: _signalStrength,
                        onChanged: (v) => setState(() => _signalStrength = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: XenoTheme.spacing3x),

                // Buttons demo
                _buildSection(
                  'CONTROLS',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('ELEVATED BUTTON'),
                      ),
                      const SizedBox(height: XenoTheme.spacing1x),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('OUTLINED BUTTON'),
                      ),
                      const SizedBox(height: XenoTheme.spacing1x),
                      TextButton(
                        onPressed: () {},
                        child: const Text('TEXT BUTTON'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: XenoTheme.spacing3x),

                // CRT toggle
                _buildSection(
                  'DISPLAY SETTINGS',
                  SwitchListTile(
                    title: Text(
                      'CRT EFFECTS',
                      style: XenoTypography.body(),
                    ),
                    subtitle: Text(
                      'Scanlines and vignette',
                      style: XenoTypography.caption(),
                    ),
                    value: _crtEnabled,
                    onChanged: (v) => setState(() => _crtEnabled = v),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: XenoTypography.overline()),
        const SizedBox(height: XenoTheme.spacing1x),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(XenoTheme.spacing2x),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _colorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(XenoTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: XenoTypography.caption()),
      ],
    );
  }

  Widget _signalDisplay() {
    final percentage = (_signalStrength * 100).toInt();
    final quality = _getSignalQuality(_signalStrength);

    return Container(
      padding: const EdgeInsets.all(XenoTheme.spacing2x),
      decoration: BoxDecoration(
        border: Border.all(
          color: XenoColors.primaryGreen.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(XenoTheme.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: XenoTypography.display().copyWith(
              shadows: [
                Shadow(
                  color: XenoColors.glowGreen,
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          Text(quality, style: XenoTypography.overline()),
        ],
      ),
    );
  }

  String _getSignalQuality(double strength) {
    if (strength > 0.8) return 'CRITICAL HIT';
    if (strength > 0.6) return 'FULLY LEVELED';
    if (strength > 0.4) return 'LOW HP';
    return 'GAME OVER';
  }
}
