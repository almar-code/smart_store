import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';

class CategoryService {
  final Dio dio = Dio();
  Future<List<dynamic>> getCategories() async {
    final response = await dio.get(ApiEndpoints.getCategories);
    return response.data['sections'];
  }
}