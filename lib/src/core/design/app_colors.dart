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

  factory WritingCoachColors.light() {
    return const WritingCoachColors(
      primary: Color(0xFF2F5FE0),
      primaryInk: Color(0xFFFFFFFF),
      primaryTint: Color(0xFFEAF0FF),
      primaryTintStrong: Color(0xFFDCE6FF),
      primarySoft: Color(0xFFF4F7FF),
      background: Color(0xFFF8F9FC),
      sunken: Color(0xFFF0F3F8),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF273244),
      ink2: Color(0xFF626B7A),
      ink3: Color(0xFF8D95A1),
      ink4: Color(0xFFB6BDC8),
      line: Color(0xFFE3E7EF),
      line2: Color(0xFFEFF2F6),
      good: Color(0xFF2AA872),
      goodTint: Color(0xFFEAF8F1),
      warn: Color(0xFFDDB64A),
      warnTint: Color(0xFFFFF5D9),
      bad: Color(0xFFD9573F),
      badTint: Color(0xFFFFEFEC),
      violet: Color(0xFF884FD6),
      violetTint: Color(0xFFF2EAFB),
    );
  }

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
