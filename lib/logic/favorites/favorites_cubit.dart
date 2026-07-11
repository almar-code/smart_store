// logic/favorites/favorites_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/data/repos/favorite_repo.dart';
import '../products/product_event_bus.dart';

class FavoritesCubit extends Cubit<Set<int>> {
  final FavoriteRepo repository;

  FavoritesCubit({required this.repository}) : super({});

  Future<void> loadInitialFavoriteCount() async {
    print("sssssssssssssssssssssssssssssssssssssننننننننننن");
    try {
      //  التعديل هنا: الاستدعاء من الـ instance المحقون
      int count = await repository.getFavoriteCount(customerId: 1);

      // حفظ العدد الكلي فوراً في الباص المشترك لتحديث الـ Badge
      ProductEventBus.setInitialCount(count);
    } catch (e) {
      print("خطأ أثناء جلب العداد الأولي: $e");
    }
  }
}