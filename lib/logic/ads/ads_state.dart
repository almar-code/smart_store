import '../../data/models/AdModel.dart';
import '../../data/models/product_model.dart';

abstract class AdsState {}

class AdsInitial extends AdsState {}

class AdsLoading extends AdsState {}

class AdsLoaded extends AdsState {
  final List<AdModel> adsList;
  AdsLoaded(this.adsList);
}

// 🌟 حالات خاصة بمنتجات الإعلان العام
class GeneralAdProductsLoading extends AdsState {}

class GeneralAdProductsLoaded extends AdsState {
  final String adName;
  final List<ProductModel> products;
  GeneralAdProductsLoaded({required this.adName, required this.products});
}

class AdsError extends AdsState {
  final String message;
  AdsError(this.message);
}