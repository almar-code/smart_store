import 'package:dio/dio.dart';

import '../../core/constants/app_endpoints.dart';

class ChatService {
  final Dio _dio = Dio();

  Future<String> sendPrompt({required String chatId, required String message}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.n8nChatAgent,
        data: {
          'chat_id': chatId,
          'message': message,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // معالجة الرد القادم من n8n
        return data['output'] ?? data['message'] ?? 'لم أتمكن من فهم الرد.';
      } else {
        return 'حدث خطأ في الاتصال بالسيرفر: ${response.statusCode}';
      }
    } on DioException catch (e) {
      return 'فشل الاتصال بالشبكة: ${e.message ?? e.toString()}';
    } catch (e) {
      return 'حدث خطأ غير متوقع: $e';
    }
  }
}