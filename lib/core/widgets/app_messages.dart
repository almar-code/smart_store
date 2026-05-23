import 'package:easy_localization/easy_localization.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';

class AppToasts {

  static void showErrorToast(BuildContext context, String message) {
    ElegantNotification.error(
      width: 350,
      height: 60,

      title:  Text(tr("error"), style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }

  static void showSuccessToast(BuildContext context, String message) {
    ElegantNotification.success(
      width: 350,
      height: 65,
      title:  Text(tr("success"), style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      onDismiss: () {},
    ).show(context);
  }
}