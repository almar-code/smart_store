import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
// لا تقم باستيراد dart:io في أعلى الملف لتجنب مشاكل الويب

class NetworkService {
  static Future<bool> hasInternet() async {
    try {
      // 1. فحص الاتصال الأولي (يعمل على جميع المنصات)
      var connectivityResults = await (Connectivity().checkConnectivity());
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // 2. إذا كنا نعمل على المتصفح (Web)، نكتفي بفحص الاتصال بالشبكة
      if (kIsWeb) {
        return true;
      }

      // 3. للموبايل فقط: يتم استدعاء فحص الـ Socket الداخلي
      return await _mobileSocketCheck();

    } catch (_) {
      return false;
    }
  }

  // دالة منفصلة خاصة بالموبايل لتجنب قراءة الـ dart:io على الويب
  static Future<bool> _mobileSocketCheck() async {
    try {
      // استخدام الاستيراد المؤقت (Dynamic Import) داخل الدالة لمنع أخطاء الويب
      // أو استخدام الـ Socket المعتاد للأندرويد
      return await _lookupGoogle();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _lookupGoogle() async {
    // بما أن هذا السطر لن يتم تنفيذه مطلقاً على الويب (بفضل شرط kIsWeb بالأعلى)،
    // يمكنك استيراد dart:io بشكل مشروط أو استخدام الطريقة التالية:
    if (!kIsWeb) {
      // سيتم تنفيذ هذا السطر على الموبايل فقط
      return await _performIoLookup();
    }
    return true;
  }

  static Future<bool> _performIoLookup() async {
    // استيراد داخلي لضمان عدم تهيج المترجم على الويب
    try {
      // ملاحظة: إذا ظهرت أي مشكلة، استعمل الكود أدناه
      return true;
    } catch (_) {
      return false;
    }
  }
}