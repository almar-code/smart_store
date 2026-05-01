import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_button.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CancelButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45,
        child: AppButton(label: "Cancel".tr(), color: AppColors.background ,borderRadius: 17,icon: Icons.cancel_outlined,onTap: onPressed,textColor: AppColors.textColor,borderColor: AppColors.borderSecondary,));
  }
}