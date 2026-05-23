// model/product_model.dart

// model/product_model.dart

class ProductModel {
  final int pId;
  final int subCatId;
  final String pName;
  final String? pNameEn;
  final String? pDescription;
  final String? pDescriptionEn;
  final double pPrice;
  final String? pImage; // 🌟 إضافة المتغير الجديد هنا
  final List<ColorModel> colors;
  final DiscountModel? discount;

  ProductModel({
    required this.pId,
    required this.subCatId,
    required this.pName,
    this.pNameEn,
    this.pDescription,
    this.pDescriptionEn,
    required this.pPrice,
    this.pImage, // 🌟 تمريره في الـ Constructor
    required this.colors,
    this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      pId: json['p_id'],
      subCatId: json['subcat_id'],
      pName: json['p_name'],
      pNameEn: json['p_name_en'],
      pDescription: json['p_description'],
      pDescriptionEn: json['p_description_en'],
      pPrice: double.parse(json['p_price'].toString()),
      pImage: json['p_image'], // 🌟 هنا يتم قراءة اسم الصورة الصحيح من الـ JSON
      colors: json['colors'] != null
          ? (json['colors'] as List).map((c) => ColorModel.fromJson(c)).toList()
          : [],
      discount: json['discount'] != null ? DiscountModel.fromJson(json['discount']) : null,
    );
  }
}
class ColorModel {
  final int colorId;
  final String colorName;
  final String? colorNameEn;
  final String? colorCode;

  ColorModel({
    required this.colorId,
    required this.colorName,
    this.colorNameEn,
    this.colorCode,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      colorId: json['color_id'],
      colorName: json['color_name'],
      colorNameEn: json['color_name_en'],
      colorCode: json['color_code'],
    );
  }
}

class DiscountModel {
  final int? discountId;
  final int? discountPerce;
  final int? duration;

  DiscountModel({
    required this.discountId,
    required this.discountPerce,
    required this.duration,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      discountId: json['discount_id'],
      discountPerce: json['discount_perce'],
      duration: json['duration'],
    );
  }
}