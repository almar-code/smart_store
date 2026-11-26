import '../models/size_prediction_model.dart';
import '../services/size_prediction_service.dart';

class SizePredictionRepo {
  final SizePredictionService service;
  SizePredictionRepo(this.service);

  Future<SizeResultModel> predictSize(SizeRequestModel request) async {
    final data = await service.predictSize(request.toJson());
    return SizeResultModel.fromJson(data);
  }
}
