import 'package:flutter_bloc/flutter_bloc.dart';
import 'subcategory_state.dart';
import '../../data/repos/subcategory_repo.dart';

class SubcategoryCubit extends Cubit<SubcategoryState> {
  final SubcategoryRepo repo;

  SubcategoryCubit(this.repo) : super(SubcategoryInitial());

  // 🔹 أضفنا الباراميتر الاختياري هنا أيضاً
  Future<void> getSubcategories({int? categoryId}) async {
    emit(SubcategoryLoading());
    try {
      // تمرير المعرف المختار إلى الـ repo
      final subcategories = await repo.getSubcategories(categoryId: categoryId);
      emit(SubcategoryLoaded(subcategories));
    } catch (e) {
      emit(SubcategoryError('فشل في جلب الفئات الفرعية'));
    }
  }
}