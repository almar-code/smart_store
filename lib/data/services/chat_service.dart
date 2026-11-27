import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

import '../../core/constants/app_endpoints.dart';
import '../../core/utils/device_id_helper.dart';

class ChatService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<Map<String, dynamic>> sendPrompt({
    required String message,
    Uint8List? image,
    String? imageName,
  }) async {
    try {
      final String? token =
          Supabase.instance.client.auth.currentSession?.accessToken;
      final String deviceId = await DeviceIdHelper.get();

      final dynamic requestData = image != null
          ? FormData.fromMap({
        'device_id': deviceId,
        'message': message,
        'image': MultipartFile.fromBytes(
          image,
          filename: imageName ?? 'image.jpg',
        ),
      })
          : {
        'device_id': deviceId,
        'message': message,
      };

      final response = await _dio.post(
        ApiEndpoints.n8nChatAgent,
        data: requestData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map) {
          final String msg = data['message'] ?? data['output'] ?? 'لم أتمكن من فهم الرد.';
          final List<dynamic> products = data['similar_products'] ?? [];
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