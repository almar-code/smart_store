import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_endpoints.dart';

class SizePredictionService {
  final Dio dio = Dio();
  static const String _boxName = 'user_info_box';
  static const String _profileKey = 'size_profile';

  // إرسال قياسات العميلة إلى عقدة n8n واستقبال المقاس المقترح
  Future<Map<String, dynamic>> predictSize(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiEndpoints.n8nSizePredictor,
      data: body,
      options: Options(
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final data = response.data;
    // n8n قد يرجع قائمة بعنصر واحد أو كائن مباشرة
    if (data is List && data.isNotEmpty) return Map<String, dynamic>.from(data.first);
    return Map<String, dynamic>.from(data);
  }

  // حفظ آخر قياسات للعميلة (Hive) حتى لا تعيد إدخالها
  Future<void> saveProfile(Map<String, dynamic> body) async {
    final box = Hive.box(_boxName);
    await box.put(_profileKey, body);
  }

  Map<dynamic, dynamic>? loadProfile() {
    final box = Hive.box(_boxName);
    return box.get(_profileKey);
  }
}
