import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartRepository {
  final CartApiService _cartApiService;

  CartRepository(this._cartApiService);

  // جلب السلة وتحويل مصفوفة الـ JSON إلى List<CartModel>
  Future<List<CartModel>> getCartItems() async {
    final response = await _cartApiService.getCartRaw();

    if (response.statusCode == 200 && response.data['status'] == true) {
      final List data = response.data['data'];
      return data.map((json) => CartModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'حدث خطأ ما أثناء جلب السلة');
    }
  }

  // إضافة منتج وإعادة النتيجة كـ Boolean
  // داخل ملف cart_repo.dart
  Future<String> addToCart({
    required int productId,
    int? colorId,
    required int sizeId,
  }) async {
    try {
      final response = await _cartApiService.addToCartRaw(
        productId: productId,
        colorId: colorId,
        sizeId: sizeId,
      );

      // لارافيل يرجع status إما true أو false
      if (response.data['status'] == true) {
        return response.data['message']; // 🌟 إرجاع الرسالة القادمة من لارافيل
      } else {
        throw Exception(response.data['message'] ?? " لم يتم اضافة المنتج الى السلة");
      }
    } catch (e) {
      // معالجة أخطاء الـ Validator (كود 420) أو أي خطأ شبكة
      throw Exception(e.toString());
    }
  }

  // تحديث كمية الصنف
  Future<bool> updateQuantity({required int cartItemId, required int quantity}) async {
    final response = await _cartApiService.updateCartQuantityRaw(cartItemId: cartItemId, quantity: quantity);
    return response.statusCode == 200;
  }

  // حذف الصنف من السلة
  Future<bool> deleteItem({required int cartItemId}) async {
    final response = await _cartApiService.deleteCartItemRaw(cartItemId: cartItemId);
    return response.statusCode == 200;
  }
  // تعديل اللون او المقاس وارجاع هل تم الدمج مع صنف مطابق
  Future<bool> updateOptions({required int cartItemId, int? colorId, int? sizeId}) async {
    final response = await _cartApiService.updateCartOptionsRaw(cartItemId: cartItemId, colorId: colorId, sizeId: sizeId);
    if (response.statusCode == 200 && response.data['status'] == true) {
      return response.data['merged'] == true;
    }
    throw Exception(response.data['message'] ?? 'تعذر تعديل الصنف');
  }

  // حذف كل اصناف السلة
  Future<bool> clearCart() async {
    final response = await _cartApiService.clearCartRaw();
    return response.statusCode == 200;
  }
}