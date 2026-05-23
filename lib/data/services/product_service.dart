// data/services/product_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';

class ProductService {
  final Dio dio = Dio();

  Future<Response> getProductsRaw({int? subCatId, int? categoryId,int? productId, required int page ,int? seed,bool isDiscount = false}) async {
    try {
      // تجهيز رقم الصفحة كمعامل أساسي
      Map<String, dynamic> queryParams = {'page': page};

      if (subCatId != null) queryParams['subCatId'] = subCatId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (productId != null) queryParams['product_id'] = productId;
      if (isDiscount) queryParams['is_discount'] = isDiscount;
      if (seed != null) queryParams['seed'] = seed;

      final response = await dio.get(
        ApiEndpoints.getProducts,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to connect to the server: $e");
    }
  }}