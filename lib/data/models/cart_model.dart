import 'product_model.dart';

class CartModel {
  final int cartItemId;
  final int productId;
  final String productName;
  final String? productNameEn;
  final double productPrice;
  int quantity;
  final SizeModel? selectedSize;
  final ColorModel? selectedColor;
  final DiscountModel? discount;

  // بيانات المنتج الاضافية للتعديل والتفاصيل
  final String? productImage;
  final int subCatId;
  final String? productDescription;
  final String? productDescriptionEn;
  final List<ColorModel> productColors;
  final List<SizeModel> productSizes;

  CartModel({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.productNameEn,
    required this.productPrice,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.discount,
    this.productImage,
    this.subCatId = 0,
    this.productDescription,
    this.productDescriptionEn,
    this.productColors = const [],
    this.productSizes = const [],
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartItemId: json['cart_id'],
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

      productImage: json['p_image'],
      subCatId: json['subcat_id'] ?? 0,
      productDescription: json['p_description'],
      productDescriptionEn: json['p_description_en'],

      // الالوان والمقاسات المتاحة للمنتج
      productColors: json['product_colors'] != null
          ? (json['product_colors'] as List).map((c) => ColorModel.fromJson(c)).toList()
          : [],
      productSizes: json['product_sizes'] != null
          ? (json['product_sizes'] as List).map((s) => SizeModel.fromJson(s)).toList()
          : [],
    );
  }

  // سعر القطعة بعد الخصم
  double get unitPrice => discount?.discountPerce != null ? productPrice - discount!.discountPerce! : productPrice;

  // اجمالي الصنف
  double get lineTotal => unitPrice * quantity;

  // نسبة الخصم
  int get discountPercent {
    if (discount?.discountPerce == null || productPrice <= 0) return 0;
    return ((discount!.discountPerce! / productPrice) * 100).round();
  }

  // صورة اللون المختار او صورة المنتج
  String? get displayImage {
    final images = selectedColor?.images ?? [];
    return images.isNotEmpty ? images.first.imgUrl : productImage;
  }

  // هل يمكن تعديل اللون او المقاس
  bool get canEditOptions => productColors.length > 1 || productSizes.length > 1;

  // نسخة معدلة من الصنف
  CartModel copyWith({ColorModel? selectedColor, SizeModel? selectedSize, int? quantity}) {
    return CartModel(
      cartItemId: cartItemId,
      productId: productId,
      productName: productName,
      productNameEn: productNameEn,
      productPrice: productPrice,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      discount: discount,
      productImage: productImage,
      subCatId: subCatId,
      productDescription: productDescription,
      productDescriptionEn: productDescriptionEn,
      productColors: productColors,
      productSizes: productSizes,
    );
  }

  // تحويل الصنف الى منتج لفتح التفاصيل والمشاركة
  ProductModel toProduct() {
    return ProductModel(
      pId: productId,
      subCatId: subCatId,
      pName: productName,
      pNameEn: productNameEn,
      pDescription: productDescription,
      pDescriptionEn: productDescriptionEn,
      pPrice: productPrice,
      pImage: productImage ?? displayImage,
      colors: productColors,
      sizes: productSizes,
      generalAdvertisements: const [],
      discount: discount,
    );
  }
}