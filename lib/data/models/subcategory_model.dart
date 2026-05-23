class SubcategoryModel {
  final int subcatId;
  final String subcatName;
  final String? subcatNameEn;
  final String? subcatImage;
  final int catId;

  SubcategoryModel({
    required this.subcatId,
    required this.subcatName,
    this.subcatNameEn,
    this.subcatImage,
    required this.catId,
  });

  // دالة تحويل الـ JSON اليدوية
  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      subcatId: json['subcat_id'] as int,
      subcatName: json['subcat_name'] as String,
      subcatNameEn: json['subcat_name_en'] as String?,
      subcatImage: json['subcat_image'] as String?,
      catId: json['cat_id'] as int,
    );
  }
}