// data/services/product_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';

class FavoriteService {
  final Dio dio = Dio();

  Future<Response> getFavoriteCountRaw({required int customerId}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.favoriteCount??"",
        queryParameters: {
          'customer_id': customerId,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to get favorite count: $e");
    }
  }
  // 🌟 دالة تفعيل أو إلغاء المفضلة بضغط زر واحدة (Toggle)
  Future<Response> toggleFavoriteRaw({
    required int customerId,
    required int productId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.toggleFavorite, // رابط الـ POST الخاص بالتعديل
        data: {
          'customer_id': customerId,
          'product_id': productId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to toggle favorite status: $e");
    }
  }
}