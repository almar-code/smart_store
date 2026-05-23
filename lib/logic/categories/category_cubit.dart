import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_state.dart';
import '../../data/repos/category_repo.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepo repo;

  CategoryCubit(this.repo) : super(CategoryInitial());

  Future<void> getCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await repo.getCategories();
      if (categories.isEmpty) {
        emit(CategoryEmpty());
      } else {
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      emit(
        CategoryError('فشل في جلب البيانات'),
      );
    }
  }
}