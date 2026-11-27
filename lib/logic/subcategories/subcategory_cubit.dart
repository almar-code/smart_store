import 'package:flutter_bloc/flutter_bloc.dart';
import 'subcategory_state.dart';
import '../../data/repos/subcategory_repo.dart';

class SubcategoryCubit extends Cubit<SubcategoryState> {
  final SubcategoryRepo repo;

  SubcategoryCubit(this.repo) : super(SubcategoryInitial());

  // اخر قسم تم طلبه للتحديث الصامت
  int? _lastCategoryId;

  // 🔹 أضفنا الباراميتر الاختياري هنا أيضاً
  Future<void> getSubcategories({int? categoryId, bool silent = false}) async {
    _lastCategoryId = categoryId;
    if (!silent) emit(SubcategoryLoading());
    try {
      // تمرير المعرف المختار إلى الـ repo
      final subcategories = await repo.getSubcategories(categoryId: categoryId);
      if (isClosed) return;
      emit(SubcategoryLoaded(subcategories));
    } catch (e) {
      if (silent || isClosed) return;
      emit(SubcategoryError('فشل في جلب الفئات الفرعية'));
    }
  }

  // تحديث بالخلفية بنفس القسم الحالي
  Future<void> refreshSilently() => getSubcategories(categoryId: _lastCategoryId, silent: true);
}
