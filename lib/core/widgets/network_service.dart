import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> hasInternet() async {
    try {
      // 1. فحص النوع: هل الجهاز متصل بأي شبكة أصلاً؟
      var connectivityResults = await (Connectivity().checkConnectivity());

      // إذا كانت القائمة تحتوي على 'none' فقط، فلا يوجد اتصال فيزيائي
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // 2. الفحص الحقيقي والمباشر (بواسطة IP لضمان السرعة والدقة)
      // نستخدم Socket للاتصال بـ Google DNS على المنفذ 53
      // هذا الفحص لا يخطئ لأنه يختبر عبور البيانات فعلياً
      final result = await Socket.connect('8.8.8.8', 53,
          timeout: const Duration(seconds: 2));

      result.destroy(); // إغلاق الاتصال فوراً بعد التأكد
      return true;

    } catch (_) {
      // في حال فشل الاتصال بالـ IP أو حدوث Timeout
      // نقوم بمحاولة أخيرة عبر الـ Lookup
      return await _fallbackCheck();
    }
  }

  // فحص احتياطي في حال فشل الـ Socket لأسباب أمنية في الجهاز
  static Future<bool> _fallbackCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}