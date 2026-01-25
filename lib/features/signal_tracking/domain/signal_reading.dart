import 'signal_type.dart';

/// Geographic position for signal location tracking.
class GeoPosition {
  /// Creates a geographic position.
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });

  /// Latitude in degrees (-90 to 90).
  final double latitude;

  /// Longitude in degrees (-180 to 180).
  final double longitude;

  /// Altitude in meters above sea level (optional).
  final double? altitude;

  /// Horizontal accuracy in meters (optional).
  final double? accuracy;

  @override
  String toString() =>
      'GeoPosition($latitude, $longitude${altitude != null ? ', alt: $altitude' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPosition &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          altitude == other.altitude &&
          accuracy == other.accuracy;

  @override
  int get hashCode => Object.hash(latitude, longitude, altitude, accuracy);
}

/// A single signal strength reading.
///
/// Captures signal data at a point in time, optionally with location.
/// Supports both raw dBm values (Android) and derived quality scores (iOS).
class SignalReading {
  /// Creates a signal reading.
  const SignalReading({
    required this.timestamp,
    required this.type,
    this.dbm,
    this.latencyMs,
    required this.qualityScore,
    this.networkName,
    this.connectionType,
    this.location,
  }) : assert(
          qualityScore >= 0 && qualityScore <= 100,
          'qualityScore must be between 0 and 100',
        );

  /// When this reading was taken.
  final DateTime timestamp;

  /// Type of signal (WiFi or cellular).
  final SignalType type;

  /// Raw signal strength in dBm (Android only, null on iOS).
  ///
  /// Typical ranges:
  /// - WiFi: -30 (excellent) to -90 (poor)
  /// - Cellular: -50 (excellent) to -120 (poor)
  final double? dbm;

  /// Ping latency in milliseconds.
  ///
  /// Used as a proxy for signal quality on iOS where raw dBm is unavailable.
  final double? latencyMs;

  /// Normalized quality score from 0 (no signal) to 100 (excellent).
  ///
  /// This is the unified metric for cross-platform comparison.
  final int qualityScore;

  /// Network identifier (SSID for WiFi, carrier name for cellular).
  final String? networkName;

  /// Connection type details.
  ///
  /// For WiFi: frequency band (e.g., "2.4 GHz", "5 GHz").
  /// For cellular: technology (e.g., "5G", "LTE", "3G").
  final String? connectionType;

  /// Geographic location where reading was taken (optional).
  final GeoPosition? location;

  /// Quality label for UI display per XenoSignal aesthetic.
  String get qualityLabel {
    if (qualityScore > 80) return 'CRITICAL HIT';
    if (qualityScore > 60) return 'FULLY LEVELED';
    if (qualityScore > 40) return 'LOW HP';
    return 'GAME OVER';
  }

  /// Creates a copy with optional field overrides.
  SignalReading copyWith({
    DateTime? timestamp,
    SignalType? type,
    double? dbm,
    double? latencyMs,
    int? qualityScore,
    String? networkName,
    String? connectionType,
    GeoPosition? location,
  }) {
    return SignalReading(
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      dbm: dbm ?? this.dbm,
      latencyMs: latencyMs ?? this.latencyMs,
      qualityScore: qualityScore ?? this.qualityScore,
      networkName: networkName ?? this.networkName,
      connectionType: connectionType ?? this.connectionType,
      location: location ?? this.location,
    );
  }

  @override
  String toString() =>
      'SignalReading(type: $type, quality: $qualityScore%, ${dbm != null ? 'dbm: $dbm, ' : ''}${networkName ?? 'unknown'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignalReading &&
          timestamp == other.timestamp &&
          type == other.type &&
          dbm == other.dbm &&
          latencyMs == other.latencyMs &&
          qualityScore == other.qualityScore &&
          networkName == other.networkName &&
          connectionType == other.connectionType &&
          location == other.location;

  @override
  int get hashCode => Object.hash(
        timestamp,
        type,
        dbm,
        latencyMs,
        qualityScore,
        networkName,
        connectionType,
        location,
      );
}

/// Utilities for normalizing signal readings across platforms.
abstract final class SignalNormalizer {
  /// Normalizes WiFi dBm to quality score (0-100).
  ///
  /// Based on spec ranges:
  /// - > -50 dBm: Excellent (80-100)
  /// - -50 to -60: Good (60-80)
  /// - -60 to -70: Fair (40-60)
  /// - < -70: Poor (0-40)
  static int normalizeWifiDbm(double dbm) {
    if (dbm >= -50) {
      // Excellent: -30 to -50 -> 80-100
      return (100 - ((dbm.abs() - 30) * (20 / 20))).round().clamp(80, 100);
    } else if (dbm >= -60) {
      // Good: -50 to -60 -> 60-80
      return (80 - ((dbm.abs() - 50) * (20 / 10))).round().clamp(60, 80);
    } else if (dbm >= -70) {
      // Fair: -60 to -70 -> 40-60
      return (60 - ((dbm.abs() - 60) * (20 / 10))).round().clamp(40, 60);
    } else {
      // Poor: -70 to -90 -> 0-40
      return (40 - ((dbm.abs() - 70) * (40 / 20))).round().clamp(0, 40);
    }
  }

  /// Normalizes cellular dBm to quality score (0-100).
  ///
  /// Based on spec ranges:
  /// - > -70 dBm: Excellent (80-100)
  /// - -70 to -85: Good (60-80)
  /// - -85 to -100: Fair (40-60)
  /// - < -100: Poor (0-40)
  static int normalizeCellularDbm(double dbm) {
    if (dbm >= -70) {
      // Excellent: -50 to -70 -> 80-100
      return (100 - ((dbm.abs() - 50) * (20 / 20))).round().clamp(80, 100);
    } else if (dbm >= -85) {
      // Good: -70 to -85 -> 60-80
      return (80 - ((dbm.abs() - 70) * (20 / 15))).round().clamp(60, 80);
    } else if (dbm >= -100) {
      // Fair: -85 to -100 -> 40-60
      return (60 - ((dbm.abs() - 85) * (20 / 15))).round().clamp(40, 60);
    } else {
      // Poor: -100 to -120 -> 0-40
      return (40 - ((dbm.abs() - 100) * (40 / 20))).round().clamp(0, 40);
    }
  }

  /// Normalizes ping latency to quality score (0-100).
  ///
  /// Based on spec:
  /// - < 20ms: Excellent (80-100)
  /// - 20-50ms: Good (60-80)
  /// - 50-100ms: Fair (40-60)
  /// - > 100ms: Poor (0-40)
  static int normalizeLatency(double latencyMs) {
    if (latencyMs <= 20) {
      // Excellent: 0-20ms -> 80-100
      return (100 - (latencyMs * (20 / 20))).round().clamp(80, 100);
    } else if (latencyMs <= 50) {
      // Good: 20-50ms -> 60-80
      return (80 - ((latencyMs - 20) * (20 / 30))).round().clamp(60, 80);
    } else if (latencyMs <= 100) {
      // Fair: 50-100ms -> 40-60
      return (60 - ((latencyMs - 50) * (20 / 50))).round().clamp(40, 60);
    } else {
      // Poor: 100-500ms -> 0-40 (cap at 500ms)
      final capped = latencyMs.clamp(100, 500);
      return (40 - ((capped - 100) * (40 / 400))).round().clamp(0, 40);
    }
  }

  /// Normalizes dBm to quality score based on signal type.
  static int normalizeDbm(double dbm, SignalType type) => switch (type) {
        SignalType.wifi => normalizeWifiDbm(dbm),
        SignalType.cellular => normalizeCellularDbm(dbm),
      };
}
