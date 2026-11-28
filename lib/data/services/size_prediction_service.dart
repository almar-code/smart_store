import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';

class SizePredictionService {
  final Dio dio = Dio();

  // إرسال قياسات العميلة إلى عقدة n8n واستقبال المقاس المقترح
  Future<Map<String, dynamic>> predictSize(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiEndpoints.n8nSizePredictor,
      data: body,
      options: Options(
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        // تحليل الصورة قد يتأخر في أول طلب
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    final data = response.data;
    // n8n قد يرجع قائمة بعنصر واحد أو كائن مباشرة
    if (data is List && data.isNotEmpty) return Map<String, dynamic>.from(data.first);
    return Map<String, dynamic>.from(data);
  }
}
