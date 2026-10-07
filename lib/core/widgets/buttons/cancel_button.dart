import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'app_button.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double borderRadius;
  const CancelButton({super.key, required this.onPressed, this.borderRadius = 17});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45,
        child: AppButton(label: "Cancel".tr(), color: AppColors.background ,borderRadius: borderRadius,icon: Icons.cancel_outlined,onTap: onPressed,textColor: AppColors.textColor,borderColor: AppColors.borderSecondary,));
  }
}
class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double borderRadius;
  const DeleteButton({super.key, required this.onPressed, this.borderRadius = 17});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45,
        child: AppButton(label: "delete".tr(), color: Color(0xFFFF5F00) ,borderRadius: borderRadius,icon: Icons.delete_outline,onTap: onPressed,borderColor: AppColors.borderSecondary,));
  }
}