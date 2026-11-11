// logic/favorites/favorites_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/data/repos/favorite_repo.dart';
import '../../data/local/user_local.dart';
import '../products/product_event_bus.dart';

class FavoritesCubit extends Cubit<Set<int>> {
  final FavoriteRepo repository;
  Future<int?> _customerId() => UserLocal().getCustomerId();
  FavoritesCubit({required this.repository}) : super({});

  Future<void> loadInitialFavoriteCount() async {
    try {
      //  التعديل هنا: الاستدعاء من الـ instance المحقون
      int count = await repository.getFavoriteCount(customerId:  await _customerId());

      // حفظ العدد الكلي فوراً في الباص المشترك لتحديث الـ Badge
      ProductEventBus.setInitialCount(count);
    } catch (e) {
      print("خطأ أثناء جلب العداد الأولي: $e");
    }
  }
}