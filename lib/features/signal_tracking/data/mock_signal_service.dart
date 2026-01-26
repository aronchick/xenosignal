import 'dart:async';
import 'dart:math';

import '../domain/domain_exports.dart';
import 'signal_repository.dart';

/// Mock signal service for testing and demo purposes.
///
/// Generates realistic simulated signal readings that vary over time,
/// allowing the app to be demonstrated without platform channels.
/// Signal strength oscillates naturally with added random noise.
class MockSignalService implements SignalRepository {
  MockSignalService({
    this.baseWifiDbm = -55.0,
    this.baseCellularDbm = -75.0,
    this.variationAmplitude = 15.0,
    this.noiseLevel = 5.0,
    this.baseLatencyMs = 25.0,
    Random? random,
  }) : _random = random ?? Random();

  /// Base WiFi signal strength in dBm (around -55 is "good").
  final double baseWifiDbm;

  /// Base cellular signal strength in dBm (around -75 is "good").
  final double baseCellularDbm;

  /// Amplitude of signal variation over time (dBm).
  final double variationAmplitude;

  /// Random noise level (dBm).
  final double noiseLevel;

  /// Base ping latency in milliseconds.
  final double baseLatencyMs;

  final Random _random;
  final DateTime _startTime = DateTime.now();

  StreamController<SignalReading>? _signalStreamController;
  Timer? _pollingTimer;

  /// Generates a time-varying signal value with natural variation.
  ///
  /// Uses sine wave for smooth oscillation plus random noise for realism.
  double _generateSignal(double base, {double? amplitude, double? noise}) {
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    final effectiveAmplitude = amplitude ?? variationAmplitude;
    final effectiveNoise = noise ?? noiseLevel;

    // Slow oscillation over ~30 seconds for natural movement
    final oscillation =
        sin(elapsed / 30000 * 2 * pi) * effectiveAmplitude * 0.7;

    // Faster secondary oscillation for texture
    final secondaryOscillation =
        sin(elapsed / 5000 * 2 * pi) * effectiveAmplitude * 0.3;

    // Random noise
    final randomNoise = (_random.nextDouble() - 0.5) * effectiveNoise * 2;

    return base + oscillation + secondaryOscillation + randomNoise;
  }

  /// Generates a mock geographic position near a base location.
  GeoPosition _generateLocation() {
    // Base location: somewhere interesting (San Francisco)
    const baseLat = 37.7749;
    const baseLng = -122.4194;

    // Small random offset (within ~100m)
    final latOffset = (_random.nextDouble() - 0.5) * 0.001;
    final lngOffset = (_random.nextDouble() - 0.5) * 0.001;

    return GeoPosition(
      latitude: baseLat + latOffset,
      longitude: baseLng + lngOffset,
      accuracy: 10.0 + _random.nextDouble() * 20.0,
    );
  }

  @override
  Future<SignalReading?> getWifiSignal() async {
    // Simulate network delay
    await Future<void>.delayed(
      Duration(milliseconds: 50 + _random.nextInt(50)),
    );

    final dbm = _generateSignal(baseWifiDbm);
    final latency = _generateSignal(
      baseLatencyMs,
      amplitude: 15.0,
      noise: 10.0,
    ).clamp(5.0, 200.0);

    return SignalReading(
      timestamp: DateTime.now(),
      type: SignalType.wifi,
      dbm: dbm,
      latencyMs: latency,
      qualityScore: SignalNormalizer.normalizeWifiDbm(dbm),
      networkName: 'XenoNet-5G',
      connectionType: '5 GHz',
      location: _generateLocation(),
    );
  }

  @override
  Future<SignalReading?> getCellularSignal() async {
    await Future<void>.delayed(
      Duration(milliseconds: 50 + _random.nextInt(50)),
    );

    final dbm = _generateSignal(baseCellularDbm);
    final latency = _generateSignal(
      baseLatencyMs + 10,
      amplitude: 20.0,
      noise: 15.0,
    ).clamp(10.0, 300.0);

    return SignalReading(
      timestamp: DateTime.now(),
      type: SignalType.cellular,
      dbm: dbm,
      latencyMs: latency,
      qualityScore: SignalNormalizer.normalizeCellularDbm(dbm),
      networkName: 'Weyland-Yutani',
      connectionType: '5G',
      location: _generateLocation(),
    );
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

    // Emit initial readings immediately
    _emitReadings(effectiveTypes);

    _pollingTimer = Timer.periodic(interval, (_) {
      _emitReadings(effectiveTypes);
    });

    return _signalStreamController!.stream;
  }

  void _emitReadings(Set<SignalType> types) {
    if (types.contains(SignalType.wifi)) {
      getWifiSignal().then((reading) {
        if (reading != null) _signalStreamController?.add(reading);
      });
    }

    if (types.contains(SignalType.cellular)) {
      getCellularSignal().then((reading) {
        if (reading != null) _signalStreamController?.add(reading);
      });
    }
  }

  @override
  Future<double?> measureLatency({String target = '1.1.1.1'}) async {
    await Future<void>.delayed(
      Duration(milliseconds: 20 + _random.nextInt(30)),
    );

    return _generateSignal(
      baseLatencyMs,
      amplitude: 15.0,
      noise: 10.0,
    ).clamp(5.0, 200.0);
  }

  @override
  Future<bool> isWifiEnabled() async => true;

  @override
  Future<bool> isCellularEnabled() async => true;

  @override
  Future<String> getConnectionType() async => 'WiFi (Mock)';

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _signalStreamController?.close();
    _signalStreamController = null;
    _pollingTimer = null;
  }
}
