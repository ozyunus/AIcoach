import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Plus Jakarta Sans';
  static const String numberFontFamily = 'Space Grotesk';

  static TextTheme textTheme(WritingCoachColors colors, {double scale = 1}) {
    const base = TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: ['SF Pro Text', 'Segoe UI', 'Roboto', 'sans-serif'],
      letterSpacing: 0,
    );

    return TextTheme(
      displaySmall: base.copyWith(
        fontSize: 27 * scale,
        fontWeight: FontWeight.w800,
        height: 1.12,
        color: colors.ink,
      ),
      displayLarge: base.copyWith(
        fontSize: 56 * scale,
        fontWeight: FontWeight.w800,
        height: 0.95,
        color: colors.ink,
      ),
      titleLarge: base.copyWith(
        fontSize: 21 * scale,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: colors.ink,
      ),
      titleMedium: base.copyWith(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: colors.ink,
      ),
      bodyLarge: base.copyWith(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: colors.ink2,
      ),
      bodyMedium: base.copyWith(
        fontSize: 14.5 * scale,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: colors.ink2,
      ),
      bodySmall: base.copyWith(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: colors.ink3,
      ),
      labelLarge: base.copyWith(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      labelMedium: base.copyWith(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: colors.ink3,
      ),
      labelSmall: base.copyWith(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: colors.ink3,
      ),
    );
  }

  static TextStyle number({
    required WritingCoachColors colors,
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1,
  }) {
    return TextStyle(
      fontFamily: numberFontFamily,
      fontFamilyFallback: const ['SF Pro Display', 'Roboto', 'sans-serif'],
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? colors.ink,
      letterSpacing: 0,
    );
  }
}
