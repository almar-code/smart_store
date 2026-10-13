import 'package:dio/dio.dart';

import '../../core/constants/app_endpoints.dart';

class AdService {
  final Dio dio = Dio();

  Future<List<dynamic>> getAds() async {
    final response = await dio.get(ApiEndpoints.getAllAds);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getGeneralAdProducts(int adsId) async {
    final response = await dio.get(ApiEndpoints.generalAdProducts(adsId));
    return response.data; // يرجع اسم الإعلان ولستة المنتجات
  }
}