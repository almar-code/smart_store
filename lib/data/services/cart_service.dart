import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_endpoints.dart';

class CartApiService {
  final Dio _dio = Dio();
  final box = Hive.box('user_info_box');

  // 1. جلب محتويات السلة لعميل معين
  Future<Response> getCartRaw() async {
    try {
      final customerId = (box.isEmpty) ? '' :  box.get('customer_id');
      final response = await _dio.get(
        ApiEndpoints.getCart,
        queryParameters: {'customer_id': customerId},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في جلب بيانات السلة: $e");
    }
  }

  // 2. إضافة منتج للسلة
  Future<Response> addToCartRaw({
    required int productId,
    int? colorId,
    int? sizeId,
  }) async {
    try {
      final customerId = (box.isEmpty) ? '' :  box.get('customer_id');
      final response = await _dio.post(
        ApiEndpoints.addToCart,
        data: {
          'customer_id': customerId,
          'product_id': productId,
          if (colorId != null) 'color_id': colorId,
          if (sizeId != null) 'size_id': sizeId,
          'quantity': 1,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في إضافة المنتج إلى السلة: $e");
    }
  }

  // 3. تحديث كمية المنتج في السلة (الزيادة والنقصان)
  Future<Response> updateCartQuantityRaw({required int cartItemId, required int quantity}) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateCartItem(cartItemId),
        data: {'quantity': quantity},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في تحديث كمية السلة: $e");
    }
  }

  // 4. حذف صنف تماماً من السلة
  Future<Response> deleteCartItemRaw({required int cartItemId}) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteCartItem(cartItemId),
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في حذف الصنف من السلة: $e");
    }
  }
}