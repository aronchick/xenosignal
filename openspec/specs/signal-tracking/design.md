# Signal Tracking - Technical Design

## Context
Signal tracking is the foundational capability—without accurate, cross-platform signal measurement, nothing else works. The critical challenge is iOS restrictions on signal data access.

## Goals
- Provide accurate signal strength readings on both platforms
- Create unified quality metric that's comparable across platforms
- Support background monitoring with minimal battery impact
- Handle edge cases gracefully (airplane mode, no SIM, etc.)

## Non-Goals
- Tower triangulation or network diagnostics
- VPN or network security features
- Speed testing (beyond ping latency)

## Architecture

### Platform Abstraction Layer

```
┌─────────────────────────────────────────────────────────────┐
│                    SignalService                             │
│  Unified API for signal measurement                         │
├─────────────────────────────────────────────────────────────┤
│  abstract SignalReading getCurrentSignal()                  │
│  abstract Stream<SignalReading> signalStream()              │
│  abstract Future<QualityScore> measureQuality()             │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   AndroidSignal │ │    iOSSignal    │ │   MockSignal    │
│   Service       │ │    Service      │ │   Service       │
├─────────────────┤ ├─────────────────┤ ├─────────────────┤
│ • WifiManager   │ │ • NEHotspot     │ │ • Testing       │
│ • TelephonyMgr  │ │ • CTTelephony   │ │ • Simulator     │
│ • Direct dBm    │ │ • Ping proxy    │ │                 │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Android Implementation

Android provides direct access to signal strength via platform APIs:

```kotlin
// android/app/src/main/kotlin/SignalMethodChannel.kt

class SignalMethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    private val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
    private val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

    fun getWifiSignal(): Map<String, Any> {
        val wifiInfo = wifiManager.connectionInfo
        return mapOf(
            "ssid" to wifiInfo.ssid.trim('"'),
            "bssid" to wifiInfo.bssid,
            "rssi" to wifiInfo.rssi,  // dBm, typically -30 to -90
            "frequency" to wifiInfo.frequency,
            "linkSpeed" to wifiInfo.linkSpeedMbps
        )
    }

    fun getCellularSignal(): Map<String, Any> {
        val cellInfo = telephonyManager.allCellInfo?.firstOrNull()
        return when (cellInfo) {
            is CellInfoLte -> mapOf(
                "type" to "LTE",
                "rssi" to cellInfo.cellSignalStrength.rssi,
                "rsrp" to cellInfo.cellSignalStrength.rsrp,
                "rsrq" to cellInfo.cellSignalStrength.rsrq
            )
            is CellInfoNr -> mapOf(
                "type" to "5G",
                "ssRsrp" to cellInfo.cellSignalStrength.ssRsrp,
                "ssRsrq" to cellInfo.cellSignalStrength.ssRsrq
            )
            // ... other cell types
        }
    }
}
```

### iOS Implementation

iOS restricts direct signal access. We use a multi-metric approach:

```swift
// ios/Runner/SignalService.swift

class SignalService {

    // WiFi: Limited data available
    func getWifiInfo() -> [String: Any]? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String],
              let interface = interfaces.first,
              let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else {
            return nil
        }
        // Note: iOS only provides SSID and BSSID, NOT signal strength
        return [
            "ssid": info[kCNNetworkInfoKeySSID as String] ?? "",
            "bssid": info[kCNNetworkInfoKeyBSSID as String] ?? ""
        ]
    }

    // Cellular: Connection type only
    func getCellularType() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        guard let radioType = networkInfo.serviceCurrentRadioAccessTechnology?.values.first else {
            return "unknown"
        }
        switch radioType {
        case CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA:
            return "5G"
        case CTRadioAccessTechnologyLTE:
            return "LTE"
        // ... map other types
        }
    }
}
```

### Ping-Based Quality Measurement (iOS Fallback)

Since iOS doesn't provide raw signal strength, we derive quality from network performance:

```dart
class PingQualityService {
  final List<String> targets = ['1.1.1.1', '8.8.8.8', '9.9.9.9'];
  final int sampleCount = 5;
  final Duration timeout = Duration(seconds: 2);

  Future<QualityScore> measureQuality() async {
    final latencies = <double>[];
    int failures = 0;

    for (int i = 0; i < sampleCount; i++) {
      try {
        final latency = await _pingTarget(targets[i % targets.length]);
        latencies.add(latency);
      } catch (e) {
        failures++;
      }
      await Future.delayed(Duration(milliseconds: 200));
    }

    if (latencies.isEmpty) {
      return QualityScore.unreachable();
    }

    final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
    final packetLoss = failures / sampleCount;

    return QualityScore.fromMetrics(
      latencyMs: avgLatency,
      packetLoss: packetLoss,
      jitter: _calculateJitter(latencies),
    );
  }

  Future<double> _pingTarget(String host) async {
    final stopwatch = Stopwatch()..start();
    final socket = await Socket.connect(host, 53, timeout: timeout);
    stopwatch.stop();
    socket.destroy();
    return stopwatch.elapsedMilliseconds.toDouble();
  }
}
```

### Quality Score Normalization

Converting platform-specific metrics to unified 0-100 scale:

```dart
class QualityScore {
  final int score;        // 0-100
  final String label;     // "CRITICAL HIT", "LOW HP", etc.
  final SignalBand band;  // excellent, good, fair, poor

  static QualityScore fromAndroidWifi(int rssiDbm) {
    // RSSI typically ranges from -30 (excellent) to -90 (poor)
    final normalized = ((rssiDbm + 90) / 60 * 100).clamp(0, 100).toInt();
    return QualityScore._fromNormalized(normalized);
  }

  static QualityScore fromAndroidCellular(int rsrpDbm) {
    // RSRP ranges from -44 (excellent) to -140 (poor)
    final normalized = ((rsrpDbm + 140) / 96 * 100).clamp(0, 100).toInt();
    return QualityScore._fromNormalized(normalized);
  }

  static QualityScore fromMetrics({
    required double latencyMs,
    required double packetLoss,
    required double jitter,
  }) {
    // Weight: 60% latency, 25% packet loss, 15% jitter
    final latencyScore = _latencyToScore(latencyMs);
    final lossScore = ((1 - packetLoss) * 100).toInt();
    final jitterScore = _jitterToScore(jitter);

    final weighted = (latencyScore * 0.6 + lossScore * 0.25 + jitterScore * 0.15).toInt();
    return QualityScore._fromNormalized(weighted);
  }

  static int _latencyToScore(double ms) {
    if (ms < 20) return 100;
    if (ms < 50) return 80;
    if (ms < 100) return 60;
    if (ms < 200) return 40;
    return 20;
  }
}
```

### Background Monitoring

Using platform-specific background execution:

```dart
// Background service using workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'signalMonitor':
        final service = SignalService.instance;
        final reading = await service.getCurrentSignal();
        final location = await LocationService.instance.getCurrentPosition();

        await SignalDatabase.instance.insert(SignalRecord(
          reading: reading,
          location: location,
          timestamp: DateTime.now(),
        ));

        return true;
    }
    return false;
  });
}

// Registration
Workmanager().registerPeriodicTask(
  'signalMonitor',
  'signalMonitor',
  frequency: Duration(minutes: 15), // Minimum on Android
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
  ),
);
```

## Decisions

### Decision: TCP Ping over ICMP
**Rationale**: ICMP (raw ping) requires special permissions on mobile. TCP connection to DNS port 53 works without elevated privileges and is reliably fast.

**Alternatives Considered**:
- ICMP ping: Requires root/special entitlements
- HTTP request: Adds overhead, measures more than network
- UDP ping: Less reliable, may be blocked

### Decision: Multi-target ping rotation
**Rationale**: Single target could be temporarily slow or blocked. Rotating through Cloudflare, Google, and Quad9 provides resilience.

### Decision: Workmanager for background tasks
**Rationale**: Standard Flutter solution that handles both Android and iOS background execution with proper power management.

**Alternatives Considered**:
- flutter_background_service: More control but complex setup
- Native implementation: Platform-specific code duplication
- Foreground service: Too aggressive for this use case

## Platform Differences Summary

| Capability | Android | iOS |
|------------|---------|-----|
| WiFi RSSI (dBm) | ✅ Direct | ❌ Not available |
| WiFi SSID | ✅ Direct | ✅ With permission |
| Cellular dBm | ✅ Direct | ❌ Not available |
| Cellular type | ✅ Direct | ✅ Direct |
| Ping latency | ✅ | ✅ |
| Background (frequent) | ✅ 15min minimum | ⚠️ Limited |
| Background (significant location) | ✅ | ✅ |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| iOS ping blocked by firewall | No quality data | Multiple targets, graceful fallback |
| Background execution killed | Gaps in data | Use significant location changes trigger |
| Battery complaints | User churn | Clear battery usage, power modes |
| API changes (Apple/Google) | Breaking changes | Abstraction layer, feature detection |

## Open Questions
1. Should we attempt to use private APIs on jailbroken iOS devices?
2. What's the optimal ping frequency balance between accuracy and battery?
3. Should we support carrier WiFi calling detection?
