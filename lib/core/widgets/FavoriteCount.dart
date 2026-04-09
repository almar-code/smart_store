import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
class FavoriteCount extends StatelessWidget {
  final double fontSize;
  final Color? color;
  const FavoriteCount({super.key,this.fontSize=10,this.color});

  @override
  Widget build(BuildContext context) {
    return  Text('7',style: TextStyle(
        color: color ?? AppColors.primary,
        fontSize: fontSize,
        fontWeight: FontWeight.w600
    ),);
  }
}
