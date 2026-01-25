import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// XenoSignal typography - monospace terminal fonts with retro aesthetic.
///
/// Uses VT323 as primary font (classic CRT terminal look) with
/// Share Tech Mono as fallback. All text uses the phosphor green color
/// by default.
abstract final class XenoTypography {
  /// Base text style using VT323 font.
  static TextStyle _baseStyle({
    double fontSize = 14,
    double letterSpacing = 0,
    FontWeight fontWeight = FontWeight.w400,
    Color color = XenoColors.textPrimary,
  }) {
    return GoogleFonts.vt323(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      color: color,
      height: 1.2,
    );
  }

  /// Display text - 32px, used for large readings and titles.
  static TextStyle display({Color? color}) => _baseStyle(
        fontSize: 32,
        letterSpacing: 0.64, // +0.02em
        color: color ?? XenoColors.textPrimary,
      );

  /// Title text - 24px, section headers.
  static TextStyle title({Color? color}) => _baseStyle(
        fontSize: 24,
        letterSpacing: 0.24, // +0.01em
        color: color ?? XenoColors.textPrimary,
      );

  /// Body large text - 18px, emphasized content.
  static TextStyle bodyLarge({Color? color}) => _baseStyle(
        fontSize: 18,
        color: color ?? XenoColors.textPrimary,
      );

  /// Body text - 14px, standard content.
  static TextStyle body({Color? color}) => _baseStyle(
        fontSize: 14,
        color: color ?? XenoColors.textPrimary,
      );

  /// Caption text - 12px, secondary information.
  static TextStyle caption({Color? color}) => _baseStyle(
        fontSize: 12,
        letterSpacing: 0.12, // +0.01em
        color: color ?? XenoColors.textSecondary,
      );

  /// Overline text - 10px ALL CAPS, labels and categories.
  static TextStyle overline({Color? color}) => _baseStyle(
        fontSize: 10,
        letterSpacing: 0.5, // +0.05em
        fontWeight: FontWeight.w500,
        color: color ?? XenoColors.textSecondary,
      );

  /// Creates a complete TextTheme for use with ThemeData.
  static TextTheme textTheme({bool amberTheme = false}) {
    final primaryColor =
        amberTheme ? XenoColors.textPrimaryAmber : XenoColors.textPrimary;
    final secondaryColor =
        amberTheme ? XenoColors.textSecondaryAmber : XenoColors.textSecondary;

    return TextTheme(
      displayLarge: display(color: primaryColor),
      displayMedium: display(color: primaryColor),
      displaySmall: title(color: primaryColor),
      headlineLarge: title(color: primaryColor),
      headlineMedium: title(color: primaryColor),
      headlineSmall: bodyLarge(color: primaryColor),
      titleLarge: title(color: primaryColor),
      titleMedium: bodyLarge(color: primaryColor),
      titleSmall: body(color: primaryColor),
      bodyLarge: bodyLarge(color: primaryColor),
      bodyMedium: body(color: primaryColor),
      bodySmall: caption(color: secondaryColor),
      labelLarge: body(color: primaryColor),
      labelMedium: caption(color: primaryColor),
      labelSmall: overline(color: secondaryColor),
    );
  }
}
