// data/repositories/product_repository.dart
import 'package:dio/dio.dart';
import 'package:smart_store/data/services/favorite_service.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class FavoriteRepo {
  final FavoriteService apiService;

  FavoriteRepo({required this.apiService});

  Future<int> getFavoriteCount({required int customerId}) async {
    try {
      final Response response = await apiService.getFavoriteCountRaw(
        customerId: customerId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == true) {
          return responseData['favorite_count'] ?? 0;
        } else {
          print("sssssssssssssssssssssssssssssssssssss");
          throw Exception(responseData['message'] ?? "Failed to get count");
        }
      } else {
        print("sssssssssssssssssssssssssssssssssssss");

        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("sssssssssssssssssssssssssssssssssssss");

      throw Exception("Repository Error: $e");
    }
  }
  Future<bool> toggleProductFavorite({
    required int customerId,
    required int productId,
  }) async {
    try {
      final Response response = await apiService.toggleFavoriteRaw(
        customerId: customerId,
        productId: productId,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['status'] == true) {
          // إرجاع قيمة true إذا تم الإضافة، أو false إذا تم الحذف من المفضلة
          return responseData['is_favorite'] ?? false;
        } else {
          throw Exception(responseData['message'] ?? "Failed to toggle favorite");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Repository Error: $e");
    }
  }
}