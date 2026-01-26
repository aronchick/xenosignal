import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/effects/crt_effect.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../signal_tracking/signal_tracking_exports.dart';
import '../data/data_exports.dart';
import '../domain/domain_exports.dart';

/// Map-based heatmap visualization screen.
///
/// Displays recorded signal data as a heatmap overlay on OpenStreetMap,
/// styled with the XenoSignal Aliens aesthetic (dark green monochrome).
class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final MapController _mapController = MapController();
  final HeatmapRepository _repository = HeatmapRepository();
  final LocationService _locationService = LocationService();
  late final SignalRecorder _recorder;

  List<SignalMapPoint> _points = [];
  List<HeatmapTile> _tiles = [];
  GeoPosition? _currentPosition;
  HeatmapStats? _stats;

  bool _isLoading = true;
  bool _crtEnabled = true;
  bool _isRecording = false;
  String? _errorMessage;

  StreamSubscription<GeoPosition>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _recorder = SignalRecorder(
      repository: _repository,
      signalRepository: SignalService(),
      locationService: _locationService,
    );
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    try {
      // Request location permission
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Location permission required for heatmap';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      _currentPosition = await _locationService.getCurrentPosition();

      // Start listening for location updates
      await _locationService.startTracking();
      _locationSubscription = _locationService.positionStream.listen((pos) {
        setState(() => _currentPosition = pos);
      });

      // Load data for current area
      await _loadDataForCurrentArea();

      // Load stats
      _stats = await _repository.getStats();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataForCurrentArea() async {
    if (_currentPosition == null) return;

    final bounds = GeoBounds.fromCenterAndRadius(
      _currentPosition!,
      2000, // 2km radius
    );

    _points = await _repository.getPointsInBounds(bounds);
    _tiles = await _repository.generateTiles(
      bounds: bounds,
      tileSizeMeters: 100, // 100m tiles
    );

    setState(() {});
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.dispose();
    _recorder.dispose();
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIGNAL MAP'),
        actions: [
          // Recording toggle
          IconButton(
            icon: Icon(
              _isRecording ? Icons.pause_circle : Icons.play_circle,
              color: _isRecording ? XenoColors.primaryGreen : null,
            ),
            onPressed: _toggleRecording,
            tooltip: _isRecording ? 'Stop Recording' : 'Start Recording',
          ),
          // CRT toggle
          IconButton(
            icon: Icon(_crtEnabled ? Icons.blur_on : Icons.blur_off),
            onPressed: () => setState(() => _crtEnabled = !_crtEnabled),
            tooltip: 'Toggle CRT Effect',
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDataForCurrentArea,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: CrtOverlay(
        enabled: _crtEnabled,
        child: _buildBody(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Manual pin button
          FloatingActionButton.small(
            heroTag: 'pin',
            onPressed: _addManualPin,
            backgroundColor: XenoColors.primaryGreen,
            child: const Icon(Icons.push_pin),
          ),
          const SizedBox(height: XenoTheme.spacing2x),
          // Center on location button
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed: _centerOnCurrentLocation,
            backgroundColor: XenoColors.surfaceDark,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: XenoColors.primaryGreen),
            const SizedBox(height: XenoTheme.spacing2x),
            Text('SCANNING...', style: XenoTypography.body()),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: XenoColors.danger),
            const SizedBox(height: XenoTheme.spacing2x),
            Text(_errorMessage!, style: XenoTypography.body()),
            const SizedBox(height: XenoTheme.spacing2x),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stats bar
        _buildStatsBar(),
        // Map
        Expanded(child: _buildMap()),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: XenoTheme.spacing2x,
        vertical: XenoTheme.spacing1x,
      ),
      color: XenoColors.surfaceDark,
      child: Row(
        children: [
          _buildStatChip('POINTS', _points.length.toString()),
          const SizedBox(width: XenoTheme.spacing2x),
          _buildStatChip('PINS', _stats?.manualPinCount.toString() ?? '0'),
          const Spacer(),
          if (_isRecording)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: XenoColors.danger,
                    boxShadow: [
                      BoxShadow(
                        color: XenoColors.danger.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: XenoTheme.spacing1x),
                Text('REC', style: XenoTypography.caption()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: XenoTypography.caption()),
        Text(value, style: XenoTypography.body()),
      ],
    );
  }

  Widget _buildMap() {
    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(0, 0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
        backgroundColor: XenoColors.background,
      ),
      children: [
        // Dark-themed map tiles
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.xenosignal.app',
          // Apply green tint overlay
          tileBuilder: (context, tileWidget, tile) {
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2, 0, 0, 0, 0,   // Red
                0.5, 1, 0.5, 0, 0, // Green boost
                0.2, 0, 0, 0, 0,   // Blue
                0, 0, 0, 1, 0,     // Alpha
              ]),
              child: tileWidget,
            );
          },
        ),
        // Heatmap tiles layer
        if (_tiles.isNotEmpty) _buildHeatmapLayer(),
        // Individual points layer (for manual pins)
        _buildPointsLayer(),
        // Current location marker
        if (_currentPosition != null) _buildCurrentLocationMarker(),
      ],
    );
  }

  Widget _buildHeatmapLayer() {
    return PolygonLayer(
      polygons: _tiles.map((tile) {
        final opacity = (tile.intensity * 0.6).clamp(0.1, 0.6);
        final color = _getColorForQuality(tile.avgSignalQuality.round());

        return Polygon(
          points: [
            LatLng(tile.bounds.south, tile.bounds.west),
            LatLng(tile.bounds.north, tile.bounds.west),
            LatLng(tile.bounds.north, tile.bounds.east),
            LatLng(tile.bounds.south, tile.bounds.east),
          ],
          color: color.withValues(alpha: opacity),
          borderColor: color.withValues(alpha: opacity * 0.5),
          borderStrokeWidth: 1,
        );
      }).toList(),
    );
  }

  Widget _buildPointsLayer() {
    final manualPins = _points.where((p) => p.isManualPin).toList();

    return MarkerLayer(
      markers: manualPins.map((point) {
        return Marker(
          point: LatLng(point.position.latitude, point.position.longitude),
          width: 32,
          height: 32,
          child: _buildPinMarker(point),
        );
      }).toList(),
    );
  }

  Widget _buildPinMarker(SignalMapPoint point) {
    final color = _getColorForQuality(point.reading.qualityScore);

    return GestureDetector(
      onTap: () => _showPointDetails(point),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: XenoColors.primaryGreen, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.push_pin,
          size: 16,
          color: XenoColors.background,
        ),
      ),
    );
  }

  Widget _buildCurrentLocationMarker() {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: XenoColors.primaryGreen,
              shape: BoxShape.circle,
              border: Border.all(color: XenoColors.background, width: 3),
              boxShadow: [
                BoxShadow(
                  color: XenoColors.glowGreen.withValues(alpha: 0.8),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(XenoTheme.spacing2x),
      color: XenoColors.surfaceDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('EXCELLENT', XenoColors.primaryGreen),
          _buildLegendItem('GOOD', XenoColors.classicGreen),
          _buildLegendItem('FAIR', XenoColors.amber),
          _buildLegendItem('POOR', XenoColors.danger),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: XenoTypography.caption()),
      ],
    );
  }

  Color _getColorForQuality(int quality) {
    if (quality > 80) return XenoColors.primaryGreen;
    if (quality > 60) return XenoColors.classicGreen;
    if (quality > 40) return XenoColors.amber;
    return XenoColors.danger;
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _recorder.stopRecording();
    } else {
      final started = await _recorder.startRecording();
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start recording')),
        );
        return;
      }
    }
    setState(() => _isRecording = _recorder.isRecording);
  }

  Future<void> _addManualPin() async {
    final label = await _showLabelDialog();
    if (label == null) return; // User cancelled

    final point = await _recorder.recordManualPin(label: label.isEmpty ? null : label);

    if (point != null) {
      await _loadDataForCurrentArea();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pin added: ${point.reading.qualityScore}% signal'),
            backgroundColor: XenoColors.surfaceDark,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not add pin'),
          backgroundColor: XenoColors.danger,
        ),
      );
    }
  }

  Future<String?> _showLabelDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: XenoColors.surfaceDark,
        title: Text('MARK LOCATION', style: XenoTypography.title()),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Optional label (e.g., "Good spot by window")',
          ),
          style: XenoTypography.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('MARK'),
          ),
        ],
      ),
    );
  }

  void _showPointDetails(SignalMapPoint point) {
    showModalBottomSheet(
      context: context,
      backgroundColor: XenoColors.surfaceDark,
      builder: (context) => Container(
        padding: const EdgeInsets.all(XenoTheme.spacing4x),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.push_pin,
                  color: _getColorForQuality(point.reading.qualityScore),
                ),
                const SizedBox(width: XenoTheme.spacing1x),
                Text(
                  point.label ?? 'MANUAL PIN',
                  style: XenoTypography.title(),
                ),
              ],
            ),
            const SizedBox(height: XenoTheme.spacing2x),
            _buildDetailRow('QUALITY', '${point.reading.qualityScore}%'),
            _buildDetailRow('LABEL', point.reading.qualityLabel),
            _buildDetailRow('NETWORK', point.reading.networkName ?? 'Unknown'),
            _buildDetailRow('TYPE', point.reading.type.name.toUpperCase()),
            _buildDetailRow(
              'RECORDED',
              _formatDateTime(point.recordedAt),
            ),
            if (point.reading.dbm != null)
              _buildDetailRow('DBM', '${point.reading.dbm}'),
            const SizedBox(height: XenoTheme.spacing2x),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: XenoTypography.caption()),
          ),
          Expanded(
            child: Text(value, style: XenoTypography.body()),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16,
      );
    }
  }
}
