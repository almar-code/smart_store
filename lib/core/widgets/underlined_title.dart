import 'package:flutter/material.dart';
import '../constants/app_colors.dart'; // تأكد من مسار الألوان لديك
import 'app_title.dart'; // تأكد من مسار كلاس AppTitle

class UnderlinedTitle extends StatelessWidget {
  final String firstPart;
  final String secondPart;
  final double fontSize;
  final double underlineWidth;
  final double underlineHeight;
  final String spacing;
  final bool isCenter;

  const UnderlinedTitle({
    super.key,
    this.firstPart = '',
    this.secondPart = '',
    this.fontSize = 15,
    this.underlineWidth = 50,
    this.underlineHeight = 2.5,
    this.spacing = ' ',
    this.isCenter = false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCenter ? CrossAxisAlignment.center :CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        AppTitle(
          firstPart: firstPart,
          secondPart: secondPart,
          fontSize: fontSize,
          spacing: spacing,
        ),
        Container(
          height: underlineHeight,
          width: underlineWidth,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}