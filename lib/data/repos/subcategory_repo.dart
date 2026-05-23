import '../models/subcategory_model.dart';
import '../services/subcategory_service.dart';

class SubcategoryRepo {
  final SubcategoryService service;

  SubcategoryRepo(this.service);

  // 🔹 أضفنا الباراميتر الاختياري {int? categoryId} هنا
  Future<List<SubcategoryModel>> getSubcategories({int? categoryId}) async {
    // 🔹 ممرر الـ id إلى الـ service
    final data = await service.getSubcategories(categoryId: categoryId);

    return data.map<SubcategoryModel>(
          (json) => SubcategoryModel.fromJson(json),
    ).toList();
  }
}