import 'package:flutter/material.dart';

class AppShadow {
  // تعريف الظل كمتغير ثابت (static const)
  static const BoxShadow defaultShadow = BoxShadow(
    color: Color(0x14000000), // هذا يمثل Colors.black.withOpacity(0.08)
    blurRadius: 4,
    spreadRadius: 1,
    offset: Offset(0, 2),
  );

  // يمكنك أيضاً تعريف القائمة كاملة لتسهيل الاستخدام في الـ Decoration
  static const List<BoxShadow> commonShadow = [defaultShadow];
}