import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = false;

  // اللون الأساسي
  static Color get primary =>
      isDark ? const Color(0xFF03C383) : const Color.fromARGB(255, 3, 195, 131);

  static Color get boxShadow =>
      isDark ? Colors.white10 :  Colors.black12;

  static Color get iconColor =>
      isDark ? Colors.white : const Color.fromARGB(255, 0, 0, 0);

  static Color get borderColor =>
      isDark ? Colors.white10 : const Color.fromARGB(66, 158, 158, 158);

  static Color get textColor =>
      isDark ? Colors.white : const Color.fromARGB(255, 0, 0, 0);

  static Color get redColor => const Color(0xFFE53935);

  static Color get buttonColor =>
      isDark ? const Color(0xFF159A8C) : const Color(0xFF1FAF9F);

  static Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

  static Color get textSecondary =>
      isDark ? Colors.white70 : const Color(0xFF757575);

  static Color get backgroundSecondary =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

  static Color get baseColor =>
      isDark? const Color(0xFF2A2A2A): Colors.grey.shade300;

  static Color get highlightColor =>
      isDark? const Color(0xFF3A3A3A): Colors.grey.shade100;
  static Color get error => const Color(0xFFE53935);

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    return Color(int.parse(hex, radix: 16));
  }
}