
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_messages.dart';
import 'network_service.dart';
class InternetCheck {
  // جعل الدالة ترجع Future<bool> لتخبر الكود المستدعي هل يوجد نت أم لا
  static Future<bool> internetCheck(BuildContext context) async {
    bool connected = await NetworkService.hasInternet();
    if (!connected) {
      if (context.mounted) {
        AppToasts.showErrorToast(
          context,
          tr("no_internet"),
        );
      }
      return false; // لا يوجد إنترنت
    }
    return true; // الإنترنت شغال
  }
}