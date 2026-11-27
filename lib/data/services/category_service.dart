import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';

class CategoryService {
  // حفظ الردود للعرض بدون انترنت
  final Dio dio = Dio()..interceptors.add(AppCache.interceptor);  Future<List<dynamic>> getCategories() async {
    final response = await dio.get(ApiEndpoints.getCategories);
    return response.data['sections'];
  }
}