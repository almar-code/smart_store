import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadow.dart';

class TitleBar extends StatelessWidget {
  final String title;

  const TitleBar({
    super.key,
    this.title = ""
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric( vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        // استخدام التدرج اللوني يعطي عمقاً فخماً
       color: AppColors.background,
        borderRadius: BorderRadius.circular(7), // حواف أكثر انحناءً للمسة عصرية
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          ...AppShadow.commonShadow, // دمج ظلالك الخاصة
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2), // إطار مضيء خفيف (Inner Glow)
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // إضافة لمسة جمالية (خط عمودي صغير قبل النص)
          Container(
            width: 3,
            height: 15,
            decoration: BoxDecoration(
              color: AppColors.primary, // لون التطبيق الأساسي
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color:  AppColors.textColor, // أو AppColors.text
            ),
          ),
        ],
      ),
    );
  }
}