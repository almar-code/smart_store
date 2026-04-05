import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
class AppButton extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final double iconSize;
  final String label;
  const AppButton({super.key,this.color  ,this.fontSize  =14,this.iconSize  =14,this.icon ,this.label='checkout',this.borderColor = Colors.white,this.textColor =Colors.white});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      // padding: const EdgeInsets.symmetric(vertical: 15),
      color: color ?? AppColors.buttonColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(2),
      ),
      elevation: 0,
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (icon != null) ? Icon(icon,color:textColor,size: iconSize,):SizedBox(),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
