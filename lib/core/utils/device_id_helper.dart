import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

// معرف ثابت للجهاز لذاكرة الزائرة غير المسجلة
class DeviceIdHelper {
  static const String _key = 'voice_device_id';

  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_key);
    if (id == null) {
      final rand = Random.secure().nextInt(1 << 32).toRadixString(16);
      id = '${DateTime.now().millisecondsSinceEpoch}$rand';
      await prefs.setString(_key, id);
    }
    return id;
  }
}