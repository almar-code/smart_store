import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/AdRepo.dart';
import 'ads_state.dart';

class AdsCubit extends Cubit<AdsState> {
  final AdRepo repo;

  AdsCubit(this.repo) : super(AdsInitial());

  // جلب كل الإعلانات للسلايدر
  Future<void> fetchAds() async {
    emit(AdsLoading());
    try {
      final ads = await repo.fetchAds();
      emit(AdsLoaded(ads));
    } catch (e) {
      emit(AdsError('فشل في تحميل الإعلانات'));
    }
  }

  // 🌟 جلب منتجات الإعلان العام المحدد من الجدول الوسيط
  Future<void> fetchGeneralAdProducts(int adsId) async {
    emit(GeneralAdProductsLoading());
    try {
      final result = await repo.fetchGeneralAdProducts(adsId);
      emit(GeneralAdProductsLoaded(
        adName: result['ad_name'],
        products: result['products'],
      ));
    } catch (e) {
      emit(AdsError('فشل في تحميل منتجات الإعلان'));
    }
  }
}