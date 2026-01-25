/// Signal type enumeration for XenoSignal.
///
/// Distinguishes between WiFi and cellular network signals,
/// which have different measurement characteristics and APIs.
enum SignalType {
  /// WiFi network signal.
  ///
  /// On Android: Direct dBm from WifiManager.
  /// On iOS: Limited access via NEHotspotNetwork.
  wifi,

  /// Cellular network signal.
  ///
  /// On Android: Direct dBm from TelephonyManager.
  /// On iOS: Limited access via CTTelephonyNetworkInfo.
  cellular,
}

/// Extension methods for [SignalType].
extension SignalTypeExtension on SignalType {
  /// Human-readable display name.
  String get displayName => switch (this) {
        SignalType.wifi => 'WIFI',
        SignalType.cellular => 'CELLULAR',
      };

  /// Icon name for UI display.
  String get iconName => switch (this) {
        SignalType.wifi => 'wifi',
        SignalType.cellular => 'signal_cellular_alt',
      };

  /// Whether this signal type typically has direct dBm access on Android.
  bool get hasDirectDbmOnAndroid => true;

  /// Whether this signal type has direct dBm access on iOS.
  ///
  /// iOS restricts raw signal strength data for both WiFi and cellular.
  bool get hasDirectDbmOnIOS => false;
}
