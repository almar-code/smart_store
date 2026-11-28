import 'package:easy_localization/easy_localization.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';

class AppToasts {
  static const double _maxWidth = 350;
  static const double _descSize = 13;

  // عرض الإشعار: لا يتجاوز الشاشة في الجوال
  static double _width(BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    return screen - 24 < _maxWidth ? screen - 24 : _maxWidth;
  }

  // ارتفاع الإشعار حسب طول النص
  static double _height(BuildContext context, String message, double width) {
    final painter = TextPainter(
      text: TextSpan(text: message, style: const TextStyle(fontSize: _descSize)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width - 100); // مساحة الأيقونة وزر الإغلاق والهوامش
    return (painter.height + 48).clamp(65.0, 240.0);
  }

  // مدة الظهور تزيد مع طول النص
  static Duration _duration(String message) =>
      Duration(milliseconds: (3000 + message.length * 40).clamp(3000, 8000));

  static Widget _title(String key) =>
      Text(tr(key), style: const TextStyle(fontWeight: FontWeight.bold));

  static Widget _description(String message) => Text(
    message,
    style: TextStyle(color: AppColors.textColor, fontSize: _descSize),
  );

  static void showErrorToast(BuildContext context, String message) {
    final width = _width(context);
    ElegantNotification.error(
      width: width,
      height: _height(context, message, width),
      toastDuration: _duration(message),
      background: AppColors.background,
      title: _title("error"),
      description: _description(message),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }

  static void showSuccessToast(BuildContext context, String message) {
    final width = _width(context);
    ElegantNotification.success(
      width: width,
      height: _height(context, message, width),
      toastDuration: _duration(message),
      background: AppColors.background,
      title: _title("success"),
      description: _description(message),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }

  static void showWarningToast(BuildContext context, String message) {
    final width = _width(context);
    ElegantNotification.info(
      width: width,
      height: _height(context, message, width),
      toastDuration: _duration(message),
      background: AppColors.background,
      title: _title("warning"),
      description: _description(message),
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
            Icon(Icons.warning_amber_rounded, color: AppColors.redColor, size: 30),
            // العنوان الطويل ينزل لسطر ثاني
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold),
              ),
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