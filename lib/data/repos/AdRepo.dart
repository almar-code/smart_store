import '../models/AdModel.dart';
import '../models/product_model.dart';
import '../services/AdService.dart';

class AdRepo {
  final AdService service;
  AdRepo(this.service);

  Future<List<AdModel>> fetchAds() async {
    final data = await service.getAds();
    return data.map<AdModel>((json) => AdModel.fromJson(json)).toList();
  }

  // 🌟 دالة جلب المنتجات الخاصة بإعلان معين من الجدول الوسيط
  Future<Map<String, dynamic>> fetchGeneralAdProducts(int adsId) async {
    final result = await service.getGeneralAdProducts(adsId);
    List<dynamic> productsJson = result['data'];
    List<ProductModel> products = productsJson.map((json) => ProductModel.fromJson(json)).toList();

    return {
      'ad_name': result['ad_name'],
      'products': products,
    };
  }
}