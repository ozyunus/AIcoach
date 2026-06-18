import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double screenX = 18;
  static const double screenTop = 8;
  static const double sectionGap = 26;
  static const double cardGap = 14;
  static const double cardPadding = 18;
  static const double chipX = 11;
  static const double chipY = 6;
  static const double bottomNavHeight = 96;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(24));
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(16),
  );
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(12));
}
