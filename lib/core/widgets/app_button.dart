import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
class AppButton extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final double fontSize;
  final String label;
  const AppButton({super.key,this.color =AppColors.buttonColor ,this.fontSize  =14,this.icon ,this.label=''});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      elevation: 0,
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (icon != null) ? Icon(icon,color: Colors.white,size: fontSize,):SizedBox(),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
