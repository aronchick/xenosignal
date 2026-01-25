import '../domain/domain_exports.dart';

/// Abstract interface for signal reading operations.
///
/// This defines the contract for signal data access, allowing
/// different implementations (platform-specific, mock for testing).
abstract interface class SignalRepository {
  /// Gets the current WiFi signal reading.
  ///
  /// Returns null if WiFi is disabled or not connected.
  Future<SignalReading?> getWifiSignal();

  /// Gets the current cellular signal reading.
  ///
  /// Returns null if cellular is disabled or in airplane mode.
  Future<SignalReading?> getCellularSignal();

  /// Gets both WiFi and cellular readings.
  ///
  /// Convenience method that fetches both signal types concurrently.
  Future<({SignalReading? wifi, SignalReading? cellular})> getAllSignals();

  /// Streams continuous signal readings at the specified interval.
  ///
  /// The [interval] determines how frequently readings are taken.
  /// The [types] parameter filters which signal types to include.
  /// If [types] is null, both WiFi and cellular are included.
  Stream<SignalReading> watchSignals({
    Duration interval = const Duration(seconds: 2),
    Set<SignalType>? types,
  });

  /// Measures connection quality using ping latency.
  ///
  /// This is primarily used on iOS where raw dBm is unavailable.
  /// The [target] is the ping destination (default: 1.1.1.1).
  Future<double?> measureLatency({String target = '1.1.1.1'});

  /// Checks if WiFi is currently enabled on the device.
  Future<bool> isWifiEnabled();

  /// Checks if cellular data is currently enabled.
  Future<bool> isCellularEnabled();

  /// Gets the current network connection type.
  ///
  /// Returns descriptive string like "WiFi", "5G", "LTE", "None".
  Future<String> getConnectionType();

  /// Disposes of any resources held by the repository.
  void dispose();
}

/// Result of a ping latency measurement.
class LatencyResult {
  /// Creates a latency result.
  const LatencyResult({
    required this.target,
    required this.latencyMs,
    required this.success,
    this.errorMessage,
  });

  /// The target that was pinged.
  final String target;

  /// Round-trip latency in milliseconds (null if failed).
  final double? latencyMs;

  /// Whether the ping was successful.
  final bool success;

  /// Error message if the ping failed.
  final String? errorMessage;

  @override
  String toString() => success
      ? 'LatencyResult($target: ${latencyMs}ms)'
      : 'LatencyResult($target: FAILED - $errorMessage)';
}
