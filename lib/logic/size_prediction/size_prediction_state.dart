import '../../data/models/size_prediction_model.dart';

abstract class SizePredictionState {}

class SizePredictionInitial extends SizePredictionState {}

class SizePredictionLoading extends SizePredictionState {}

class SizePredictionSuccess extends SizePredictionState {
  final SizeResultModel result;
  SizePredictionSuccess(this.result);
}

// بيانات ناقصة أو غير منطقية (fields تحدد الحقول المطلوب تصحيحها)
class SizePredictionNeedInput extends SizePredictionState {
  final String messageKey;
  final List<String> fields;
  SizePredictionNeedInput(this.messageKey, this.fields);
}

class SizePredictionError extends SizePredictionState {
  final String message;
  SizePredictionError(this.message);
}
