import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';

class SubcategoryService {
  // حفظ الردود للعرض بدون انترنت
  final Dio dio = Dio()..interceptors.add(AppCache.interceptor);
  Future<List<dynamic>> getSubcategories({int? categoryId}) async {
    // تجهيز الـ query parameters إذا تم تمرير الـ id
    Map<String, dynamic> queryParams = {};
    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }

    final response = await dio.get(
      ApiEndpoints.getSubCategories,
      queryParameters: queryParams, // تمرير الباراميترز لـ Dio
    );

    return response.data['subcategories'];
  }
}