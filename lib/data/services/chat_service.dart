
import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../../core/constants/app_endpoints.dart';
import '../local/user_local.dart';

class ChatService {
  final Dio _dio = Dio();
  Future<int?> _customerId() => UserLocal().getCustomerId();
  Future<Map<String, dynamic>> sendPrompt({
    required String message,
    Uint8List? image,
    String? imageName,
  }) async {
    try {
      dynamic requestData;

      if (image != null) {
        requestData = FormData.fromMap({
          'chat_id':  await _customerId(),
          'message': message,
          'image': MultipartFile.fromBytes(
            image,
            filename: imageName ?? 'image.jpg',
          ),
        });
      } else {
        requestData = {
          'chat_id':  await _customerId(),
          'message': message,
        };
      }

      final response = await _dio.post(
        ApiEndpoints.n8nChatAgent,
        data: requestData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map) {
          // محاولة استخراج الـ message و similar_products بدقة
          String msg = data['message'] ?? data['output'] ?? 'لم أتمكن من فهم الرد.';
          List<dynamic> products = data['similar_products'] ?? [];
          return {
            'message': msg,
            'similar_products': products,
          };
        }
        return {'message': data.toString(), 'similar_products': []};
      }

      return {'message': 'حدث خطأ في الاتصال بالسيرفر: ${response.statusCode}', 'similar_products': []};
    } on DioException catch (e) {
      return {'message': 'فشل الاتصال بالشبكة: ${e.message ?? e.toString()}', 'similar_products': []};
    } catch (e) {
      return {'message': 'حدث خطأ غير متوقع: $e', 'similar_products': []};
    }
  }
}
