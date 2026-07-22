import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF057064);
  static const Color primaryDark = Color(0xFF04564D);
  static const Color primaryTint = Color(0xFFE3F0EE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF7F9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F4F3);
  static const Color border = Color(0xFFE3E9E7);
  static const Color borderStrong = Color(0xFFCBD5D2);

  static const Color textPrimary = Color(0xFF0F1A18);
  static const Color textSecondary = Color(0xFF5C6B68);
  static const Color textTertiary = Color(0xFF8A9793);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF17803D);
  static const Color successTint = Color(0xFFE7F5EC);
  static const Color warning = Color(0xFFB45309);
  static const Color warningTint = Color(0xFFFDF2E3);
  static const Color danger = Color(0xFFC2261C);
  static const Color dangerTint = Color(0xFFFBEAE8);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoTint = Color(0xFFEAEFFC);

  static const List<Color> chartSeries = <Color>[
    Color(0xFF057064),
    Color(0xFF1D4ED8),
    Color(0xFFB45309),
    Color(0xFF7C3AED),
    Color(0xFFC2261C),
  ];

  const AppColors._();
}
