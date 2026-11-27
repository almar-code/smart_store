import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';
import '../local/user_local.dart';

class CartApiService {
  final Dio dio = Dio()..interceptors.add(AppCache.interceptor);
  Future<int?> _customerId() => UserLocal().getCustomerId();

  // 1. جلب محتويات السلة لعميل معين
  Future<Response> getCartRaw() async {
    try {
      final customerId =  await _customerId();
      final response = await dio.get(
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
      final customerId =  await _customerId();
      final response = await dio.post(
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
      final response = await dio.put(
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
      final response = await dio.delete(
        ApiEndpoints.deleteCartItem(cartItemId),
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في حذف الصنف من السلة: $e");
    }
  }
  // 5. تعديل لون او مقاس صنف في السلة
  Future<Response> updateCartOptionsRaw({required int cartItemId, int? colorId, int? sizeId}) async {
    try {
      final response = await dio.put(
        ApiEndpoints.updateCartItem(cartItemId),
        data: {
          if (colorId != null) 'color_id': colorId,
          if (sizeId != null) 'size_id': sizeId,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } on DioException catch (e) {
      // ارجاع رد السيرفر لعرض رسالته
      if (e.response != null) return e.response!;
      throw Exception("فشل في تعديل الصنف: $e");
    }
  }

  // 6. حذف كل اصناف السلة
  Future<Response> clearCartRaw() async {
    try {
      final customerId = await _customerId();
      final response = await dio.delete(
        ApiEndpoints.clearCart,
        queryParameters: {'customer_id': customerId},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في حذف السلة: $e");
    }
  }
}