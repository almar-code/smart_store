import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'views/screens/main_wrapper_screen.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/constants/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            key: ValueKey(state.isDark),
            debugShowCheckedModeBanner: false,

          // 🌍 الترجمة
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // 🎨 الثيم
          theme: ThemeData(
            brightness: state.isDark ? Brightness.dark : Brightness.light,


            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.background,
              elevation: 0,
            ),

            // 🔥 مهم جدًا (لكن وحده لا يكفي)
            canvasColor: Colors.transparent,

            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // 🔥 هذه أهم نقطة ناقصة عندك
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              type: BottomNavigationBarType.fixed,
            ),
          ),

          home: MainWrapperScreen(),
        );
      }
        );
      }
}