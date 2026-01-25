# Radar Display

The primary interface for XenoSignal—a real-time signal visualization modeled after the M314 Motion Tracker from *Aliens*.

## Requirements

### Requirement: Radar Sweep Animation
The radar SHALL display a continuously rotating sweep line that completes a full rotation every 2-4 seconds (configurable), rendering at 60fps on supported devices.

#### Scenario: Normal operation
- **WHEN** the app is in foreground
- **AND** the radar screen is active
- **THEN** the sweep line rotates clockwise at constant speed
- **AND** frame rate remains stable at 60fps

#### Scenario: Low power mode
- **WHEN** device battery is below 20%
- **OR** user enables power saver
- **THEN** sweep animation reduces to 30fps
- **AND** rotation speed remains constant (not perceived as slower)

### Requirement: Signal Blip Display
The radar SHALL display "blips" representing signal strength readings, positioned relative to the user's location and device orientation.

#### Scenario: Current signal strength
- **WHEN** a signal reading is obtained
- **THEN** a blip appears at the center of the radar
- **AND** blip intensity (brightness/size) corresponds to signal strength
- **AND** blip fades over 3-5 sweep cycles

#### Scenario: Historical signal direction
- **WHEN** a stronger signal was recorded at a nearby location
- **THEN** a blip appears in the direction of that location
- **AND** blip distance from center indicates relative proximity
- **AND** blip intensity indicates the strength of the historical reading

### Requirement: Compass Integration
The radar display SHALL rotate based on device compass heading so that "up" on screen corresponds to the direction the device is facing.

#### Scenario: Device rotation
- **WHEN** the user physically rotates the device
- **THEN** the radar display rotates inversely
- **AND** blip positions remain fixed relative to real-world coordinates
- **AND** rotation is smooth with < 100ms latency

#### Scenario: Compass unavailable
- **WHEN** compass data is unavailable or unreliable
- **THEN** the radar locks to a fixed orientation (north up)
- **AND** a "COMPASS OFFLINE" indicator is displayed
- **AND** directional features degrade gracefully

### Requirement: Numeric Signal Display
The radar SHALL display current signal strength as a numeric value in the Aliens aesthetic (dBm or quality percentage).

#### Scenario: WiFi signal display
- **WHEN** connected to WiFi
- **THEN** display WiFi signal strength in dBm (Android) or quality % (iOS)
- **AND** display network SSID
- **AND** use game-themed quality labels ("CRITICAL HIT", "LOW HP", etc.)

#### Scenario: Cellular signal display
- **WHEN** cellular data is active
- **THEN** display cellular signal strength in dBm (Android) or quality % (iOS)
- **AND** display carrier name and connection type (5G, LTE, 3G)
- **AND** use game-themed quality labels

#### Scenario: Dual display mode
- **WHEN** both WiFi and cellular are available
- **THEN** display both readings in split-screen or tabbed format
- **AND** allow user to select primary display

### Requirement: Direction Arrow
The radar SHALL display a directional arrow pointing toward the strongest known signal location within a configurable radius.

#### Scenario: Strong signal nearby
- **WHEN** a location with better signal is recorded within 100m
- **THEN** display an arrow pointing toward that location
- **AND** arrow pulses faster as user approaches the target
- **AND** distance estimate is shown (if available)

#### Scenario: No better signal known
- **WHEN** current location has the best recorded signal
- **OR** no historical data exists
- **THEN** display "POSITION OPTIMAL" or similar indicator
- **AND** arrow is hidden or shows a "stay here" state

#### Scenario: Multiple strong signals
- **WHEN** multiple locations with similar strong signals exist
- **THEN** point toward the nearest one
- **OR** show multiple arrows with intensity indicating strength

## Non-Functional Requirements

### Performance
- Radar animation SHALL maintain 60fps on devices from 2020 or newer
- Memory usage SHALL not exceed 100MB for the radar view
- GPU usage SHALL be optimized to prevent thermal throttling

### Accessibility
- High-contrast mode SHALL be available for visibility
- Screen reader SHALL announce signal strength changes
- Haptic feedback SHALL accompany visual blips (optional)
