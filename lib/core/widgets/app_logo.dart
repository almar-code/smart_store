import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
class Logo extends StatelessWidget {
  final double width;
  final double height;
  Logo({super.key,this.width=27,this.height=27});
  @override
  Widget build(BuildContext context) {
    return  Image.asset(
      AppColors.isDark.value ? 'assets/images/ligth-mode-logo.gif' : 'assets/images/logo.png',
      width: width ,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
