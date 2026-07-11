// data/repositories/product_repository.dart
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepo {
  final ProductService apiService;

  ProductRepo({required this.apiService});

  Future<Map<String, dynamic>> fetchProductsPaginated({int? subCatId, int? categoryId,int? productId, required int page,String? date ,int? seed,bool isDiscount = false,bool isFavorite = false,int? customerId}) async {
    try {
      final Response response = await apiService.getProductsRaw(subCatId: subCatId,categoryId: categoryId,productId: productId, page: page ,seed: seed,date: date,isDiscount: isDiscount,isFavorite: isFavorite,customerId :customerId);

      if (response.statusCode == 200) {
        // الـ Dio يقوم بتحليل الـ JSON تلقائياً إلى Map، لذا نصل لـ response.data مباشرة
        final Map<String, dynamic> responseData = response.data;

        if (responseData['status'] == true) {
          final List<dynamic> productsData = responseData['data'];
          final bool hasMore = responseData['meta']['has_more'];
          List<ProductModel> productsList = productsData.map((p) => ProductModel.fromJson(p)).toList();
          return {
            'products': productsList,
            'hasMore': hasMore,
            'seed': responseData['meta']['seed'],
          };
        } else {
          throw Exception(responseData['message'] ?? "Unknown error occurred");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Repository Error: $e");
    }
  }
  // 🌟 دالة تفعيل أو إلغاء المفضلة وإرجاع الحالة الجديدة للمنتج
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