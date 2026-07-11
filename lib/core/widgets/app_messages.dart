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
}