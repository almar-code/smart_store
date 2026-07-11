import 'product_model.dart';

class CartModel {
  final int cartId;
  final int productId;
  final String productName;
  final String? productNameEn;
  final double productPrice;
  int quantity;
  final SizeModel? selectedSize;
  final ColorModel? selectedColor;
  final DiscountModel? discount;

  CartModel({
    required this.cartId,
    required this.productId,
    required this.productName,
    this.productNameEn,
    required this.productPrice,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.discount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cart_id'],
      productId: json['product_id'],
      // قراءة بيانات المنتج الأساسية الممررة بشكل مسطح أو متداخل من لارافيل
      productName: json['p_name'] ?? json['product']?['p_name'] ?? '',
      productNameEn: json['p_name_en'] ?? json['product']?['p_name_en'],
      productPrice: double.parse((json['p_price'] ?? json['product']?['p_price'] ?? 0).toString()),
      quantity: json['quantity'] ?? 1,

      // تحليل المقاس المختار إن وجد
      selectedSize: json['size'] != null ? SizeModel.fromJson(json['size']) : null,

      // تحليل اللون المختار مع صوره المتداخلة إن وجد
      selectedColor: json['color'] != null ? ColorModel.fromJson(json['color']) : null,

      // تحليل الخصم النشط للمنتج إن وجد
      discount: json['discount'] != null
          ? DiscountModel.fromJson(json['discount'])
          : (json['product']?['discount'] != null ? DiscountModel.fromJson(json['product']['discount']) : null),
    );
  }
}