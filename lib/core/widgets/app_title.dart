import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTitle extends StatelessWidget {
  final String firstPart ;
  final String secondPart;
  final double fontSize;

  AppTitle({super.key,this.firstPart="N",this.secondPart="ice",this.fontSize=17});

  @override
  Widget build(BuildContext context) {

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: firstPart,
            style:  TextStyle(
              color: AppColors.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: secondPart,
            style: TextStyle(
              color: AppColors.iconColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}




