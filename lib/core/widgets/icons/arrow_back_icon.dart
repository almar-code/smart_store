
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'app_icon.dart';
class ArrowBack extends StatelessWidget {
  const ArrowBack({super.key});

  @override
  Widget build(BuildContext context) {
    return AppIcon(icon:Icons.arrow_forward_ios_outlined,onPressed: ()=> Navigator.of(context).pop(),color: AppColors.primary,);
  }
}
