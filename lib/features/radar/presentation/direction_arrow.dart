import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/typography.dart';
import 'radar_painter.dart';

/// Data representing a target location with better signal.
class SignalTarget {
  const SignalTarget({
    required this.angle,
    required this.distance,
    required this.signalStrength,
    this.distanceMeters,
  });

  /// Direction to the target in radians (0 = north/up, clockwise).
  final double angle;

  /// Relative distance from 0 (here) to 1 (far away).
  /// Used for pulse speed calculation.
  final double distance;

  /// Signal strength at target location (0-1, where 1 is excellent).
  final double signalStrength;

  /// Actual distance in meters, if available.
  final double? distanceMeters;
}

/// State of the direction arrow.
enum DirectionArrowState {
  /// Pointing toward a better signal location.
  pointing,

  /// Current position is optimal (best known signal).
  optimal,

  /// No historical data available to guide.
  unknown,
}

/// Directional arrow widget that guides users toward better signal.
///
/// Features:
/// - Rotates to point toward the strongest known signal location
/// - Pulse animation speeds up as user approaches the target
/// - Shows "POSITION OPTIMAL" when current location is best
///
/// Example:
/// ```dart
/// DirectionArrow(
///   target: SignalTarget(
///     angle: math.pi / 4, // Northeast
///     distance: 0.5,
///     signalStrength: 0.9,
///     distanceMeters: 45,
///   ),
/// )
/// ```
class DirectionArrow extends StatefulWidget {
  const DirectionArrow({
    super.key,
    this.target,
    this.state = DirectionArrowState.unknown,
    this.size = 80,
    this.theme = const RadarTheme(),
    this.showDistance = true,
    this.enabled = true,
  });

  /// Target location with better signal. Null when state is optimal/unknown.
  final SignalTarget? target;

  /// Current state of the arrow.
  final DirectionArrowState state;

  /// Size of the arrow widget.
  final double size;

  /// Visual theme configuration.
  final RadarTheme theme;

  /// Whether to show distance text below the arrow.
  final bool showDistance;

  /// Whether the arrow animation is enabled.
  final bool enabled;

  @override
  State<DirectionArrow> createState() => _DirectionArrowState();
}

class _DirectionArrowState extends State<DirectionArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _calculatePulseDuration(),
    );

    if (widget.enabled && widget.state == DirectionArrowState.pointing) {
      _pulseController.repeat(reverse: true);
    }
  }

  Duration _calculatePulseDuration() {
    if (widget.target == null) {
      return const Duration(milliseconds: 2000);
    }

    // Pulse faster as distance decreases
    // distance 1.0 = 2000ms, distance 0.0 = 300ms
    final distance = widget.target!.distance.clamp(0.0, 1.0);
    final durationMs = 300 + (1700 * distance).round();
    return Duration(milliseconds: durationMs);
  }

  @override
  void didUpdateWidget(DirectionArrow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update pulse duration if distance changed
    final newDuration = _calculatePulseDuration();
    if (_pulseController.duration != newDuration) {
      _pulseController.duration = newDuration;
    }

    // Handle state changes
    if (widget.state == DirectionArrowState.pointing && widget.enabled) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildArrowContent(),
        ),
        if (widget.showDistance && widget.state == DirectionArrowState.pointing)
          _buildDistanceLabel(),
        if (widget.state == DirectionArrowState.optimal) _buildOptimalLabel(),
        if (widget.state == DirectionArrowState.unknown) _buildUnknownLabel(),
      ],
    );
  }

  Widget _buildArrowContent() {
    switch (widget.state) {
      case DirectionArrowState.pointing:
        return _buildPointingArrow();
      case DirectionArrowState.optimal:
        return _buildOptimalIndicator();
      case DirectionArrowState.unknown:
        return _buildUnknownIndicator();
    }
  }

  Widget _buildPointingArrow() {
    final target = widget.target;
    if (target == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Pulse scale from 0.85 to 1.0
        final scale = 0.85 + (_pulseController.value * 0.15);
        // Pulse glow intensity
        final glowIntensity = 0.3 + (_pulseController.value * 0.4);

        return Transform.rotate(
          angle: target.angle,
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _ArrowPainter(
                color: widget.theme.primaryColor,
                glowIntensity: glowIntensity,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptimalIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _OptimalPainter(
            color: widget.theme.primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildUnknownIndicator() {
    return CustomPaint(
      size: Size.square(widget.size),
      painter: _UnknownPainter(
        color: widget.theme.primaryColor.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildDistanceLabel() {
    final distanceText = _formatDistance();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        distanceText,
        style: XenoTypography.caption(color: widget.theme.primaryColor),
      ),
    );
  }

  String _formatDistance() {
    final meters = widget.target?.distanceMeters;
    if (meters == null) return 'TRACKING';
    if (meters < 10) return '< 10M';
    if (meters < 100) return '${meters.round()}M';
    return '${(meters / 1000).toStringAsFixed(1)}KM';
  }

  Widget _buildOptimalLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'POSITION OPTIMAL',
        style: XenoTypography.overline(color: widget.theme.primaryColor),
      ),
    );
  }

  Widget _buildUnknownLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'SCANNING...',
        style: XenoTypography.overline(
          color: widget.theme.primaryColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Paints a directional arrow pointing up (to be rotated).
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.color,
    required this.glowIntensity,
  });

  final Color color;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arrowHeight = size.height * 0.7;
    final arrowWidth = size.width * 0.5;

    // Arrow points (pointing up)
    final tip = Offset(center.dx, center.dy - arrowHeight / 2);
    final leftBase = Offset(center.dx - arrowWidth / 2, center.dy + arrowHeight / 3);
    final rightBase = Offset(center.dx + arrowWidth / 2, center.dy + arrowHeight / 3);
    final innerLeft = Offset(center.dx - arrowWidth / 6, center.dy + arrowHeight / 6);
    final innerRight = Offset(center.dx + arrowWidth / 6, center.dy + arrowHeight / 6);
    final tail = Offset(center.dx, center.dy + arrowHeight / 2);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftBase.dx, leftBase.dy)
      ..lineTo(innerLeft.dx, innerLeft.dy)
      ..lineTo(tail.dx, tail.dy)
      ..lineTo(innerRight.dx, innerRight.dy)
      ..lineTo(rightBase.dx, rightBase.dy)
      ..close();

    // Draw glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowIntensity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(path, glowPaint);

    // Draw arrow fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Draw arrow stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}

/// Paints the "position optimal" indicator (checkmark in circle).
class _OptimalPainter extends CustomPainter {
  _OptimalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.7;

    // Draw outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius * 1.2, glowPaint);

    // Draw outer circle
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw checkmark
    final checkPath = Path();
    final checkStart = Offset(center.dx - radius * 0.35, center.dy);
    final checkMid = Offset(center.dx - radius * 0.05, center.dy + radius * 0.3);
    final checkEnd = Offset(center.dx + radius * 0.4, center.dy - radius * 0.25);

    checkPath.moveTo(checkStart.dx, checkStart.dy);
    checkPath.lineTo(checkMid.dx, checkMid.dy);
    checkPath.lineTo(checkEnd.dx, checkEnd.dy);

    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(_OptimalPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Paints the "unknown/scanning" indicator (question mark or radar sweep).
class _UnknownPainter extends CustomPainter {
  _UnknownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.6;

    // Draw dashed circle
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw as dashed circle (8 segments)
    const segments = 8;
    const gapAngle = math.pi / 16;

    for (int i = 0; i < segments; i++) {
      final startAngle = (i * 2 * math.pi / segments) + gapAngle;
      final sweepAngle = (2 * math.pi / segments) - (2 * gapAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        circlePaint,
      );
    }

    // Draw question mark
    final fontSize = radius * 0.9;
    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_UnknownPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
