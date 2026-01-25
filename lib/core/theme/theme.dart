import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'typography.dart';

/// XenoSignal theme configuration.
///
/// Provides ThemeData for the retro-futuristic CRT aesthetic.
/// Supports both green (default) and amber theme variants.
abstract final class XenoTheme {
  /// Spacing constants based on 8px grid.
  static const double spacing1x = 8;
  static const double spacing2x = 16;
  static const double spacing3x = 24;
  static const double spacing4x = 32;

  /// Border radius - subtle, not rounded.
  static const double borderRadius = 4;

  /// Animation durations.
  static const Duration transitionDuration = Duration(milliseconds: 250);
  static const Duration feedbackDuration = Duration(milliseconds: 100);

  /// Minimum touch targets per platform guidelines.
  static const double minTouchTargetIOS = 44;
  static const double minTouchTargetAndroid = 48;

  /// Creates the main XenoSignal theme.
  ///
  /// Set [amberTheme] to true for the amber color variant.
  static ThemeData create({bool amberTheme = false}) {
    final primaryColor = XenoColors.primary(amberTheme: amberTheme);
    final textTheme = XenoTypography.textTheme(amberTheme: amberTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Colors
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: XenoColors.background,
        secondary: XenoColors.classicGreen,
        onSecondary: XenoColors.background,
        surface: XenoColors.surfaceDark,
        onSurface: primaryColor,
        error: XenoColors.danger,
        onError: XenoColors.background,
      ),
      scaffoldBackgroundColor: XenoColors.background,

      // Typography
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: XenoColors.background,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: XenoTypography.title(color: primaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: XenoColors.background,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: XenoColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.all(spacing1x),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: XenoColors.background,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: spacing2x),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: XenoTypography.body(color: XenoColors.background),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: spacing2x),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(color: primaryColor),
          textStyle: XenoTypography.body(color: primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: spacing2x),
          textStyle: XenoTypography.body(color: primaryColor),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: XenoColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor),
        ),
        labelStyle: XenoTypography.body(color: primaryColor),
        hintStyle:
            XenoTypography.body(color: primaryColor.withValues(alpha: 0.5)),
      ),

      // Icons
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: primaryColor.withValues(alpha: 0.2),
        thickness: 1,
        space: spacing2x,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return XenoColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.3);
          }
          return XenoColors.surfaceMid;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: 0.3),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
      ),

      // Progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: primaryColor.withValues(alpha: 0.2),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: XenoColors.surfaceMid,
        contentTextStyle: XenoTypography.body(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: XenoColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        ),
        titleTextStyle: XenoTypography.title(color: primaryColor),
        contentTextStyle: XenoTypography.body(color: primaryColor),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: XenoColors.background,
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Green theme (default).
  static ThemeData get green => create(amberTheme: false);

  /// Amber theme (alternate).
  static ThemeData get amber => create(amberTheme: true);
}
