import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/widgets/app_messages.dart';
import 'package:smart_store/data/models/cart_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repos/cart_repo.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit(this._cartRepository) : super(CartInitial());
  List<CartModel> allProducts = [];
  double totalPrice = 0;
  double totalDiscount = 0;
  int itemCount = 0;

  // مؤقتات تأخير ارسال الكمية لكل صنف
  final Map<int, Timer> _quantityTimers = {};
  // اخر كمية مؤكدة من السيرفر لكل صنف
  final Map<int, int> _confirmedQuantities = {};

  // اصدار الحالة بعد اعادة الحساب
  void _emitCart() {
    totalAccount();
    if (allProducts.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));
    }
  }

  // 1. جلب محتويات السلة (silent بدون حالة تحميل للسحب للتحديث)
  Future<void> fetchCart({bool silent = false}) async {
    if (!silent || state is! CartLoaded) emit(CartLoading());
    try {
      final List<CartModel> items = await _cartRepository.getCartItems();
      allProducts
        ..clear()
        ..addAll(items);
      _confirmedQuantities
        ..clear()
        ..addEntries(items.map((e) => MapEntry(e.cartItemId, e.quantity)));
      _emitCart();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  // 2. إضافة صنف جديد للسلة
  Future<void> addToCart({
    required int productId,
    int? colorId,
    required int sizeId,
    required BuildContext context
  }) async {
    emit(CartAdding());
    try {
      final String serverMessage = await _cartRepository.addToCart(
        productId: productId,
        colorId: colorId,
        sizeId: sizeId,
      );

      AppToasts.showSuccessToast(context, serverMessage);
      fetchCart();
    } catch (e) {
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      AppToasts.showErrorToast(context, errorMessage);
    }
  }

  // 3. تحديث الكمية فورا بالواجهة وارسالها للسيرفر بعد توقف الضغط
  void updateItemQuantity({
    required CartModel product,
    required int newQuantity,
  }) {
    if (newQuantity < 1) return;
    final index = allProducts.indexWhere((p) => p.cartItemId == product.cartItemId);
    if (index == -1) return;

    allProducts[index].quantity = newQuantity;
    _emitCart();

    _quantityTimers[product.cartItemId]?.cancel();
    _quantityTimers[product.cartItemId] = Timer(const Duration(milliseconds: 450), () {
      _sendQuantity(product.cartItemId, newQuantity);
    });
  }

  Future<void> _sendQuantity(int cartItemId, int quantity) async {
    _quantityTimers.remove(cartItemId);
    bool success = false;
    try {
      success = await _cartRepository.updateQuantity(cartItemId: cartItemId, quantity: quantity);
    } catch (_) {}

    if (isClosed) return;
    final index = allProducts.indexWhere((p) => p.cartItemId == cartItemId);
    if (success) {
      _confirmedQuantities[cartItemId] = quantity;
    } else if (index != -1) {
      // ارجاع اخر كمية مؤكدة عند الفشل
      allProducts[index].quantity = _confirmedQuantities[cartItemId] ?? allProducts[index].quantity;
      _emitCart();
    }
  }

  // 4. حذف صنف من السلة
  Future<void> deleteItemFromCart({
    required int cartItemId,
    required CartModel product,
    required BuildContext context,
    bool showToast = true,
  }) async {
    _quantityTimers.remove(cartItemId)?.cancel();
    final int itemIndex = allProducts.indexWhere((p) => p.cartItemId == cartItemId);
    if (itemIndex != -1) {
      allProducts.removeAt(itemIndex);
      _emitCart();
    }

    bool success = false;
    try {
      success = await _cartRepository.deleteItem(cartItemId: cartItemId);
    } catch (_) {}

    if (isClosed) return;
    if (success) {
      _confirmedQuantities.remove(cartItemId);
      if (showToast && context.mounted) AppToasts.showSuccessToast(context, tr('cart_item_deleted'));
    } else {
      // ارجاع الصنف عند الفشل
      if (itemIndex != -1) {
        allProducts.insert(itemIndex.clamp(0, allProducts.length), product);
        _emitCart();
      }
      if (context.mounted) AppToasts.showErrorToast(context, tr('cart_item_delete_failed'));
    }
  }

  // 5. تعديل لون او مقاس الصنف
  Future<bool> updateItemOptions({
    required CartModel product,
    ColorModel? color,
    SizeModel? size,
    required BuildContext context,
  }) async {
    final index = allProducts.indexWhere((p) => p.cartItemId == product.cartItemId);
    if (index == -1) return false;

    final old = allProducts[index];
    allProducts[index] = old.copyWith(selectedColor: color, selectedSize: size);
    _emitCart();

    try {
      final merged = await _cartRepository.updateOptions(
        cartItemId: product.cartItemId,
        colorId: color?.colorId,
        sizeId: size?.sizeId,
      );
      if (merged) {
        // اعادة الجلب بعد دمج الصنف مع صنف مطابق
        await fetchCart(silent: true);
        if (context.mounted) AppToasts.showSuccessToast(context, tr('cart_item_merged'));
      } else if (context.mounted) {
        AppToasts.showSuccessToast(context, tr('cart_item_updated'));
      }
      return true;
    } catch (e) {
      final i = allProducts.indexWhere((p) => p.cartItemId == product.cartItemId);
      if (i != -1) allProducts[i] = old;
      _emitCart();
      if (context.mounted) {
        AppToasts.showErrorToast(context, e.toString().replaceAll("Exception: ", ""));
      }
      return false;
    }
  }

  // 6. حذف كل المنتجات من السلة
  Future<void> clearCart({required BuildContext context}) async {
    for (final t in _quantityTimers.values) {
      t.cancel();
    }
    _quantityTimers.clear();

    final backup = List<CartModel>.from(allProducts);
    allProducts.clear();
    _emitCart();

    bool success = false;
    try {
      success = await _cartRepository.clearCart();
    } catch (_) {}

    if (isClosed) return;
    if (success) {
      _confirmedQuantities.clear();
      if (context.mounted) AppToasts.showSuccessToast(context, tr('cart_cleared'));
    } else {
      allProducts.addAll(backup);
      _emitCart();
      if (context.mounted) AppToasts.showErrorToast(context, tr('cart_clear_failed'));
    }
  }

  // دالة حساب الاجماليات
  void totalAccount() {
    totalPrice = 0;
    totalDiscount = 0;
    itemCount = 0;

    for (var p in allProducts) {
      itemCount += p.quantity;
      totalPrice += (p.productPrice * p.quantity);
      if (p.discount != null && p.discount!.discountPerce != null) {
        totalDiscount += (p.discount!.discountPerce! * p.quantity);
      }
    }
  }

  @override
  Future<void> close() {
    for (final t in _quantityTimers.values) {
      t.cancel();
    }
    return super.close();
  }
}