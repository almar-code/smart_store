import 'package:dio/dio.dart';

import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';

class AdService {
  // حفظ الردود للعرض بدون انترنت
  final Dio dio = Dio()..interceptors.add(AppCache.interceptor);

  Future<List<dynamic>> getAds() async {
    final response = await dio.get(ApiEndpoints.getAllAds);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getGeneralAdProducts(int adsId) async {
    final response = await dio.get(ApiEndpoints.generalAdProducts(adsId));
    return response.data; // يرجع اسم الإعلان ولستة المنتجات
  }
}