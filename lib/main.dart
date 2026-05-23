import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/repos/product_repo.dart';
import 'data/repos/subcategory_repo.dart';
import 'data/repos/video_repo.dart';
import 'logic/subcategories/subcategory_cubit.dart';
import 'logic/videos/comments_cubit.dart';
import 'logic/videos/video_cubit.dart Dart.dart';
import 'my_app.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'logic/categories/category_cubit.dart';
import 'core/di/injection_container.dart' as di;
import 'data/repos/category_repo.dart';

// 🌟 استيراد ملفات الـ Product الـجديدة لربطها بالماين
import 'logic/products/product_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // تهيئة حاوي الحقن (Dependency Injection) قبل تشغيل التطبيق
  await di.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('en'),
      saveLocale: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(
            // استدعاء الـ CategoryRepo من حاوي الحقن مباشرة بدون تعقيد
            create: (_) => CategoryCubit(di.sl<CategoryRepo>())..getCategories(),
          ),
          BlocProvider(
            create: (_) => SubcategoryCubit(di.sl<SubcategoryRepo>())..getSubcategories(),
          ),

          // 🌟 إضافة الـ ProductCubit وحقن الـ ProductRepository من الـ Service Locator تلقائياً
          BlocProvider(
            create: (_) => ProductCubit(repository: di.sl<ProductRepo>())
              ..fetchProducts(isRefresh: true),
          ),

          // أضف الـ BlocProvider الخاص بالفيديوهات
          BlocProvider(
            create: (_) => VideoCubit(di.sl<VideoRepo>())..getAllVideos(),
          ),
          BlocProvider(
            create: (_) => CommentsCubit(di.sl<VideoRepo>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}