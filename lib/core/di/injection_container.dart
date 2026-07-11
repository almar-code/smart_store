import 'package:get_it/get_it.dart';
import 'package:smart_store/data/services/favorite_service.dart';
import '../../data/repos/cart_repo.dart';
import '../../data/repos/favorite_repo.dart';
import 'package:smart_store/data/services/country_api_service.dart';
import 'package:smart_store/logic/countries_cubit/countries_cubit.dart';
import '../../data/repos/country_repo.dart';
import '../../data/repos/product_repo.dart';
import '../../data/repos/subcategory_repo.dart';
import '../../data/repos/video_repo.dart';
import '../../data/services/cart_service.dart';
import '../../data/services/category_service.dart';
import '../../data/repos/category_repo.dart';
import '../../data/services/product_service.dart';
import '../../data/services/subcategory_service.dart';
import '../../data/services/video_service.dart';
import '../../logic/cart/cart_cubit.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/products/product_cubit.dart';

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
  sl.registerFactory(() => ProductCubit(repository: sl<ProductRepo>()));
  sl.registerLazySingleton<FavoriteService>(() => FavoriteService());
  sl.registerLazySingleton<FavoriteRepo>(() => FavoriteRepo(apiService: sl<FavoriteService>()));
  sl.registerFactory(() => FavoritesCubit(repository: sl<FavoriteRepo>()));
  sl.registerLazySingleton(() => CartApiService());
  sl.registerLazySingleton(() => CartRepository(sl<CartApiService>()));
  sl.registerFactory(() => CartCubit(sl<CartRepository>()));
  sl.registerLazySingleton(()=>CountryRepo());
  sl.registerLazySingleton<CountriesCubit>(()=>CountriesCubit(sl<CountryRepo>()));

}