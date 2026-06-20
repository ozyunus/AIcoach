import 'package:flutter/material.dart';

@immutable
class WritingCoachColors extends ThemeExtension<WritingCoachColors> {
  const WritingCoachColors({
    required this.primary,
    required this.primaryInk,
    required this.primaryTint,
    required this.primaryTintStrong,
    required this.primarySoft,
    required this.background,
    required this.sunken,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.line,
    required this.line2,
    required this.good,
    required this.goodTint,
    required this.warn,
    required this.warnTint,
    required this.bad,
    required this.badTint,
    required this.violet,
    required this.violetTint,
  });

  final Color primary;
  final Color primaryInk;
  final Color primaryTint;
  final Color primaryTintStrong;
  final Color primarySoft;
  final Color background;
  final Color sunken;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;
  final Color line;
  final Color line2;
  final Color good;
  final Color goodTint;
  final Color warn;
  final Color warnTint;
  final Color bad;
  final Color badTint;
  final Color violet;
  final Color violetTint;

  factory WritingCoachColors.dark() {
    return const WritingCoachColors(
      primary: Color(0xFF696FFF),
      primaryInk: Color(0xFFFFFFFF),
      primaryTint: Color(0xFF1B1F35),
      primaryTintStrong: Color(0xFF9AA3FF),
      primarySoft: Color(0xFF11131F),
      background: Color(0xFF0A0B10),
      sunken: Color(0xFF101219),
      card: Color(0xFF151722),
      ink: Color(0xFFF7F8FB),
      ink2: Color(0xFFD4D8E4),
      ink3: Color(0xFF8B91A3),
      ink4: Color(0xFF5F6575),
      line: Color(0x1FFFFFFF),
      line2: Color(0x12FFFFFF),
      good: Color(0xFF34D399),
      goodTint: Color(0x1F34D399),
      warn: Color(0xFFFBBF24),
      warnTint: Color(0x1FFBBF24),
      bad: Color(0xFFFB7185),
      badTint: Color(0x1FFB7185),
      violet: Color(0xFFC084FC),
      violetTint: Color(0x21C084FC),
    );
  }

  factory WritingCoachColors.day() {
    return const WritingCoachColors(
      primary: Color(0xFF4551E6),
      primaryInk: Color(0xFFFFFFFF),
      primaryTint: Color(0xFFE9ECFF),
      primaryTintStrong: Color(0xFF4F5DFF),
      primarySoft: Color(0xFFF1F3FF),
      background: Color(0xFFF5F7FF),
      sunken: Color(0xFFEDF1FB),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF101828),
      ink2: Color(0xFF334155),
      ink3: Color(0xFF667085),
      ink4: Color(0xFF98A2B3),
      line: Color(0x1F1D2A48),
      line2: Color(0x141D2A48),
      good: Color(0xFF059669),
      goodTint: Color(0x1A059669),
      warn: Color(0xFFB7791F),
      warnTint: Color(0x1FB7791F),
      bad: Color(0xFFDC2626),
      badTint: Color(0x1ADC2626),
      violet: Color(0xFF7C3AED),
      violetTint: Color(0x1A7C3AED),
    );
  }

  factory WritingCoachColors.accessible() {
    return const WritingCoachColors(
      primary: Color(0xFF38BDF8),
      primaryInk: Color(0xFF001018),
      primaryTint: Color(0xFF072436),
      primaryTintStrong: Color(0xFF7DD3FC),
      primarySoft: Color(0xFF061823),
      background: Color(0xFF000000),
      sunken: Color(0xFF0B0B0B),
      card: Color(0xFF111111),
      ink: Color(0xFFFFFFFF),
      ink2: Color(0xFFF2F4F7),
      ink3: Color(0xFFD0D5DD),
      ink4: Color(0xFFB8C0CC),
      line: Color(0x42FFFFFF),
      line2: Color(0x2EFFFFFF),
      good: Color(0xFF4ADE80),
      goodTint: Color(0x2B4ADE80),
      warn: Color(0xFFFACC15),
      warnTint: Color(0x2EFACC15),
      bad: Color(0xFFFB7185),
      badTint: Color(0x2EFB7185),
      violet: Color(0xFFD8B4FE),
      violetTint: Color(0x2BD8B4FE),
    );
  }

  factory WritingCoachColors.light() => WritingCoachColors.day();

  bool get isDark => background.computeLuminance() < 0.45;
  bool get isHighContrast => background == const Color(0xFF000000);

  @override
  WritingCoachColors copyWith({
    Color? primary,
    Color? primaryInk,
    Color? primaryTint,
    Color? primaryTintStrong,
    Color? primarySoft,
    Color? background,
    Color? sunken,
    Color? card,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? ink4,
    Color? line,
    Color? line2,
    Color? good,
    Color? goodTint,
    Color? warn,
    Color? warnTint,
    Color? bad,
    Color? badTint,
    Color? violet,
    Color? violetTint,
  }) {
    return WritingCoachColors(
      primary: primary ?? this.primary,
      primaryInk: primaryInk ?? this.primaryInk,
      primaryTint: primaryTint ?? this.primaryTint,
      primaryTintStrong: primaryTintStrong ?? this.primaryTintStrong,
      primarySoft: primarySoft ?? this.primarySoft,
      background: background ?? this.background,
      sunken: sunken ?? this.sunken,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      ink4: ink4 ?? this.ink4,
      line: line ?? this.line,
      line2: line2 ?? this.line2,
      good: good ?? this.good,
      goodTint: goodTint ?? this.goodTint,
      warn: warn ?? this.warn,
      warnTint: warnTint ?? this.warnTint,
      bad: bad ?? this.bad,
      badTint: badTint ?? this.badTint,
      violet: violet ?? this.violet,
      violetTint: violetTint ?? this.violetTint,
    );
  }

  @override
  WritingCoachColors lerp(ThemeExtension<WritingCoachColors>? other, double t) {
    if (other is! WritingCoachColors) {
      return this;
    }

    return WritingCoachColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryInk: Color.lerp(primaryInk, other.primaryInk, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      primaryTintStrong: Color.lerp(
        primaryTintStrong,
        other.primaryTintStrong,
        t,
      )!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      sunken: Color.lerp(sunken, other.sunken, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      ink4: Color.lerp(ink4, other.ink4, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      good: Color.lerp(good, other.good, t)!,
      goodTint: Color.lerp(goodTint, other.goodTint, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnTint: Color.lerp(warnTint, other.warnTint, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      badTint: Color.lerp(badTint, other.badTint, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      violetTint: Color.lerp(violetTint, other.violetTint, t)!,
    );
  }
}

extension WritingCoachColorContext on BuildContext {
  WritingCoachColors get colors =>
      Theme.of(this).extension<WritingCoachColors>()!;
}
