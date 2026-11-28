import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/saved_size_model.dart';
import '../../data/repos/saved_sizes_repo.dart';
import 'saved_sizes_state.dart';

class SavedSizesCubit extends Cubit<SavedSizesState> {
  final SavedSizesRepo repo;

  SavedSizesCubit(this.repo) : super(const SavedSizesState());

  void load() => emit(state.copyWith(items: repo.getAll()));

  Future<void> add(SavedSizeModel size) async {
    emit(state.copyWith(items: await repo.add(size)));
  }

  Future<void> rename(String id, String name) async {
    emit(state.copyWith(items: await repo.rename(id, name)));
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(items: await repo.delete(id), clearOpen: state.openId == id));
  }

  // فتح أو إغلاق تفاصيل البطاقة
  void toggle(String id) {
    if (state.openId == id) {
      emit(state.copyWith(clearOpen: true));
    } else {
      emit(state.copyWith(openId: id));
    }
  }
}
