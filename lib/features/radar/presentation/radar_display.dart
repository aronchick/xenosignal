import 'package:flutter/material.dart';

import '../domain/signal_blip.dart';
import 'direction_arrow.dart';
import 'radar_painter.dart';
import 'radar_widget.dart';

/// Complete radar display with direction arrow overlay.
///
/// Combines the radar sweep animation with a directional arrow
/// that guides users toward better signal locations.
///
/// Example:
/// ```dart
/// RadarDisplay(
///   size: 300,
///   target: SignalTarget(
///     angle: math.pi / 4,
///     distance: 0.5,
///     signalStrength: 0.9,
///   ),
/// )
/// ```
class RadarDisplay extends StatelessWidget {
  const RadarDisplay({
    super.key,
    this.size,
    this.sweepDuration = const Duration(seconds: 3),
    this.theme = const RadarTheme(),
    this.running = true,
    this.blips = const [],
    this.target,
    this.arrowState = DirectionArrowState.unknown,
    this.showArrow = true,
    this.showDistance = true,
  });

  /// Size of the radar display. If null, expands to fill available space.
  final double? size;

  /// Duration for one complete sweep rotation.
  final Duration sweepDuration;

  /// Visual theme configuration.
  final RadarTheme theme;

  /// Whether the sweep animation is running.
  final bool running;

  /// Signal blips to render on the radar.
  final List<SignalBlip> blips;

  /// Target location with better signal for the direction arrow.
  final SignalTarget? target;

  /// State of the direction arrow.
  final DirectionArrowState arrowState;

  /// Whether to show the direction arrow overlay.
  final bool showArrow;

  /// Whether to show distance text below the arrow.
  final bool showDistance;

  @override
  Widget build(BuildContext context) {
    final radarWidget = RadarWidget(
      size: size,
      sweepDuration: sweepDuration,
      theme: theme,
      running: running,
      blips: blips,
    );

    if (!showArrow) {
      return radarWidget;
    }

    // Calculate arrow size relative to radar
    final arrowSize = (size ?? 300) * 0.25;

    return Stack(
      alignment: Alignment.center,
      children: [
        radarWidget,
        Positioned(
          bottom: (size ?? 300) * 0.15,
          child: DirectionArrow(
            target: target,
            state: arrowState,
            size: arrowSize,
            theme: theme,
            showDistance: showDistance,
            enabled: running,
          ),
        ),
      ],
    );
  }
}

/// A radar display that adapts its direction arrow based on signal data.
///
/// Automatically determines the arrow state from:
/// - Current signal strength
/// - Historical best signal location
/// - Distance to better signal
class SmartRadarDisplay extends StatelessWidget {
  const SmartRadarDisplay({
    super.key,
    this.size,
    this.sweepDuration = const Duration(seconds: 3),
    this.theme = const RadarTheme(),
    this.running = true,
    this.blips = const [],
    this.currentSignalStrength,
    this.bestKnownSignal,
    this.showArrow = true,
    this.showDistance = true,
    this.optimalThreshold = 0.05,
  });

  /// Size of the radar display.
  final double? size;

  /// Duration for one complete sweep rotation.
  final Duration sweepDuration;

  /// Visual theme configuration.
  final RadarTheme theme;

  /// Whether the sweep animation is running.
  final bool running;

  /// Signal blips to render on the radar.
  final List<SignalBlip> blips;

  /// Current signal strength (0-1), if known.
  final double? currentSignalStrength;

  /// Best known signal location, if available.
  final SignalTarget? bestKnownSignal;

  /// Whether to show the direction arrow.
  final bool showArrow;

  /// Whether to show distance text.
  final bool showDistance;

  /// Threshold for considering current position optimal.
  /// If current signal is within this much of best, show "optimal".
  final double optimalThreshold;

  DirectionArrowState _calculateArrowState() {
    // No historical data
    if (bestKnownSignal == null) {
      return DirectionArrowState.unknown;
    }

    // No current signal to compare
    if (currentSignalStrength == null) {
      return DirectionArrowState.pointing;
    }

    // Check if current signal is optimal (close to or better than best)
    final current = currentSignalStrength!;
    final best = bestKnownSignal!.signalStrength;

    if (current >= best - optimalThreshold) {
      return DirectionArrowState.optimal;
    }

    // Current is worse than best known - point to better signal
    return DirectionArrowState.pointing;
  }

  @override
  Widget build(BuildContext context) {
    return RadarDisplay(
      size: size,
      sweepDuration: sweepDuration,
      theme: theme,
      running: running,
      blips: blips,
      target: bestKnownSignal,
      arrowState: _calculateArrowState(),
      showArrow: showArrow,
      showDistance: showDistance,
    );
  }
}
