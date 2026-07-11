import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/widgets/app_messages.dart';
import 'package:smart_store/data/models/cart_model.dart';
import '../../data/repos/cart_repo.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit(this._cartRepository) : super(CartInitial());
  List<CartModel> allProducts = [];
  double totalPrice = 0;
  double totalDiscount = 0;
  int itemCount = 0 ;

  // 📥 1. جلب محتويات السلة
  Future<void> fetchCart({required int customerId}) async {
    emit(CartLoading());
    try {
      allProducts.clear();
      final List<CartModel> items = await _cartRepository.getCartItems(customerId: customerId);
      if (items.isEmpty) {
        emit(CartEmpty());
        return;
      }
      allProducts.addAll(items);

      // حساب الإجمالي أولاً قبل عمل emit للحالة Loaded
      totalAccount();

      emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  // ➕ 2. إضافة صنف جديد للسلة
  Future<void> addToCart({
    required int customerId,
    required int productId,
    int? colorId,
    required int sizeId,
    required BuildContext context
  }) async {
    emit(CartAdding());
    try {
      final String serverMessage = await _cartRepository.addToCart(
        customerId: customerId,
        productId: productId,
        colorId: colorId,
        sizeId: sizeId,
      );

      AppToasts.showSuccessToast(context, serverMessage);
      fetchCart(customerId: customerId);
    } catch (e) {
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      AppToasts.showErrorToast(context, errorMessage);
    }
  }

  // 🔄 3. تحديث كمية المنتج (زيادة أو نقصان)
  Future<void> updateItemQuantity({
    required int customerId,
    required CartModel product,
    required int newQuantity,
  }) async {
    try {
      int oldQuantity = 0;
      allProducts = allProducts.map((p) {
        if (p.cartId == product.cartId) {
          oldQuantity = p.quantity;
          p.quantity = newQuantity;
        }
        return p;
      }).toList();

      // إعادة الحساب فوراً لكي تظهر القيم الجديدة للعميل في الواجهة مباشرة
      totalAccount();
      emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));

      final success = await _cartRepository.updateQuantity(cartId: product.cartId, quantity: newQuantity);

      if (!success) {
        allProducts = allProducts.map((p) {
          if (p.cartId == product.cartId) {
            p.quantity = oldQuantity;
          }
          return p;
        }).toList();
        totalAccount();
        emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  // ❌ 4. حذف صنف من السلة
  Future<void> deleteItemFromCart({
    required int customerId,
    required int cartId,
    required CartModel product,
    required BuildContext context
  }) async {
    final int itemIndex = allProducts.indexWhere((p) => p.cartId == cartId);
    try {
      if (itemIndex != -1) {
        allProducts.removeAt(itemIndex);
        if (allProducts.isEmpty) {
          emit(CartEmpty());
        } else {
          totalAccount(); // إعادة الحساب فور الحذف المحامي بالواجهة
          emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));
        }
      }

      final success = await _cartRepository.deleteItem(cartId: cartId);

      if (success) {
        if (allProducts.isEmpty) {
          emit(CartEmpty());
        }else{
          AppToasts.showSuccessToast(context, 'تم حذف المنتج بنجاح');
        }
      } else {
        if (itemIndex != -1) {
          allProducts.insert(itemIndex, product);
          totalAccount();
          emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));
        }
        AppToasts.showErrorToast(context, 'لم يتم حذف المنتج ');
      }
    } catch (e) {
      if (itemIndex != -1) {
        allProducts.insert(itemIndex, product);
        totalAccount();
        emit(CartLoaded(List.from(allProducts), totalDiscount: totalDiscount, totalPrice: totalPrice));
      }
      AppToasts.showErrorToast(context, 'لم يتم حذف المنتج ');
    }
  }

  // 🧮 دالة الحساب بعد التعديل الجذري
  void totalAccount() {
    // 🌟 1. تصفير العدادات في بداية الدالة لمنع تراكم الأرقام وتضاعفها مع كل تحديث
    totalPrice = 0;
    totalDiscount = 0;
    itemCount = 0;

    // 🌟 2. استخدام حلقة for...in صريحة ومباشرة لتجنب كسل دالة .map()
    if(allProducts.isNotEmpty) {
      for (var p in allProducts) {
        // السعر الإجمالي = السعر الأصلي للمنتج × الكمية المطلوبة
        itemCount += p.quantity;
        totalPrice += (p.productPrice * p.quantity);
        // إجمالي الخصم = قيمة الخصم للمنتج الواحد × الكمية المطلوبة
        if (p.discount != null && p.discount!.discountPerce != null) {
          totalDiscount += (p.discount!.discountPerce! * p.quantity);
        }
      }
    }

  }
}