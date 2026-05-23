// data/repositories/product_repository.dart
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepo {
  final ProductService apiService;

  ProductRepo({required this.apiService});

  Future<Map<String, dynamic>> fetchProductsPaginated({int? subCatId, int? categoryId,int? productId, required int page ,int? seed,bool isDiscount = false}) async {
    try {
      final Response response = await apiService.getProductsRaw(subCatId: subCatId,categoryId: categoryId,productId: productId, page: page ,seed: seed,isDiscount: isDiscount);

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
}