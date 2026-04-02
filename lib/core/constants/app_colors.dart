// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // اللون الأساسي الذي اخترته
  static const Color primary = Color.fromARGB(255, 3, 195, 131);
  static const Color boxShadow = Color.fromARGB(128, 23, 22, 22);
  static const Color iconColor = Color.fromARGB(255, 0, 0, 0);
  static const Color borderColor = Color.fromARGB(66, 158, 158, 158);
  static const Color textColor = Color.fromARGB(255, 0, 0, 0);
  static const Color redColor = Color(0xFFE53935);      // للتنبيهات والأخطاء


  // ألوان إضافية مقترحة لتناسب الـ SaaS Style
  static const Color background = Color(0xFFFFFFFF); // خلفية فاتحة ومريحة
  static const Color surface = Colors.white;         // للبطاقات (Cards)
  static const Color textPrimary = Color(0xFF1A1A1A); // للخطوط الأساسية
  static const Color textSecondary = Color(0xFF757575); // للنصوص الفرعية
  static const Color error = Color(0xFFE53935);      // للتنبيهات والأخطاء
}