import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const forest = Color(0xFF173B34);
  static const forestDark = Color(0xFF102C27);
  static const forestSoft = Color(0xFF24524A);
  static const gold = Color(0xFFD5B47A);
  static const goldDeep = Color(0xFFB08E55);
  static const ivory = Color(0xFFF7F5F0);
  static const ink = Color(0xFF202A2A);
  static const white = Color(0xFFFFFFFF);

  static const muted = Color(0xFF6E7876);
  static const line = Color(0xFFE6E1D6);
  static const sand = Color(0xFFEFE9DD);
  static const success = Color(0xFF2E7D5B);
  static const warning = Color(0xFFC08A2E);
  static const danger = Color(0xFFB4483C);
  static const info = Color(0xFF3A6A8C);
}

extension ColorOpacity on Color {
  Color o(double opacity) => withAlpha((opacity * 255).round().clamp(0, 255));
}
