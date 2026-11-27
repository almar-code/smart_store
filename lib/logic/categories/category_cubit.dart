import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_state.dart';
import '../../data/repos/category_repo.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepo repo;

  CategoryCubit(this.repo) : super(CategoryInitial());

  // silent يحدث بالخلفية بدون شاشة تحميل ويبقي البيانات عند الفشل
  Future<void> getCategories({bool silent = false}) async {
    if (!silent) emit(CategoryLoading());
    try {
      final categories = await repo.getCategories();
      if (isClosed) return;
      if (categories.isEmpty) {
        emit(CategoryEmpty());
      } else {
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      if (silent || isClosed) return;
      emit(
        CategoryError('فشل في جلب البيانات'),
      );
    }
  }
}
