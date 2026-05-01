import 'package:flutter/material.dart';

class AppColors {
  /// 🔥 بدل bool عادي → ValueNotifier (تحديث فوري)
  static ValueNotifier<bool> isDark = ValueNotifier(false);

  // اللون الأساسي
  static Color get primary =>
      isDark.value ? const Color(0xFF03C383) : const Color.fromARGB(255, 3, 195, 131);

  static Color get boxShadow =>
      isDark.value ? Colors.white10 : Colors.black12;

  static Color get iconColor =>
      isDark.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0);

  static Color get borderColor =>
      isDark.value ? Colors.white10 : const Color.fromARGB(66, 158, 158, 158);
  static Color get borderSecondary =>
      isDark.value ? Colors.white60 : Colors.black26;

  static Color get textColor =>
      isDark.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0);

  static Color get redColor => const Color(0xFFE53935);

  static Color get buttonColor =>
      isDark.value ? const Color(0xFF00B387) : const Color(0xFF00B387);

  static Color get background =>
      isDark.value ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
// اللون العلوي للتدرج
  static Color get gradientTop =>
      isDark.value ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
// اللون السفلي للتدرج
  static Color get gradientBottom =>
      isDark.value ? const Color(0xFF1C1C1E) : const Color(0xFFE8EAF0);
  static Color get textSecondary =>
      isDark.value ? Colors.white70 : const Color(0xFF757575);

  static Color get backgroundSecondary =>
      isDark.value ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

  static Color get baseColor =>
      isDark.value ? const Color(0xFF2A2A2A) : Colors.grey.shade300;

  static Color get highlightColor =>
      isDark.value ? const Color(0xFF3A3A3A) : Colors.grey.shade100;

  static Color get ContainerColor =>
      isDark.value ? const Color(0xFF121212) : Colors.white;
  static Color get error => const Color(0xFFE53935);

  /// 🔧 تحويل HEX إلى Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    return Color(int.parse(hex, radix: 16));
  }
}