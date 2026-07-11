
import '../../data/models/cart_model.dart';

abstract class CartState {}

// 1. الحالة الابتدائية
class CartInitial extends CartState {}

// 2. حالات جلب وعرض السلة (Fetch Cart)
class CartLoading extends CartState {}
class CartEmpty extends CartState {}

class CartLoaded extends CartState {
  final List<CartModel> cartItems;
  final double totalPrice;      // 🌟 تم تحويلها إلى final للاستقرار
  final double totalDiscount;   // 🌟 تم تحويلها إلى final للاستقرار

  // تعيين قيم افتراضية بصفر إذا لم يتم تمريرها
  CartLoaded(
      this.cartItems, {
        this.totalPrice = 0.0,
        this.totalDiscount = 0.0,
      });
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

// 3. حالات إضافة منتج للسلة (Add To Cart)
class CartAdding extends CartState {}

class CartAddedSuccess extends CartState {
  final String message;
  CartAddedSuccess(this.message);
}

// 4. حالات عمليات التحديث والحذف (Action States)
// نستخدم هذه الحالات لإشعار واجهة المستخدم بالنجاح أو الفشل السريع (مثل إظهار SnackBar)
class CartActionLoading extends CartState {}

class CartActionSuccess extends CartState {
  final String message;
  CartActionSuccess(this.message);
}