import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../domain/domain_exports.dart';
import 'signal_repository.dart';

/// Platform channel for native signal access.
///
/// Communicates with:
/// - Android: WifiManager, TelephonyManager
/// - iOS: NEHotspotNetwork, CTTelephonyNetworkInfo
const _signalChannel = MethodChannel('com.xenosignal/signal');

/// Signal service implementation using platform channels.
///
/// Provides signal readings via native platform APIs with
/// fallback to ping-based quality measurement on iOS.
class SignalService implements SignalRepository {
  SignalService({
    this.pingTargets = const ['1.1.1.1', '8.8.8.8', '9.9.9.9'],
    this.pingTimeoutMs = 5000,
  });

  /// Ping targets for latency-based quality measurement.
  final List<String> pingTargets;

  /// Timeout for ping operations in milliseconds.
  final int pingTimeoutMs;

  StreamController<SignalReading>? _signalStreamController;
  Timer? _pollingTimer;

  @override
  Future<SignalReading?> getWifiSignal() async {
    try {
      final result = await _signalChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getWifiSignal',
      );

      if (result == null) return null;

      return _parseSignalResult(result, SignalType.wifi);
    } on PlatformException catch (e) {
      // WiFi access failed or not available
      _logError('getWifiSignal', e);
      return null;
    } on MissingPluginException {
      // Platform channel not implemented - use fallback
      return _getFallbackWifiSignal();
    }
  }

  @override
  Future<SignalReading?> getCellularSignal() async {
    try {
      final result = await _signalChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getCellularSignal',
      );

      if (result == null) return null;

      return _parseSignalResult(result, SignalType.cellular);
    } on PlatformException catch (e) {
      _logError('getCellularSignal', e);
      return null;
    } on MissingPluginException {
      // Platform channel not implemented - use fallback
      return _getFallbackCellularSignal();
    }
  }

  @override
  Future<({SignalReading? wifi, SignalReading? cellular})> getAllSignals() async {
    final results = await Future.wait([
      getWifiSignal(),
      getCellularSignal(),
    ]);

    return (wifi: results[0], cellular: results[1]);
  }

  @override
  Stream<SignalReading> watchSignals({
    Duration interval = const Duration(seconds: 2),
    Set<SignalType>? types,
  }) {
    _signalStreamController?.close();
    _pollingTimer?.cancel();

    _signalStreamController = StreamController<SignalReading>.broadcast(
      onCancel: () {
        _pollingTimer?.cancel();
        _pollingTimer = null;
      },
    );

    final effectiveTypes = types ?? {SignalType.wifi, SignalType.cellular};

    _pollingTimer = Timer.periodic(interval, (_) async {
      if (effectiveTypes.contains(SignalType.wifi)) {
        final wifi = await getWifiSignal();
        if (wifi != null) _signalStreamController?.add(wifi);
      }

      if (effectiveTypes.contains(SignalType.cellular)) {
        final cellular = await getCellularSignal();
        if (cellular != null) _signalStreamController?.add(cellular);
      }
    });

    return _signalStreamController!.stream;
  }

  @override
  Future<double?> measureLatency({String target = '1.1.1.1'}) async {
    return _pingHost(target);
  }

  @override
  Future<bool> isWifiEnabled() async {
    try {
      final result = await _signalChannel.invokeMethod<bool>('isWifiEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Assume enabled if we can't check
      return true;
    }
  }

  @override
  Future<bool> isCellularEnabled() async {
    try {
      final result = await _signalChannel.invokeMethod<bool>(
        'isCellularEnabled',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return true;
    }
  }

  @override
  Future<String> getConnectionType() async {
    try {
      final result = await _signalChannel.invokeMethod<String>(
        'getConnectionType',
      );
      return result ?? 'Unknown';
    } on PlatformException {
      return 'Error';
    } on MissingPluginException {
      return 'Unknown';
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _signalStreamController?.close();
    _signalStreamController = null;
    _pollingTimer = null;
  }

  // --- Private methods ---

  /// Parses native platform result into SignalReading.
  SignalReading _parseSignalResult(
    Map<dynamic, dynamic> result,
    SignalType type,
  ) {
    final dbm = result['dbm'] as double?;
    final latencyMs = result['latencyMs'] as double?;

    // Calculate quality score from available data
    int qualityScore;
    if (dbm != null) {
      qualityScore = SignalNormalizer.normalizeDbm(dbm, type);
    } else if (latencyMs != null) {
      qualityScore = SignalNormalizer.normalizeLatency(latencyMs);
    } else {
      // Default to mid-range if no data
      qualityScore = 50;
    }

    return SignalReading(
      timestamp: DateTime.now(),
      type: type,
      dbm: dbm,
      latencyMs: latencyMs,
      qualityScore: qualityScore,
      networkName: result['networkName'] as String?,
      connectionType: result['connectionType'] as String?,
      location: _parseLocation(result['location'] as Map<dynamic, dynamic>?),
    );
  }

  GeoPosition? _parseLocation(Map<dynamic, dynamic>? location) {
    if (location == null) return null;

    return GeoPosition(
      latitude: location['latitude'] as double,
      longitude: location['longitude'] as double,
      altitude: location['altitude'] as double?,
      accuracy: location['accuracy'] as double?,
    );
  }

  /// Fallback WiFi signal using ping-based quality.
  Future<SignalReading?> _getFallbackWifiSignal() async {
    final latency = await _measureAverageLatency();
    if (latency == null) return null;

    return SignalReading(
      timestamp: DateTime.now(),
      type: SignalType.wifi,
      latencyMs: latency,
      qualityScore: SignalNormalizer.normalizeLatency(latency),
      networkName: 'WiFi', // Can't get SSID without platform channel
    );
  }

  /// Fallback cellular signal using ping-based quality.
  Future<SignalReading?> _getFallbackCellularSignal() async {
    final latency = await _measureAverageLatency();
    if (latency == null) return null;

    return SignalReading(
      timestamp: DateTime.now(),
      type: SignalType.cellular,
      latencyMs: latency,
      qualityScore: SignalNormalizer.normalizeLatency(latency),
      networkName: 'Cellular',
    );
  }

  /// Measures average latency across multiple targets.
  Future<double?> _measureAverageLatency() async {
    final latencies = <double>[];

    for (final target in pingTargets) {
      final latency = await _pingHost(target);
      if (latency != null) {
        latencies.add(latency);
      }
    }

    if (latencies.isEmpty) return null;

    return latencies.reduce((a, b) => a + b) / latencies.length;
  }

  /// Pings a host and returns round-trip latency in ms.
  Future<double?> _pingHost(String host) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Use socket connection as cross-platform "ping"
      // ICMP ping requires elevated permissions on most platforms
      final socket = await Socket.connect(
        host,
        53, // DNS port - usually open
        timeout: Duration(milliseconds: pingTimeoutMs),
      );

      stopwatch.stop();
      await socket.close();

      return stopwatch.elapsedMilliseconds.toDouble();
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    }
  }

  void _logError(String method, PlatformException e) {
    // In production, this would use a proper logging system
    // ignore: avoid_print
    print('SignalService.$method error: ${e.code} - ${e.message}');
  }
}
