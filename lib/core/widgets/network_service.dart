import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_endpoints.dart';

class NetworkService {
  // مهلة قصيرة حتى لا ينتظر المستخدم
  static const Duration _timeout = Duration(seconds: 5);

  /// ترجع true فقط إذا كان الإنترنت يعمل فعلاً
  static Future<bool> hasInternet() async {
    try {
      // 1. لا واي فاي ولا بيانات: لا داعي لأي طلب
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.none)) return false;

      // 2. طلب صغير لسيرفر المتجر
      if (await _ping(ApiEndpoints.healthCheck)) return true;

      // 3. على الجوال: محاولة احتياطية مع Google إذا كان سيرفرنا متوقفاً
      if (!kIsWeb) {
        return await _ping('https://www.google.com/generate_204');
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _ping(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}