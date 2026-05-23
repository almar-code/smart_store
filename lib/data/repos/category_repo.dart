import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryRepo {
  final CategoryService service;
  CategoryRepo(this.service);

  Future<List<CategoryModel>> getCategories() async {
    final data = await service.getCategories();

    return data
        .map<CategoryModel>(
          (json) => CategoryModel.fromJson(json),
    ).toList();
  }
}