import 'package:get_it/get_it.dart';
import '../../data/repos/product_repo.dart';
import '../../data/repos/subcategory_repo.dart';
import '../../data/repos/video_repo.dart';
import '../../data/services/category_service.dart';
import '../../data/repos/category_repo.dart';
import '../../data/services/product_service.dart';
import '../../data/services/subcategory_service.dart';
import '../../data/services/video_service.dart';

// 1. إنشاء نسخة عالمية من GetIt
final sl = GetIt.instance;

Future<void> init() async {
  //  تسجيل الـ Services
  sl.registerLazySingleton(() => CategoryService());
  //  تسجيل الـ Repositories
  sl.registerLazySingleton(() => CategoryRepo(sl<CategoryService>()));
  // داخل دالة init() في ملف injection_container.dart
  sl.registerLazySingleton(() => SubcategoryService());
  sl.registerLazySingleton(() => SubcategoryRepo(sl<SubcategoryService>()));
  sl.registerLazySingleton(() => VideoService());
  sl.registerLazySingleton(() => VideoRepo(sl()));
  sl.registerLazySingleton<ProductService>(() => ProductService());

// تسجيل كلاس اريبو (Repository) وتمرير كلاس السيرفر له
  sl.registerLazySingleton<ProductRepo>( () => ProductRepo(apiService: sl<ProductService>()),);
}