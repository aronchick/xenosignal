import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/signal_blip.dart';
import 'radar_painter.dart';

/// Animated radar display widget.
///
/// Renders a radar with a continuously rotating sweep line.
/// The sweep completes one full rotation every [sweepDuration] (default 3 seconds).
///
/// Example:
/// ```dart
/// RadarWidget(
///   size: 300,
///   sweepDuration: Duration(seconds: 3),
/// )
/// ```
class RadarWidget extends StatefulWidget {
  const RadarWidget({
    super.key,
    this.size,
    this.sweepDuration = const Duration(seconds: 3),
    this.theme = const RadarTheme(),
    this.running = true,
    this.blips = const [],
  });

  /// Size of the radar widget. If null, expands to fill available space.
  final double? size;

  /// Duration for one complete sweep rotation.
  final Duration sweepDuration;

  /// Visual theme configuration.
  final RadarTheme theme;

  /// Whether the sweep animation is running.
  final bool running;

  /// Signal blips to render on the radar.
  final List<SignalBlip> blips;

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _sweepCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );

    // Track sweep completions for blip fade
    _controller.addStatusListener(_onAnimationStatus);

    if (widget.running) {
      _controller.repeat();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _sweepCount++;
    }
  }

  @override
  void didUpdateWidget(RadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update duration if changed
    if (oldWidget.sweepDuration != widget.sweepDuration) {
      _controller.duration = widget.sweepDuration;
    }

    // Handle running state changes
    if (oldWidget.running != widget.running) {
      if (widget.running) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget radar = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RadarPainter(
            sweepAngle: _controller.value * 2 * math.pi,
            theme: widget.theme,
            blips: widget.blips,
            sweepCount: _sweepCount,
          ),
          size: widget.size != null ? Size.square(widget.size!) : Size.infinite,
        );
      },
    );

    if (widget.size != null) {
      radar = SizedBox.square(
        dimension: widget.size,
        child: radar,
      );
    }

    return radar;
  }
}

/// A radar widget that can be controlled externally.
///
/// Use this when you need to control the sweep angle directly,
/// for example when integrating with compass heading or
/// synchronizing with other animations.
class ControlledRadarWidget extends StatelessWidget {
  const ControlledRadarWidget({
    super.key,
    required this.sweepAngle,
    this.size,
    this.theme = const RadarTheme(),
    this.blips = const [],
    this.sweepCount = 0,
  });

  /// Current sweep angle in radians (0 = top, clockwise).
  final double sweepAngle;

  /// Size of the radar widget. If null, expands to fill available space.
  final double? size;

  /// Visual theme configuration.
  final RadarTheme theme;

  /// Signal blips to render on the radar.
  final List<SignalBlip> blips;

  /// Current sweep count for calculating blip fade.
  final int sweepCount;

  @override
  Widget build(BuildContext context) {
    Widget radar = CustomPaint(
      painter: RadarPainter(
        sweepAngle: sweepAngle,
        theme: theme,
        blips: blips,
        sweepCount: sweepCount,
      ),
      size: size != null ? Size.square(size!) : Size.infinite,
    );

    if (size != null) {
      radar = SizedBox.square(
        dimension: size,
        child: radar,
      );
    }

    return radar;
  }
}
