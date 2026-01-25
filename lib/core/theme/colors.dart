import 'package:flutter/material.dart';

/// XenoSignal color palette - phosphor green/amber on black.
///
/// Inspired by the M314 Motion Tracker from Aliens. All UI elements
/// use this strict monochrome palette for authentic retro-futuristic feel.
abstract final class XenoColors {
  // Primary colors
  static const Color primaryGreen = Color(0xFF39FF14); // Phosphor green
  static const Color classicGreen = Color(0xFF00FF00); // Accent green
  static const Color amber = Color(0xFFFFAA00); // Warning/alternate theme
  static const Color danger = Color(0xFFFF3300); // Critical states

  // Background colors
  static const Color background = Color(0xFF000000); // Pure black
  static const Color surfaceDark = Color(0xFF0A0A0A); // Card backgrounds
  static const Color surfaceMid = Color(0xFF1A1A1A); // Elevated surfaces

  // Text colors (green theme)
  static const Color textPrimary = primaryGreen;
  static const Color textSecondary = Color(0xFF00AA00); // Dimmed
  static const Color textDisabled = Color(0xFF004400); // Very dim

  // Text colors (amber theme)
  static const Color textPrimaryAmber = amber;
  static const Color textSecondaryAmber = Color(0xFFAA7700);
  static const Color textDisabledAmber = Color(0xFF443300);

  // Glow colors (for shadows/effects)
  static const Color glowGreen = Color(0x8039FF14); // 50% opacity
  static const Color glowAmber = Color(0x80FFAA00);

  /// Returns the primary color for the given theme variant.
  static Color primary({bool amberTheme = false}) =>
      amberTheme ? amber : primaryGreen;

  /// Returns appropriate text color based on theme variant.
  static Color text({bool amberTheme = false}) =>
      amberTheme ? textPrimaryAmber : textPrimary;

  /// Returns glow color for shadow effects.
  static Color glow({bool amberTheme = false}) =>
      amberTheme ? glowAmber : glowGreen;
}
