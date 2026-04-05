import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadow {
  // تعريف الظل كمتغير ثابت (static const)
  static final BoxShadow defaultShadow = BoxShadow(
    color:AppColors.boxShadow, // هذا يمثل Colors.black.withOpacity(0.08)
    blurRadius: 4,
    spreadRadius: 1,
    offset: const Offset(0, 2),
  );

  // يمكنك أيضاً تعريف القائمة كاملة لتسهيل الاستخدام في الـ Decoration
  static final List<BoxShadow> commonShadow = [defaultShadow];
}