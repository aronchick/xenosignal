import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// CRT scanline effect overlay.
///
/// Renders horizontal scanlines over the child widget to simulate
/// a CRT monitor. This is a placeholder implementation using
/// CustomPaint; can be enhanced later with fragment shaders for
/// chromatic aberration and barrel distortion.
class CrtEffect extends StatelessWidget {
  const CrtEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.scanlineIntensity = 0.15,
    this.scanlineSpacing = 2.0,
  });

  /// The widget to render with CRT effects.
  final Widget child;

  /// Whether CRT effects are enabled.
  final bool enabled;

  /// Opacity of scanlines (0.0 to 1.0).
  final double scanlineIntensity;

  /// Spacing between scanlines in logical pixels.
  final double scanlineSpacing;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(
                intensity: scanlineIntensity,
                spacing: scanlineSpacing,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({
    required this.intensity,
    required this.spacing,
  });

  final double intensity;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = XenoColors.background.withValues(alpha: intensity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
        oldDelegate.spacing != spacing;
  }
}

/// Vignette effect overlay.
///
/// Darkens the corners of the screen to simulate CRT tube curvature.
class VignetteEffect extends StatelessWidget {
  const VignetteEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.intensity = 0.3,
  });

  final Widget child;
  final bool enabled;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    XenoColors.background.withValues(alpha: intensity),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Combined CRT effects widget.
///
/// Applies scanlines and vignette effects to simulate a CRT display.
/// Can be enhanced later with fragment shaders for advanced effects
/// like chromatic aberration and barrel distortion.
class CrtOverlay extends StatelessWidget {
  const CrtOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.scanlineIntensity = 0.15,
    this.vignetteIntensity = 0.3,
  });

  final Widget child;
  final bool enabled;
  final double scanlineIntensity;
  final double vignetteIntensity;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return VignetteEffect(
      enabled: enabled,
      intensity: vignetteIntensity,
      child: CrtEffect(
        enabled: enabled,
        scanlineIntensity: scanlineIntensity,
        child: child,
      ),
    );
  }
}
