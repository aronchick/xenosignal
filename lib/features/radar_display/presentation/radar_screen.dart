import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/effects/crt_effect.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../data/compass_service.dart';
import 'radar_painter.dart';

/// Main radar display screen.
///
/// Combines the RadarPainter with sweep animation and compass integration.
/// Shows compass heading, status indicators, and the animated radar sweep.
class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  /// Sweep animation controller - continuous 3-second rotation.
  late AnimationController _sweepController;

  /// Compass service for device heading.
  final CompassService _compass = CompassService();

  /// Current compass heading in degrees.
  double _heading = 0;

  /// Stream subscriptions.
  StreamSubscription<double>? _headingSubscription;
  StreamSubscription<CompassStatus>? _statusSubscription;

  /// CRT effect toggle.
  bool _crtEnabled = true;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initCompass();
  }

  void _initAnimation() {
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Full rotation in 3 seconds
    )..repeat(); // Continuous clockwise rotation
  }

  void _initCompass() {
    _headingSubscription = _compass.headingStream.listen((heading) {
      setState(() => _heading = heading);
    });

    _statusSubscription = _compass.statusStream.listen((status) {
      setState(() {}); // Rebuild to show status change
    });

    _compass.start();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _headingSubscription?.cancel();
    _statusSubscription?.cancel();
    _compass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XENOSIGNAL'),
        actions: [
          IconButton(
            icon: Icon(_crtEnabled ? Icons.blur_on : Icons.blur_off),
            onPressed: () => setState(() => _crtEnabled = !_crtEnabled),
            tooltip: 'Toggle CRT Effect',
          ),
        ],
      ),
      body: CrtOverlay(
        enabled: _crtEnabled,
        child: SafeArea(
          child: Column(
            children: [
              // Compass status bar
              _buildStatusBar(),

              // Radar display (main content)
              Expanded(
                child: _buildRadarDisplay(),
              ),

              // Heading readout
              _buildHeadingReadout(),

              const SizedBox(height: XenoTheme.spacing2x),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: XenoTheme.spacing2x,
        vertical: XenoTheme.spacing1x,
      ),
      child: Row(
        children: [
          _buildStatusIndicator(),
          const Spacer(),
          Text(
            'SWEEP: 3.0s',
            style: XenoTypography.caption(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final (label, color) = switch (_compass.status) {
      CompassStatus.active => ('COMPASS ACTIVE', XenoColors.primaryGreen),
      CompassStatus.offline => ('COMPASS OFFLINE', XenoColors.amber),
      CompassStatus.permissionDenied => ('PERMISSION DENIED', XenoColors.danger),
      CompassStatus.unavailable => ('NO COMPASS', XenoColors.danger),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: XenoTheme.spacing1x),
        Text(label, style: XenoTypography.caption()),
      ],
    );
  }

  Widget _buildRadarDisplay() {
    return Padding(
      padding: const EdgeInsets.all(XenoTheme.spacing2x),
      child: AspectRatio(
        aspectRatio: 1, // Square radar display
        child: AnimatedBuilder(
          animation: _sweepController,
          builder: (context, child) {
            // Convert animation value (0-1) to radians (0 to 2*pi)
            final sweepAngle = _sweepController.value * 2 * math.pi;

            // Convert heading to radians (opposite direction for inverse rotation)
            final compassRadians = _heading * (math.pi / 180);

            return CustomPaint(
              painter: RadarPainter(
                sweepAngle: sweepAngle,
                compassHeading: compassRadians,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeadingReadout() {
    final headingInt = _heading.round() % 360;
    final cardinal = _getCardinalDirection(_heading);

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
            '${headingInt.toString().padLeft(3, '0')}°',
            style: XenoTypography.display().copyWith(
              fontSize: 48,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: XenoColors.glowGreen,
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          Text(
            cardinal,
            style: XenoTypography.overline(),
          ),
          if (!_compass.isActive)
            Padding(
              padding: const EdgeInsets.only(top: XenoTheme.spacing1x),
              child: Text(
                'SIMULATED DATA',
                style: XenoTypography.caption().copyWith(
                  color: XenoColors.amber,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}
