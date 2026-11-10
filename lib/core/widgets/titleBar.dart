import 'package:flutter/material.dart';
import 'package:smart_store/core/widgets/text/viewMoreText.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadow.dart';
import 'icons/app_icon.dart';

class TitleBar extends StatelessWidget {
  final String title;
  final bool isDecoration ;
  final Widget? viewMoreShow ;
  final Color? color ;
  const TitleBar({
    super.key,
    this.title = "",
    this.isDecoration = true,
    this.viewMoreShow,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: (isDecoration) ? EdgeInsets.symmetric(horizontal: 10, vertical: 5) : null,
      decoration: (isDecoration) ? BoxDecoration(
        // استخدام التدرج اللوني يعطي عمقاً فخماً
       color: AppColors.background,
        borderRadius: BorderRadius.circular(7), // حواف أكثر انحناءً للمسة عصرية
        boxShadow:AppShadow.commonShadow, // دمج ظلالك الخاصة

        border: Border.all(
          color:AppColors.borderColor, // إطار مضيء خفيف (Inner Glow)
          width: 1,
        ),
      ) : null,
      child: Row(
        mainAxisAlignment: (viewMoreShow != null) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // إضافة لمسة جمالية (خط عمودي صغير قبل النص)
              Container(
                width: 3,
                height: 15,
                decoration: BoxDecoration(
                  color: color ?? AppColors.primary, // لون التطبيق الأساسي
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style:  TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color:  AppColors.textColor, // أو AppColors.text
                ),
              ),
            ],
          ),
          if(viewMoreShow != null) ...[
            viewMoreShow ?? SizedBox()
            ]
        ],
      ),
    );
  }
}