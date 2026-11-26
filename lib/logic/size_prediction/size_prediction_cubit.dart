import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/size_prediction_model.dart';
import '../../data/repos/size_prediction_repo.dart';
import 'size_prediction_state.dart';

class SizePredictionCubit extends Cubit<SizePredictionState> {
  final SizePredictionRepo repo;

  SizePredictionCubit(this.repo) : super(SizePredictionInitial());

  // آخر طلب مرسل (يستخدم عند حفظ المقاس)
  SizeRequestModel? lastRequest;

  Future<void> predict(SizeRequestModel request) async {
    lastRequest = request;
    emit(SizePredictionLoading());
    try {
      final result = await repo.predictSize(request);
      if (result.isOk) {
        emit(SizePredictionSuccess(result));
      } else if (result.isPhotoFailed) {
        emit(SizePredictionNeedInput(result.messageKey, const ['photo']));
      } else {
        emit(SizePredictionNeedInput(result.messageKey, result.fields));
      }
    } catch (e) {
      emit(SizePredictionError('size_err_connection'));
    }
  }

  void reset() => emit(SizePredictionInitial());
}
