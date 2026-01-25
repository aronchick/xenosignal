# Audio & Haptic Feedback

The sensory feedback system that makes XenoSignal feel like the M314 Motion Tracker—Geiger counter clicks, tension-building pings, and tactile pulses.

## Requirements

### Requirement: Geiger Counter Audio
The system SHALL produce audio feedback that mimics a Geiger counter, with click frequency proportional to signal strength.

#### Scenario: Strong signal audio
- **WHEN** signal quality is excellent (>80%)
- **THEN** produce rapid clicking (8-12 clicks per second)
- **AND** clicks have sharp, crisp tone
- **AND** volume is consistent

#### Scenario: Weak signal audio
- **WHEN** signal quality is poor (<30%)
- **THEN** produce slow, sparse clicking (0.5-1 clicks per second)
- **AND** clicks may have slight static/noise overlay
- **AND** create tension through silence between clicks

#### Scenario: Signal improving
- **WHEN** signal strength increases over 3+ seconds
- **THEN** gradually increase click frequency
- **AND** add subtle pitch increase to indicate improvement
- **AND** transition smoothly (no jarring changes)

#### Scenario: Signal degrading
- **WHEN** signal strength decreases over 3+ seconds
- **THEN** gradually decrease click frequency
- **AND** add subtle pitch decrease
- **AND** at critical low levels, add warning undertone

### Requirement: Proximity Ping
The system SHALL produce a distinct "ping" sound when approaching a known strong signal location.

#### Scenario: Approaching target
- **WHEN** user moves toward a location with strong recorded signal
- **THEN** produce periodic ping sounds
- **AND** ping frequency increases as distance decreases
- **AND** final "arrival" ping plays when within 10m

#### Scenario: Ping customization
- **WHEN** user configures ping settings
- **THEN** allow selection from multiple ping sound profiles
- **AND** allow volume adjustment independent of clicks
- **AND** allow disable of ping while keeping clicks

### Requirement: Haptic Feedback
The system SHALL provide haptic (vibration) feedback that mirrors the audio cues for users who prefer silent operation.

#### Scenario: Haptic click pattern
- **WHEN** haptic mode is enabled
- **THEN** produce short vibration pulses matching click frequency
- **AND** pulse intensity corresponds to signal strength
- **AND** use device's haptic engine for crisp feedback (not motor vibration)

#### Scenario: Haptic-only mode
- **WHEN** user enables "Silent Mode"
- **THEN** disable all audio output
- **AND** continue haptic feedback at enhanced intensity
- **AND** useful for stealth operation or hearing-impaired users

#### Scenario: Haptic navigation
- **WHEN** direction arrow indicates better signal direction
- **AND** user rotates device toward that direction
- **THEN** produce confirmation haptic pattern
- **AND** distinct "on target" haptic when aligned

### Requirement: Audio Session Management
The system SHALL properly manage audio sessions to coexist with other apps and system audio.

#### Scenario: Background audio
- **WHEN** user is playing music or podcast
- **THEN** duck (lower volume of) other audio during pings
- **OR** mix XenoSignal audio with other audio (configurable)
- **AND** never fully interrupt other audio playback

#### Scenario: Phone call
- **WHEN** phone call is active
- **THEN** automatically mute all XenoSignal audio
- **AND** continue haptic feedback if enabled
- **AND** resume audio when call ends

#### Scenario: Do Not Disturb
- **WHEN** system Do Not Disturb is active
- **THEN** respect system setting (mute audio)
- **AND** continue haptic if allowed by system
- **AND** log events for later review

### Requirement: Sound Customization
The system SHALL allow users to customize the audio experience.

#### Scenario: Volume control
- **WHEN** user adjusts app volume
- **THEN** apply to all app sounds
- **AND** persist setting across sessions
- **AND** show volume indicator in app

#### Scenario: Sound theme selection
- **WHEN** user browses sound themes
- **THEN** offer multiple audio profiles:
  - "Classic M314" (movie-accurate)
  - "Modern Scanner" (cleaner digital)
  - "Retro Synth" (80s synthesizer)
  - "Minimal" (subtle clicks only)
- **AND** preview sounds before selection

#### Scenario: Custom sounds (future)
- **WHEN** user imports custom audio files
- **THEN** validate file format (WAV, MP3, AAC)
- **AND** adjust timing to match click frequency requirements
- **AND** allow separate customization of click, ping, and alert sounds

### Requirement: Alert Sounds
The system SHALL produce distinct alert sounds for significant events.

#### Scenario: Signal found alert
- **WHEN** signal improves from poor to good while searching
- **THEN** play triumphant "signal acquired" sound
- **AND** accompany with strong haptic burst
- **AND** don't repeat within 30 seconds (avoid spam)

#### Scenario: Signal lost alert
- **WHEN** signal drops from good to poor/none
- **THEN** play warning "signal lost" sound
- **AND** accompany with distinct haptic pattern
- **AND** optionally repeat at intervals if condition persists

#### Scenario: Destination reached
- **WHEN** user arrives at navigated strong-signal location
- **THEN** play completion/success sound
- **AND** display "OBJECTIVE REACHED" visual
- **AND** transition to normal monitoring mode

## Audio Specifications

### Click Sound
- Duration: 20-50ms
- Frequency: 2-4kHz primary with harmonics
- Attack: <5ms (sharp onset)
- Release: 15-30ms (slight tail)

### Ping Sound
- Duration: 100-200ms
- Frequency: 1kHz fundamental, slight pitch sweep up
- Reverb: Slight metallic echo
- Inspired by: Submarine sonar ping

### Alert Sounds
- Duration: 300-800ms
- Layered tones for richness
- Distinct from clicks/pings to ensure recognition

## Non-Functional Requirements

### Latency
- Audio SHALL play within 50ms of signal reading
- Haptic SHALL fire within 30ms of audio cue

### Battery
- Audio processing SHALL add < 2% battery drain per hour
- Haptic SHALL use efficient patterns to minimize motor drain

### Accessibility
- All audio information SHALL have visual equivalent
- Haptic patterns SHALL be distinguishable for different events
- Volume SHALL respect system accessibility settings
