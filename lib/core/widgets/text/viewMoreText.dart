import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class ViewMoreText extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const ViewMoreText({
    super.key,
    this.fontSize = 12, // القيمة الافتراضية 12
    this.color =  AppColors.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      tr('viewMore'),
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}