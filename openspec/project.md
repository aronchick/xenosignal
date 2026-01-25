# Project Context

## Purpose
**XenoSignal** is a cross-platform mobile application that tracks WiFi and cellular signal strength with a retro-futuristic UI inspired by the M314 Motion Tracker from *Aliens*. The app guides users to better connectivity using directional mechanics, records signal history, and visualizes coverage as heatmaps—all wrapped in an immersive "lo-fi industrial military tech" aesthetic.

### Core Value Proposition
- **Find Signal Fast**: Arrow-based navigation pointing toward strongest signals
- **Remember Where It Was Good**: Historical tracking of signal strength by location
- **Make It Fun**: Transform a utility into an engaging, game-like experience

## Tech Stack
- **Framework**: Flutter (Dart) - Single codebase, excellent custom 2D rendering for radar/CRT effects
- **State Management**: Riverpod - Maintainable, testable, reactive
- **Local Database**: Drift (SQLite) - For signal heatmaps, location history
- **Maps**: flutter_map (OpenStreetMap) with custom dark/green monochrome tiles
- **Sensors**:
  - `compass_plus` - Device orientation
  - `connectivity_plus` - Network state
  - Platform channels for raw signal strength (dBm)
- **Audio**: `just_audio` or `audioplayers` for Geiger-counter sound effects
- **Haptics**: `flutter_vibrate` for tactile feedback

## Project Conventions

### Code Style
- **Dart Analysis**: Use `flutter_lints` with strict mode
- **Naming**:
  - Files: `snake_case.dart`
  - Classes: `PascalCase`
  - Variables/functions: `camelCase`
  - Constants: `kCamelCase` or `SCREAMING_SNAKE_CASE`
- **Imports**: Relative within `lib/`, absolute for packages
- **Comments**: Prefer self-documenting code; use `///` for public API docs

### Architecture Patterns
- **Clean Architecture** with feature-first organization:
  ```
  lib/
  ├── core/           # Shared utilities, theme, constants
  ├── features/       # Feature modules (radar, heatmap, settings)
  │   └── [feature]/
  │       ├── data/       # Repositories, data sources
  │       ├── domain/     # Entities, use cases
  │       └── presentation/ # Widgets, providers
  └── main.dart
  ```
- **Repository Pattern**: Abstract data sources behind interfaces
- **Provider Pattern**: Use Riverpod for dependency injection and state

### Testing Strategy
- **Unit Tests**: All services, repositories, and business logic
- **Widget Tests**: Key UI components (radar, signal display)
- **Integration Tests**: Critical user flows (signal detection, heatmap recording)
- **Golden Tests**: For custom painters (radar sweep, CRT effects)
- **Platform Testing**: Manual testing on both iOS and Android for sensor behavior

### Git Workflow
- **Branching**: `main` (stable), `develop` (integration), `feature/*`, `fix/*`
- **Commits**: Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- **PRs**: Required for all changes to `main`; squash merge preferred

## Domain Context

### Signal Measurement
- **Android**: Direct access to dBm via `TelephonyManager` and `WifiManager`
- **iOS**: Apple restricts raw signal data; use derived metrics:
  - Ping latency to reliable servers (1.1.1.1, 8.8.8.8)
  - Connection quality indicators from `NEHotspotNetwork`
  - Signal bars approximation (when available)

### Signal Strength Ranges (dBm Reference)
| Quality | WiFi (dBm) | Cellular (dBm) | UI Label |
|---------|------------|----------------|----------|
| Excellent | > -50 | > -70 | "CRITICAL HIT" |
| Good | -50 to -60 | -70 to -85 | "FULLY LEVELED" |
| Fair | -60 to -70 | -85 to -100 | "LOW HP" |
| Poor | < -70 | < -100 | "GAME OVER" |

### The "Aliens" Aesthetic
- **Color**: Amber/Green (#39FF14) on pure black (#000000)
- **Effects**: CRT scanlines, chromatic aberration, phosphor glow
- **Typography**: Monospace terminal fonts (VT323, Share Tech Mono)
- **Audio**: Geiger-counter clicks, escalating ping frequency
- **Motion**: 60fps radar sweep, smooth blip animations

## Important Constraints

### Platform Limitations
1. **iOS Signal Restrictions**: Cannot read raw dBm; must use proxy metrics
2. **Background Location**: Requires proper permissions and battery optimization
3. **Audio in Background**: Platform-specific handling for continuous feedback

### Performance Requirements
- **Radar Animation**: Consistent 60fps on mid-range devices
- **Battery**: Background tracking must be battery-efficient (< 5% per hour)
- **Storage**: Heatmap data should be pruned after 30 days by default

### Privacy & Permissions
- Location data stays on-device by default
- Clear permission explanations for:
  - Precise location (for heatmap)
  - Background location (for continuous tracking)
  - Network state access

## External Dependencies

### Required APIs/Services
- **None required** - App functions fully offline
- **Optional**: Anonymous ping targets for iOS signal approximation:
  - Cloudflare: 1.1.1.1
  - Google: 8.8.8.8
  - Quad9: 9.9.9.9

### Third-Party Assets
- **Fonts**: VT323 (Google Fonts, OFL license)
- **Sound Effects**: Custom or royalty-free Geiger counter samples
- **No backend required** - All data local to device
