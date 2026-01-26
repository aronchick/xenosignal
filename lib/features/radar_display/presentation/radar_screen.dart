import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/effects/crt_effect.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../heatmap_history/data/heatmap_history_service.dart';
import '../../heatmap_history/domain/heatmap_point.dart';
import '../../signal_tracking/domain/signal_reading.dart';
import '../../signal_tracking/domain/signal_type.dart';
import '../data/compass_service.dart';
import 'radar_painter.dart';

/// Main radar display screen with heatmap history.
///
/// Combines the RadarPainter with sweep animation, compass integration,
/// and heatmap history showing temporal aging of signal readings.
///
/// Heatmap blips fade over time:
/// - Fresh (0-60 min): Full brightness → fading
/// - Historical (>60 min): Dim "ghost" indicating past good signal
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

  /// Heatmap history service for tracking signal locations.
  final HeatmapHistoryService _heatmapHistory = HeatmapHistoryService();

  /// Current compass heading in degrees.
  double _heading = 0;

  /// Simulated current position (for demo - will be replaced with real GPS).
  final GeoPosition _currentPosition = const GeoPosition(
    latitude: 37.7749,
    longitude: -122.4194,
    accuracy: 10.0,
  );

  /// Stream subscriptions.
  StreamSubscription<double>? _headingSubscription;
  StreamSubscription<CompassStatus>? _statusSubscription;
  Timer? _heatmapSimulationTimer;
  Timer? _heatmapRefreshTimer;

  /// CRT effect toggle.
  bool _crtEnabled = true;

  /// Heatmap demo mode toggle.
  bool _demoMode = true;

  /// Random for demo data generation.
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initCompass();
    _initHeatmapDemo();
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

  /// Initialize heatmap demo with simulated data.
  void _initHeatmapDemo() {
    // Generate some historical data points (older than 1 hour)
    _generateHistoricalDemoData();

    // Generate some recent data points
    _generateRecentDemoData();

    // Start periodic simulation of new readings
    _heatmapSimulationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _simulateNewReading(),
    );

    // Refresh display periodically to update temporal alpha
    _heatmapRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => setState(() {}),
    );
  }

  /// Generate historical demo data (>1 hour old).
  void _generateHistoricalDemoData() {
    final now = DateTime.now();

    // Historical good spots (2-4 hours old)
    final historicalSpots = [
      (lat: 37.7751, lon: -122.4190, quality: 85, hoursAgo: 2.5),
      (lat: 37.7746, lon: -122.4198, quality: 92, hoursAgo: 3.0),
      (lat: 37.7753, lon: -122.4188, quality: 78, hoursAgo: 4.0),
      (lat: 37.7744, lon: -122.4192, quality: 65, hoursAgo: 2.0),
    ];

    for (final spot in historicalSpots) {
      final point = HeatmapPoint(
        id: 'hist_${spot.lat}_${spot.lon}',
        position: GeoPosition(latitude: spot.lat, longitude: spot.lon),
        qualityScore: spot.quality,
        recordedAt: now.subtract(Duration(
          minutes: (spot.hoursAgo * 60).round(),
        )),
      );
      _heatmapHistory.recordReading(
        SignalReading(
          timestamp: point.recordedAt,
          type: SignalType.wifi,
          qualityScore: point.qualityScore,
          location: point.position,
        ),
      );
    }
  }

  /// Generate recent demo data (within the last hour).
  void _generateRecentDemoData() {
    final now = DateTime.now();

    // Recent readings at various ages
    final recentSpots = [
      (lat: 37.7750, lon: -122.4192, quality: 88, minutesAgo: 5),
      (lat: 37.7748, lon: -122.4196, quality: 72, minutesAgo: 15),
      (lat: 37.7752, lon: -122.4191, quality: 95, minutesAgo: 30),
      (lat: 37.7747, lon: -122.4195, quality: 55, minutesAgo: 45),
      (lat: 37.7749, lon: -122.4193, quality: 80, minutesAgo: 55),
    ];

    for (final spot in recentSpots) {
      final reading = SignalReading(
        timestamp: now.subtract(Duration(minutes: spot.minutesAgo)),
        type: SignalType.wifi,
        qualityScore: spot.quality,
        location: GeoPosition(latitude: spot.lat, longitude: spot.lon),
      );

      // Record reading (service will update timestamp, but that's ok for demo)
      _heatmapHistory.recordReading(reading);
    }
  }

  /// Simulate a new signal reading.
  void _simulateNewReading() {
    if (!_demoMode) return;

    // Generate a point near the current position
    final latOffset = (_random.nextDouble() - 0.5) * 0.001; // ~100m range
    final lonOffset = (_random.nextDouble() - 0.5) * 0.001;

    final quality = 40 + _random.nextInt(60); // 40-100 quality

    final reading = SignalReading(
      timestamp: DateTime.now(),
      type: _random.nextBool() ? SignalType.wifi : SignalType.cellular,
      qualityScore: quality,
      location: GeoPosition(
        latitude: _currentPosition.latitude + latOffset,
        longitude: _currentPosition.longitude + lonOffset,
        accuracy: 5 + _random.nextDouble() * 20,
      ),
    );

    _heatmapHistory.recordReading(reading);
    setState(() {}); // Trigger rebuild
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _headingSubscription?.cancel();
    _statusSubscription?.cancel();
    _heatmapSimulationTimer?.cancel();
    _heatmapRefreshTimer?.cancel();
    _compass.dispose();
    _heatmapHistory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XENOSIGNAL'),
        actions: [
          IconButton(
            icon: Icon(_demoMode ? Icons.play_arrow : Icons.pause),
            onPressed: () => setState(() => _demoMode = !_demoMode),
            tooltip: _demoMode ? 'Demo Active' : 'Demo Paused',
          ),
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
              // Status bar with compass and heatmap stats
              _buildStatusBar(),

              // Radar display (main content)
              Expanded(
                child: _buildRadarDisplay(),
              ),

              // Heading readout
              _buildHeadingReadout(),

              // Heatmap legend
              _buildHeatmapLegend(),

              const SizedBox(height: XenoTheme.spacing1x),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final freshCount = _heatmapHistory.freshPoints.length;
    final histCount = _heatmapHistory.historicalPoints.length;

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
            'BLIPS: $freshCount / ${freshCount + histCount}',
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

            // Convert heading to radians
            final compassRadians = _heading * (math.pi / 180);

            return CustomPaint(
              painter: RadarPainter(
                sweepAngle: sweepAngle,
                compassHeading: compassRadians,
                heatmapPoints: _heatmapHistory.points,
                currentPosition: _currentPosition,
                radarRangeMeters: 200.0, // 200m radar range
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

  /// Builds a legend showing heatmap aging behavior.
  Widget _buildHeatmapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: XenoTheme.spacing2x,
        vertical: XenoTheme.spacing1x,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: XenoColors.primaryGreen,
            label: 'FRESH',
          ),
          const SizedBox(width: XenoTheme.spacing2x),
          _buildLegendItem(
            color: XenoColors.primaryGreen.withValues(alpha: 0.5),
            label: 'AGING',
          ),
          const SizedBox(width: XenoTheme.spacing2x),
          _buildLegendItem(
            color: const Color(0xFF1A3A1A),
            label: 'HISTORICAL',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: XenoTypography.caption().copyWith(fontSize: 10),
        ),
      ],
    );
  }

  String _getCardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}
