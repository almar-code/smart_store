// lib/views/screens/main_wrapper_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/bloc/theme_bloc.dart';
import '../../core/theme/bloc/theme_state.dart';
import '../widgets/drawer/drawer.dart';
import '../widgets/floatingActionButton/cartFloatingButton.dart';
import '../widgets/navigation/modern_bottom_nav_bar.dart';
import '../widgets/navigation/modern_side_rail.dart'; // الكلاس الجديد
import 'favorites/favorites_screen.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'new/new_screen.dart';
import 'profile/profile_screen.dart';
import 'reels/reels_screen.dart';

class MainWrapperScreen extends StatelessWidget {
  MainWrapperScreen({super.key});

  // المفتاح هنا للتحكم في السكافولد الرئيسي

  @override
  Widget build(BuildContext context) {
    // نمرر المفتاح للـ HomeScreen لكي يتمكن من فتح الدراور
    final List<Widget> screens = [
      const ReelScreen(pageIndex: 0),
      const NewScreen(),
      const HomeScreen(), // تمرير المفتاح هنا
      const CartScreen(),
      const ProfileScreen(),
      const FavoritesScreen(),
    ];
    final List<bool> extendBodyPages = [
      true,  // Reels
      true,  // New
      true, // Home (مثلاً فيها nav داخلية)
      false, // Cart
      true, // Profile
      true, // Favorites
    ];
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return LayoutBuilder(
      key: ValueKey(state.isDark),
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 800;
              return Scaffold(
                extendBody: extendBodyPages[currentIndex],
                key: context.read<NavigationCubit>().scaffoldKey,

                // الدراور يظهر فقط في الموبايل
                drawer: isDesktop ? null : const AppDrawer(),


                // backgroundColor: AppColors.background,
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration:  BoxDecoration(
                    // التدرج اللوني من الأعلى للأسفل كما في الصورة
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.gradientTop,    // سيأخذ 0xFF1C1C1E في الليل و 0xFFFFFFFF في النهار
                        AppColors.gradientBottom, // سيأخذ 0xFF000000 في الليل و 0xFFE8EAF0 في النهار
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isDesktop)
                        ModernSideRail(
                          currentIndex: currentIndex,
                          onTap: (index) => context.read<NavigationCubit>().updateIndex(index),
                        ),

                      Expanded(
                        child: Column(
                          children: [

                            // 5. محتوى الصفحات (Home, Reels, etc.)
                            Expanded(
                              child: IndexedStack(
                                index: currentIndex,
                                children: screens,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- استخدام كلاس الجوال المنفصل ---
                bottomNavigationBar: isDesktop
                    ?  SizedBox()
                    : ModernBottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (index) => context.read<NavigationCubit>().updateIndex(index),
                ),

              );
            },
          );
  },
);
        },
      ),
    );
  }
}