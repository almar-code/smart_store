class CategoryModel {
  final int id;
  final String name;
  final String? nameEn;

  CategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['cat_id'],
      name: json['cat_name'],
      nameEn: json['cat_name_en'],
    );
  }
}