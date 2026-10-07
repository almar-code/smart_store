import 'package:easy_localization/easy_localization.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';

class AppToasts {

  static void showErrorToast(BuildContext context, String message) {
    ElegantNotification.error(
      width: 350,
      height: 60,
      background: AppColors.background,
      title:  Text(tr("error"), style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message,style: TextStyle(color: AppColors.textColor),),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }

  static void showSuccessToast(BuildContext context, String message) {
    ElegantNotification.success(
      width: 350,
      height: 65,
      background: AppColors.background,
      title:  Text(tr("success"), style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message,style: TextStyle(color: AppColors.textColor),),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }
  static void showWarningToast(BuildContext context, String message) {
    ElegantNotification.info(
      width: 350,
      height: 65,
      background: AppColors.background,
      // تأكد من إضافة المفتاح "warning" أو "attention" في ملفات الترجمة لديك
      title: Text(tr("warning"), style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message,style: TextStyle(color: AppColors.textColor),),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          spacing: 6,
          children: [
            Icon(Icons.warning_amber_rounded ,color: AppColors.redColor,size:30 ,),
            Text(
              title,
              style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel'), style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.redColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}