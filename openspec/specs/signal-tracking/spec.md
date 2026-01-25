# Signal Tracking

Core signal detection, measurement, and monitoring capabilities that power XenoSignal's functionality.

## Requirements

### Requirement: WiFi Signal Detection
The system SHALL detect and measure WiFi signal strength from the currently connected network.

#### Scenario: Android WiFi measurement
- **WHEN** device is connected to WiFi on Android
- **THEN** read signal strength in dBm from WifiManager
- **AND** update reading every 1-2 seconds
- **AND** provide SSID, BSSID, and frequency band

#### Scenario: iOS WiFi measurement
- **WHEN** device is connected to WiFi on iOS
- **THEN** use NEHotspotNetwork for available signal info
- **AND** supplement with ping latency measurements
- **AND** derive quality score from combined metrics

#### Scenario: WiFi disconnected
- **WHEN** WiFi is disabled or not connected
- **THEN** display "NO WIFI SIGNAL" state
- **AND** offer to scan for available networks (if permitted)

### Requirement: Cellular Signal Detection
The system SHALL detect and measure cellular signal strength from the active mobile connection.

#### Scenario: Android cellular measurement
- **WHEN** device has cellular service on Android
- **THEN** read signal strength in dBm from TelephonyManager
- **AND** identify connection type (5G, LTE, 3G, 2G)
- **AND** update reading every 1-2 seconds

#### Scenario: iOS cellular measurement
- **WHEN** device has cellular service on iOS
- **THEN** use CTTelephonyNetworkInfo for carrier and connection type
- **AND** use ping latency as proxy for signal quality
- **AND** derive quality score from latency distribution

#### Scenario: Airplane mode
- **WHEN** airplane mode is enabled
- **THEN** display "CELLULAR OFFLINE" state
- **AND** continue WiFi tracking if WiFi is enabled

### Requirement: Ping-Based Quality Measurement
The system SHALL measure connection quality through latency testing as a fallback or supplement to raw signal readings.

#### Scenario: Ping measurement cycle
- **WHEN** ping measurement is active
- **THEN** send ICMP or TCP pings to configurable targets (default: 1.1.1.1)
- **AND** measure round-trip time
- **AND** calculate rolling average over last 10 samples

#### Scenario: Quality score derivation
- **WHEN** ping measurements are available
- **THEN** derive quality score: Excellent (<20ms), Good (<50ms), Fair (<100ms), Poor (>100ms)
- **AND** factor in packet loss percentage
- **AND** smooth readings to avoid jitter

#### Scenario: Ping target unreachable
- **WHEN** ping target is unreachable
- **THEN** try alternative targets in sequence
- **AND** if all fail, indicate "NETWORK UNREACHABLE"
- **AND** distinguish from "weak signal" state

### Requirement: Background Signal Monitoring
The system SHALL continue monitoring signal strength while the app is in the background (with user permission).

#### Scenario: Background tracking enabled
- **WHEN** user enables background tracking
- **AND** appropriate permissions are granted
- **THEN** record signal readings every 5-30 seconds (configurable)
- **AND** associate readings with GPS coordinates
- **AND** minimize battery impact

#### Scenario: Significant change detection
- **WHEN** signal strength changes significantly (>10dB or quality band change)
- **THEN** record the event immediately
- **AND** optionally notify user of signal improvement/degradation

#### Scenario: Background tracking permissions
- **WHEN** background location permission is not granted
- **THEN** disable background tracking gracefully
- **AND** explain the limitation to the user
- **AND** offer foreground-only mode

### Requirement: Signal Normalization
The system SHALL normalize signal readings across platforms and connection types to a unified quality scale.

#### Scenario: Cross-platform normalization
- **WHEN** displaying signal quality
- **THEN** convert platform-specific readings to 0-100 quality score
- **AND** apply consistent thresholds for quality labels
- **AND** ensure iOS and Android show comparable readings for similar conditions

#### Scenario: Connection type weighting
- **WHEN** comparing WiFi and cellular
- **THEN** apply appropriate weighting (WiFi typically preferred for stability)
- **AND** factor in connection type (5G may outperform poor WiFi)
- **AND** allow user preference configuration

## Data Structures

### SignalReading
```dart
class SignalReading {
  final DateTime timestamp;
  final SignalType type; // wifi, cellular
  final double? dbm; // Raw dBm (Android)
  final double? latencyMs; // Ping latency
  final int qualityScore; // Normalized 0-100
  final String? networkName; // SSID or carrier
  final String? connectionType; // WiFi band, 5G/LTE/etc
  final GeoPosition? location;
}
```

## Non-Functional Requirements

### Accuracy
- dBm readings SHALL be within ±3dB of system-reported values
- Ping latency SHALL be within ±5ms of actual network latency
- Quality score SHALL be consistent across repeated measurements

### Efficiency
- Signal polling SHALL use < 1% CPU when app is in foreground
- Background tracking SHALL use < 3% battery per hour
- Network usage for ping tests SHALL be < 1KB per measurement
