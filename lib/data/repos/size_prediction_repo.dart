import '../models/size_prediction_model.dart';
import '../services/size_prediction_service.dart';

class SizePredictionRepo {
  final SizePredictionService service;
  SizePredictionRepo(this.service);

  Future<SizeResultModel> predictSize(SizeRequestModel request) async {
    final body = request.toJson();
    final data = await service.predictSize(body);
    final result = SizeResultModel.fromJson(data);
    // نحفظ القياسات فقط إذا نجح الحساب
    if (result.isOk) await service.saveProfile(body);
    return result;
  }

  SizeRequestModel? getSavedProfile() {
    final data = service.loadProfile();
    return data == null ? null : SizeRequestModel.fromJson(data);
  }
}
