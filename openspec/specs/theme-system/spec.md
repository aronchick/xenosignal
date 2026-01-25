# Theme System

The visual identity of XenoSignal—CRT effects, monochrome phosphor glow, and retro-futuristic military aesthetic inspired by the M314 Motion Tracker.

## Requirements

### Requirement: Base Color Scheme
The system SHALL use a strict monochrome amber/green-on-black color palette as the default theme.

#### Scenario: Primary colors
- **WHEN** rendering any UI element
- **THEN** use the following palette:
  - Primary: #39FF14 (phosphor green)
  - Background: #000000 (pure black)
  - Secondary: #00FF00 (classic green, for accents)
  - Warning: #FFAA00 (amber, for alerts)
  - Danger: #FF3300 (red-orange, for critical states)
- **AND** maintain high contrast ratios (>7:1)

#### Scenario: Glow effects
- **WHEN** rendering text or UI elements
- **THEN** apply subtle outer glow matching element color
- **AND** glow radius proportional to element importance
- **AND** glow intensity adjustable in settings

### Requirement: CRT Shader Effects
The system SHALL simulate CRT monitor artifacts for authentic retro aesthetic.

#### Scenario: Scanline overlay
- **WHEN** CRT effects are enabled (default: on)
- **THEN** render horizontal scanlines across entire display
- **AND** scanlines should be subtle (10-20% opacity)
- **AND** scanlines animate subtly (slight flicker)

#### Scenario: Chromatic aberration
- **WHEN** CRT effects are enabled
- **THEN** apply subtle RGB color separation at edges
- **AND** effect intensity increases toward screen edges
- **AND** creates authentic "tube TV" look

#### Scenario: Screen curvature
- **WHEN** advanced CRT mode is enabled
- **THEN** apply barrel distortion to simulate curved CRT glass
- **AND** vignette (darken) corners slightly
- **AND** add subtle reflection/glare overlay

#### Scenario: Performance mode
- **WHEN** device performance is constrained
- **OR** user disables effects
- **THEN** disable all shader effects
- **AND** maintain color scheme and typography
- **AND** ensure full functionality without effects

### Requirement: Typography
The system SHALL use monospace, terminal-style fonts throughout.

#### Scenario: Primary font
- **WHEN** displaying any text
- **THEN** use VT323 or Share Tech Mono as primary font
- **AND** fallback to system monospace if unavailable
- **AND** use consistent sizing scale (12, 14, 18, 24, 32px)

#### Scenario: Numeric displays
- **WHEN** displaying signal strength or measurements
- **THEN** use fixed-width numeric characters
- **AND** align decimal points for readability
- **AND** use "LED segment" style for large readings

#### Scenario: Labels and headers
- **WHEN** displaying UI labels
- **THEN** use ALL CAPS for headers
- **AND** use sentence case for descriptions
- **AND** apply letter-spacing for headers (tracking)

### Requirement: Animation Standards
The system SHALL use consistent animation timing and easing throughout.

#### Scenario: Transitions
- **WHEN** transitioning between screens or states
- **THEN** use 200-300ms duration
- **AND** use ease-out easing for entrances
- **AND** use ease-in for exits
- **AND** maintain 60fps during animations

#### Scenario: Continuous animations
- **WHEN** rendering radar sweep or pulsing elements
- **THEN** use linear easing for mechanical movements
- **AND** use sine easing for organic pulses
- **AND** ensure seamless looping

#### Scenario: Interactive feedback
- **WHEN** user taps interactive element
- **THEN** provide immediate visual feedback (<100ms)
- **AND** use scale or glow change for press state
- **AND** return to rest state on release

### Requirement: Iconography
The system SHALL use custom icons consistent with the military-tech aesthetic.

#### Scenario: Icon style
- **WHEN** displaying icons
- **THEN** use outlined/stroke style (not filled)
- **AND** stroke width consistent (2px at 24px size)
- **AND** geometric/angular shapes preferred
- **AND** all icons same phosphor green color

#### Scenario: Signal strength icons
- **WHEN** displaying signal strength visually
- **THEN** use custom bar/arc indicators
- **NOT** standard WiFi or cellular icons
- **AND** animate bars to show activity

#### Scenario: Status indicators
- **WHEN** displaying system status
- **THEN** use circular status dots with glow
- **AND** pulsing animation for active states
- **AND** static for stable states

### Requirement: Layout System
The system SHALL use consistent spacing, alignment, and component sizing.

#### Scenario: Grid system
- **WHEN** laying out UI elements
- **THEN** use 8px base grid unit
- **AND** spacing multipliers: 1x (8px), 2x (16px), 3x (24px), 4x (32px)
- **AND** maintain alignment to grid

#### Scenario: Component sizing
- **WHEN** sizing interactive elements
- **THEN** minimum touch target: 44x44px (iOS) / 48x48px (Android)
- **AND** buttons: height 48px, padding 16px horizontal
- **AND** cards: padding 16px, border-radius 4px (subtle, not rounded)

#### Scenario: Safe areas
- **WHEN** rendering on devices with notches or rounded corners
- **THEN** respect system safe area insets
- **AND** radar display may extend into safe area (immersive)
- **AND** critical UI stays within safe bounds

### Requirement: Theme Variants
The system SHALL support alternative theme options while maintaining aesthetic coherence.

#### Scenario: Amber variant
- **WHEN** user selects "Amber" theme
- **THEN** replace green (#39FF14) with amber (#FFAA00)
- **AND** maintain all other design patterns
- **AND** evokes original Alien motion tracker color

#### Scenario: High contrast mode
- **WHEN** user enables high contrast
- **OR** system accessibility setting is active
- **THEN** increase contrast ratios
- **AND** brighten primary colors
- **AND** darken backgrounds further if needed

#### Scenario: Light mode (optional)
- **WHEN** user specifically requests light mode
- **THEN** invert to dark text on light background
- **AND** disable CRT effects (incompatible)
- **AND** maintain typography and iconography

### Requirement: Dark Mode Integration
The system SHALL integrate with system dark mode settings.

#### Scenario: System dark mode
- **WHEN** system dark mode is enabled
- **THEN** XenoSignal displays normally (already dark)
- **AND** no visual change needed

#### Scenario: System light mode
- **WHEN** system light mode is enabled
- **THEN** XenoSignal maintains dark theme (default override)
- **OR** follows system if user preference is "Auto"
- **AND** respect user's explicit theme choice

## Visual Specifications

### Colors (Hex Values)
```
Primary Green:    #39FF14 (phosphor)
Classic Green:    #00FF00 (accent)
Background:       #000000 (pure black)
Surface Dark:     #0A0A0A (card backgrounds)
Surface Mid:      #1A1A1A (elevated surfaces)
Amber Warning:    #FFAA00
Danger Red:       #FF3300
Text Primary:     #39FF14
Text Secondary:   #00AA00 (dimmed)
Text Disabled:    #004400 (very dim)
```

### Typography Scale
```
Display:     32px, weight 400, tracking +0.02em
Title:       24px, weight 400, tracking +0.01em
Body Large:  18px, weight 400, tracking 0
Body:        14px, weight 400, tracking 0
Caption:     12px, weight 400, tracking +0.01em
Overline:    10px, weight 500, tracking +0.05em, ALL CAPS
```

### Shader Parameters (Reference)
```glsl
// Scanline intensity
const float scanlineIntensity = 0.15;
const float scanlineFrequency = 800.0; // lines per screen height

// Chromatic aberration
const float chromaticOffset = 0.002; // % of screen width

// Vignette
const float vignetteIntensity = 0.3;
const float vignetteRadius = 0.8;
```

## Non-Functional Requirements

### Performance
- All theme rendering SHALL add < 2ms to frame time
- Shader effects SHALL be GPU-accelerated
- Theme switching SHALL complete in < 100ms

### Consistency
- All screens SHALL use same theme tokens (no hardcoded colors)
- Custom components SHALL extend base theme classes
- Third-party components SHALL be styled to match
