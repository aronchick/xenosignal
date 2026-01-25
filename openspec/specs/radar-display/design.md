# Radar Display - Technical Design

## Context
The radar display is the heart of XenoSignal's user experience. It must render smooth 60fps animations while processing real-time sensor data and maintain the M314 Motion Tracker aesthetic. This is the most technically complex UI component.

## Goals
- Render radar sweep animation at 60fps on devices from 2020+
- Integrate compass, GPS, and signal data into unified visualization
- Apply CRT shader effects without impacting performance
- Support both foreground (full) and background (minimal) rendering modes

## Non-Goals
- 3D rendering or AR features
- Network visualization (tower locations, etc.)
- Offline map caching in radar view (handled by heatmap feature)

## Architecture

### Rendering Pipeline
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Sensor Layer   │────▶│  Data Layer     │────▶│  Render Layer   │
│                 │     │                 │     │                 │
│ • Compass       │     │ • Normalization │     │ • CustomPainter │
│ • GPS           │     │ • Smoothing     │     │ • Shader        │
│ • Signal        │     │ • Aggregation   │     │ • Compositor    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Key Components

#### 1. RadarPainter (CustomPainter)
The core rendering component using Flutter's `CustomPainter` for direct canvas control.

```dart
class RadarPainter extends CustomPainter {
  final double sweepAngle;        // Current sweep position (0-2π)
  final double compassHeading;     // Device orientation
  final List<SignalBlip> blips;   // Signal readings to display
  final RadarTheme theme;         // Visual configuration

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGridLines(canvas, size);
    _drawBlips(canvas, size);
    _drawSweepLine(canvas, size);
    _drawCenterReticle(canvas, size);
  }
}
```

#### 2. Sweep Animation Controller
Uses Flutter's `AnimationController` with a `Ticker` for smooth, continuous animation.

```dart
class SweepController {
  late AnimationController _controller;
  Duration rotationPeriod = const Duration(seconds: 3);

  void startSweep() {
    _controller.repeat(); // Continuous rotation
  }

  double get currentAngle => _controller.value * 2 * pi;
}
```

#### 3. Blip Manager
Manages the lifecycle of signal blips—creation, aging, and removal.

```dart
class BlipManager {
  final List<Blip> _activeBlips = [];
  final int maxBlips = 50;
  final Duration blipLifetime = Duration(seconds: 6);

  void addBlip(SignalReading reading, GeoPosition position) {
    // Convert to radar-relative coordinates
    // Add with current timestamp
    // Prune old blips if over limit
  }

  List<Blip> getVisibleBlips(double currentSweepAngle) {
    // Return blips that should be visible
    // Apply fade based on age
  }
}
```

### Coordinate Systems

The radar uses three coordinate systems that must be translated:

1. **World Coordinates** (GPS)
   - Latitude/Longitude
   - Meters from reference point

2. **Compass Coordinates**
   - 0° = North, 90° = East
   - Device heading offset

3. **Screen Coordinates**
   - 0° = Top of screen
   - Clockwise rotation
   - Pixels from center

```dart
Offset worldToScreen(GeoPosition target, GeoPosition user, double heading, Size radarSize) {
  // 1. Calculate bearing from user to target
  double bearing = calculateBearing(user, target);

  // 2. Adjust for device heading (compass)
  double relativeAngle = bearing - heading;

  // 3. Calculate distance (capped to radar radius)
  double distance = calculateDistance(user, target);
  double normalizedDistance = min(distance / maxRadarRange, 1.0);

  // 4. Convert to screen coordinates
  double screenAngle = relativeAngle - (pi / 2); // Rotate so 0° = top
  double radius = normalizedDistance * (radarSize.width / 2);

  return Offset(
    cos(screenAngle) * radius,
    sin(screenAngle) * radius,
  );
}
```

### CRT Shader Implementation

Using Flutter's `FragmentProgram` for GPU-accelerated post-processing:

```glsl
// crt_effect.frag
#version 460 core

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Scanlines
    float scanline = sin(uv.y * 800.0) * 0.04;

    // Chromatic aberration
    float aberration = 0.002;
    vec4 color;
    color.r = texture(uTexture, uv + vec2(aberration, 0)).r;
    color.g = texture(uTexture, uv).g;
    color.b = texture(uTexture, uv - vec2(aberration, 0)).b;
    color.a = 1.0;

    // Apply scanline
    color.rgb -= scanline;

    // Vignette
    float vignette = 1.0 - smoothstep(0.5, 0.8, length(uv - 0.5));
    color.rgb *= vignette;

    fragColor = color;
}
```

### Performance Optimization

#### Frame Budget (16.6ms for 60fps)
- Sensor polling: <1ms (async, off main thread)
- Data processing: <2ms
- Paint call: <8ms
- Shader pass: <4ms
- Buffer: ~2ms

#### Optimization Techniques
1. **Dirty Region Tracking**: Only repaint changed areas when possible
2. **Object Pooling**: Reuse `Blip` objects instead of creating new ones
3. **Level of Detail**: Reduce blip count when frame rate drops
4. **Shader Caching**: Pre-compile shaders on first launch

```dart
class PerformanceMonitor {
  final Stopwatch _frameStopwatch = Stopwatch();
  int _slowFrameCount = 0;

  void onFrameStart() => _frameStopwatch.start();

  void onFrameEnd() {
    _frameStopwatch.stop();
    if (_frameStopwatch.elapsedMilliseconds > 16) {
      _slowFrameCount++;
      if (_slowFrameCount > 10) {
        _reduceQuality(); // Disable effects or reduce blips
      }
    }
    _frameStopwatch.reset();
  }
}
```

## Decisions

### Decision: Use CustomPainter over Stack/Positioned
**Rationale**: CustomPainter provides direct canvas access, essential for smooth sweep animation and efficient blip rendering. Stack/Positioned would create hundreds of widgets and be much slower.

**Alternatives Considered**:
- Stack + AnimatedPositioned: Too many widget rebuilds
- CustomPaint + RepaintBoundary: Good but shader application tricky
- Flame (game engine): Overkill, adds large dependency

### Decision: Sweep Direction Clockwise from Top
**Rationale**: Matches user expectation from movie and real radar systems. Top = forward/north creates intuitive mapping.

### Decision: Compass Smoothing with Kalman Filter
**Rationale**: Raw compass data is noisy, especially indoors. Kalman filter provides smooth heading changes while remaining responsive.

```dart
class CompassSmoother {
  double _estimate = 0;
  double _errorEstimate = 1;
  final double _errorMeasure = 0.5;
  final double _q = 0.1; // Process noise

  double filter(double measurement) {
    // Kalman filter implementation
    double kalmanGain = _errorEstimate / (_errorEstimate + _errorMeasure);
    _estimate = _estimate + kalmanGain * (measurement - _estimate);
    _errorEstimate = (1 - kalmanGain) * _errorEstimate + _q;
    return _estimate;
  }
}
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Low-end device performance | Poor UX, dropped frames | Implement quality tiers, disable effects |
| Compass inaccuracy indoors | Wrong blip positions | Show "low confidence" indicator, use relative mode |
| GPS drift | Jumping blip positions | Apply smoothing, require minimum accuracy |
| Battery drain | User complaints | Implement power modes, pause when screen off |

## Open Questions
1. Should we support landscape orientation? (Complexity vs. value)
2. What's the optimal radar range for urban vs. rural settings?
3. Should blips show actual signal value or just intensity?
