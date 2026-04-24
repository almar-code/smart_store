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
  final bool iconAfter ;
  final VoidCallback? onTap;
  const AppButton({super.key,this.color  ,this.fontSize  =14,this.iconSize  =14,this.icon ,this.label='checkout',this.borderColor = Colors.white,this.textColor =Colors.white,this.onTap ,this.iconAfter =false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return MaterialButton(
      onPressed: onTap ?? (){},
      // padding: const EdgeInsets.symmetric(vertical: 15),
      color: color ?? AppColors.buttonColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(isDesktop ? 6 : 3,),
      ),
      elevation: 0,
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (!iconAfter) ? (icon != null) ? Icon(icon,color:textColor,size: iconSize,):SizedBox() : SizedBox(),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          (iconAfter) ? (icon != null) ? Icon(icon,color:textColor,size: iconSize,):SizedBox() : SizedBox(),
        ],
      ),
    );
  }
}
