# Heatmap History

Signal history recording, storage, and visualization—the "breadcrumb" system that remembers where signals were strong.

## Requirements

### Requirement: Location-Signal Recording
The system SHALL record signal readings associated with geographic coordinates to build a personal signal map.

#### Scenario: Automatic recording
- **WHEN** the app is active (foreground or background with permission)
- **THEN** record signal readings every 5 seconds (configurable)
- **AND** associate each reading with current GPS coordinates
- **AND** store readings in local database

#### Scenario: Manual pin drop
- **WHEN** user taps "Mark Location" button
- **THEN** record current signal reading with enhanced metadata
- **AND** allow user to add a label (e.g., "Good spot by window")
- **AND** visually distinguish manual pins from automatic readings

#### Scenario: Location accuracy threshold
- **WHEN** GPS accuracy is below threshold (>50m uncertainty)
- **THEN** still record the reading but flag as low-confidence
- **AND** use larger uncertainty radius in visualizations
- **AND** avoid overwriting high-confidence readings

### Requirement: Heatmap Visualization
The system SHALL visualize recorded signal data as a heatmap overlay showing signal strength by location.

#### Scenario: Radar-relative heatmap
- **WHEN** viewing the radar screen
- **THEN** display nearby historical readings as faded blips
- **AND** position blips relative to current location and heading
- **AND** color-code by signal strength (bright green = strong, dim = weak)

#### Scenario: Map-based heatmap
- **WHEN** user switches to map view
- **THEN** display OpenStreetMap with signal heatmap overlay
- **AND** apply Aliens-themed dark/green map tiles
- **AND** show heat gradients for signal strength zones

#### Scenario: Empty area indication
- **WHEN** an area has no recorded data
- **THEN** display as "UNCHARTED" or dark/empty
- **AND** distinguish from "recorded but weak signal" areas

### Requirement: Temporal Data Management
The system SHALL manage historical data with configurable retention and aggregation policies.

#### Scenario: Data aging
- **WHEN** readings are older than retention period (default: 30 days)
- **THEN** automatically delete or archive the readings
- **AND** preserve manually-pinned locations indefinitely (unless user deletes)
- **AND** show "data freshness" indicator on heatmap

#### Scenario: Data aggregation
- **WHEN** multiple readings exist for same approximate location
- **THEN** aggregate into a single representative value
- **AND** use weighted average favoring recent readings
- **AND** preserve peak value as separate "best recorded" metric

#### Scenario: Storage limits
- **WHEN** database exceeds size threshold (default: 50MB)
- **THEN** prompt user to prune old data
- **AND** offer selective deletion by area or time range
- **AND** never delete without user confirmation

### Requirement: Best Signal Navigation
The system SHALL guide users toward locations with historically strong signals.

#### Scenario: Nearby strong signal
- **WHEN** a location within 200m has significantly better recorded signal
- **THEN** display directional indicator toward that location
- **AND** show estimated distance and signal improvement potential
- **AND** update direction as user moves

#### Scenario: Path suggestion
- **WHEN** user requests "Find Signal" mode
- **THEN** analyze recorded data for optimal nearby location
- **AND** provide turn-by-turn style guidance ("Signal stronger to your left")
- **AND** update recommendations based on current readings

#### Scenario: Stale data warning
- **WHEN** navigating to a location with data older than 7 days
- **THEN** display "Data may be outdated" warning
- **AND** prioritize recent readings in navigation suggestions
- **AND** update stale data automatically when user visits location

### Requirement: Data Export
The system SHALL allow users to export their signal data for backup or analysis.

#### Scenario: Export to file
- **WHEN** user selects "Export Data" option
- **THEN** generate JSON or CSV file with all readings
- **AND** include GPS coordinates, timestamps, and signal values
- **AND** offer sharing via system share sheet

#### Scenario: Import data
- **WHEN** user selects "Import Data" option
- **THEN** parse and validate the import file
- **AND** merge with existing data (avoiding duplicates)
- **AND** show import summary (records added, skipped, errors)

## Data Structures

### SignalMapPoint
```dart
class SignalMapPoint {
  final String id;
  final GeoPosition position;
  final double radiusMeters; // Uncertainty
  final SignalReading reading;
  final DateTime recordedAt;
  final bool isManualPin;
  final String? label;
}
```

### HeatmapTile
```dart
class HeatmapTile {
  final GeoBounds bounds;
  final double avgSignalQuality;
  final double peakSignalQuality;
  final int sampleCount;
  final DateTime lastUpdated;
}
```

## Non-Functional Requirements

### Storage
- Database SHALL support 1 million readings without performance degradation
- Query for nearby readings SHALL complete in < 100ms
- Heatmap rendering SHALL complete in < 500ms for visible area

### Privacy
- All data SHALL remain on-device by default
- Export files SHALL be clearly marked as containing location data
- No data SHALL be transmitted without explicit user action
