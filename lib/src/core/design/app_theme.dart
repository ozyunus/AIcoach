import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:ai_coach/src/core/design/app_typography.dart';
import 'package:ai_coach/src/core/design/app_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppTheme {
  static ThemeData forMode(WritingCoachThemeMode mode) {
    final colors = switch (mode) {
      WritingCoachThemeMode.dark => WritingCoachColors.dark(),
      WritingCoachThemeMode.day => WritingCoachColors.day(),
      WritingCoachThemeMode.accessible => WritingCoachColors.accessible(),
    };
    final textTheme = AppTypography.textTheme(
      colors,
      scale: mode == WritingCoachThemeMode.accessible ? 1.08 : 1,
    );
    final brightness = colors.isDark ? Brightness.dark : Brightness.light;
    final overlayStyle = colors.isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        surface: colors.background,
        onSurface: colors.ink,
      ),
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      splashFactory: mode == WritingCoachThemeMode.accessible
          ? NoSplash.splashFactory
          : InkRipple.splashFactory,
      visualDensity: mode == WritingCoachThemeMode.accessible
          ? VisualDensity.comfortable
          : VisualDensity.standard,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        systemOverlayStyle: overlayStyle.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: colors.background,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryInk,
          disabledBackgroundColor: colors.sunken,
          disabledForegroundColor: colors.ink4,
          minimumSize: Size.fromHeight(
            mode == WritingCoachThemeMode.accessible ? 58 : 54,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.mediumRadius,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          side: BorderSide(
            color: colors.line,
            width: mode == WritingCoachThemeMode.accessible ? 2 : 1,
          ),
          minimumSize: Size.fromHeight(
            mode == WritingCoachThemeMode.accessible ? 58 : 54,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.mediumRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.ink4),
      ),
    );
  }

  static ThemeData light() {
    return forMode(WritingCoachThemeMode.day);
  }
}
