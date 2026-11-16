
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_messages.dart';
import 'network_service.dart';
class InternetCheck {
  // ترجع true إذا كان النت متوفراً، وتعرض رسالة إذا لم يكن
  static Future<bool> internetCheck(BuildContext context) async {
    final bool connected = await NetworkService.hasInternet();

    if (!connected) {
      if (context.mounted) {
        AppToasts.showErrorToast(context, tr("no_internet"));
      }
      return false;
    }

    return true;
  }
}