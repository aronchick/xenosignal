import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  });

  /// Size of the radar widget. If null, expands to fill available space.
  final double? size;

  /// Duration for one complete sweep rotation.
  final Duration sweepDuration;

  /// Visual theme configuration.
  final RadarTheme theme;

  /// Whether the sweep animation is running.
  final bool running;

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.sweepDuration,
    );

    if (widget.running) {
      _controller.repeat();
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
  });

  /// Current sweep angle in radians (0 = top, clockwise).
  final double sweepAngle;

  /// Size of the radar widget. If null, expands to fill available space.
  final double? size;

  /// Visual theme configuration.
  final RadarTheme theme;

  @override
  Widget build(BuildContext context) {
    Widget radar = CustomPaint(
      painter: RadarPainter(
        sweepAngle: sweepAngle,
        theme: theme,
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
