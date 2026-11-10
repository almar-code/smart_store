import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/size_prediction_model.dart';
import '../../data/repos/size_prediction_repo.dart';
import 'size_prediction_state.dart';

class SizePredictionCubit extends Cubit<SizePredictionState> {
  final SizePredictionRepo repo;

  SizePredictionCubit(this.repo) : super(SizePredictionInitial());

  // آخر قياسات محفوظة لتعبئة النموذج تلقائياً
  SizeRequestModel? get savedProfile => repo.getSavedProfile();

  Future<void> predict(SizeRequestModel request) async {
    emit(SizePredictionLoading());
    try {
      final result = await repo.predictSize(request);
      if (result.isOk) {
        emit(SizePredictionSuccess(result));
      } else {
        emit(SizePredictionNeedInput(result.messageKey, result.fields));
      }
    } catch (e) {
      emit(SizePredictionError('size_err_connection'));
    }
  }

  void reset() => emit(SizePredictionInitial());
}
