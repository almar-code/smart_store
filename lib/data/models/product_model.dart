// model/product_model.dart

import 'package:smart_store/data/models/video_model.dart';

class ProductModel {
  final int pId;
  final int subCatId;
  final String pName;
  final String? pNameEn;
  final String? pDescription;
  final String? pDescriptionEn;
  final double pPrice;
  final String? pImage;
  final List<ColorModel> colors;
  final List<SizeModel> sizes; //  إضافة قائمة المقاسات الجديدة
  final DiscountModel? discount;
  final int? videoID;
  bool isFavorite;

  ProductModel({
    required this.pId,
    required this.subCatId,
    required this.pName,
    this.pNameEn,
    this.pDescription,
    this.pDescriptionEn,
    required this.pPrice,
    this.pImage,
    required this.colors,
    required this.sizes, //  تمرير المقاسات
    this.discount,
    this.videoID,
    this.isFavorite = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      pId: json['p_id'],
      subCatId: json['subcat_id'],
      pName: json['p_name'],
      pNameEn: json['p_name_en'],
      pDescription: json['p_description'],
      pDescriptionEn: json['p_description_en'],
      pPrice: json['p_price'] != null
          ? (double.tryParse(json['p_price'].toString()) ?? 0.0)
          : 0.0,
      pImage: json['p_image'],
      colors: json['colors'] != null
          ? (json['colors'] as List).map((c) => ColorModel.fromJson(c)).toList()
          : [],
      //  تحويل المقاسات القادمة من لارافيل إلى قائمة كائنات فلاتر
      sizes: json['sizes'] != null
          ? (json['sizes'] as List).map((s) => SizeModel.fromJson(s)).toList()
          : [],
      discount: json['discount'] != null ? DiscountModel.fromJson(json['discount']) : null,
      videoID: json['video_id'],
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
    );
  }
}

class ColorModel {
  final int colorId;
  final String colorName;
  final String? colorNameEn;
  final String? colorCode;
  final List<ProductImageModel> images; //  إضافة قائمة الصور التابعة لكل لون

  ColorModel({
    required this.colorId,
    required this.colorName,
    this.colorNameEn,
    this.colorCode,
    required this.images, //  تمرير الصور
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      colorId: json['color_id'],
      colorName: json['color_name'],
      colorNameEn: json['color_name_en'],
      colorCode: json['color_code'],
      //  تحويل مصفوفة الصور المتداخلة القادمة من السيرفر
      images: json['images'] != null
          ? (json['images'] as List).map((img) => ProductImageModel.fromJson(img)).toList()
          : [],
    );
  }
}

//  موديل صور المنتج الجديد المتطابق مع جدول product_images
class ProductImageModel {
  final int imgId;
  final String imgUrl;
  final int colorId;

  ProductImageModel({
    required this.imgId,
    required this.imgUrl,
    required this.colorId,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imgId: json['img_id'],
      imgUrl: json['img_url'] ?? '',
      colorId: json['color_id'],
    );
  }
}

//  موديل المقاسات الجديد المتطابق مع جدول sizes
class SizeModel {
  final int sizeId;
  final String sizeName;
  final int pId;

  SizeModel({
    required this.sizeId,
    required this.sizeName,
    required this.pId,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      sizeId: json['size_id'],
      sizeName: json['size_name'].toString(), // تحويل النص أو الرقم بأمان
      pId: json['p_id'] ?? 0,
    );
  }
}

class DiscountModel {
  final int? discountId;
  final double? discountPerce;
  final String? endDate; // تم تغيير الاسماء لتطابق الاستجابة الفعلية لارافيل end_date

  DiscountModel({
    required this.discountId,
    required this.discountPerce,
    required this.endDate,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      discountId: json['discount_id'],
      discountPerce: json['discount_perce'] != null
          ? double.tryParse(json['discount_perce'].toString())
          : null,
      endDate: json['end_date'], // مطابقة مباشرة مع الـ JSON
    );
  }
}