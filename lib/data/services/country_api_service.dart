import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';

class CountryApiService {
  final Dio dio = Dio();

  Future<List<dynamic>> fetchCountries() async {
    final response = await dio.get(ApiEndpoints.getCountry);


    final data = response.data;

    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      /// غيّر المفتاح هنا بعد ما نشوف شكل البيانات
      return data['data'] as List<dynamic>;
    }

    throw Exception('Invalid countries response');
  }
}