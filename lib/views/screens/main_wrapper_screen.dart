// lib/views/screens/main_wrapper_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../widgets/floatingActionButton/cart_screen.dart';
import '../widgets/navigation/modern_bottom_nav_bar.dart';
import '../widgets/navigation/modern_side_rail.dart'; // الكلاس الجديد
import 'favorites/favorites_screen.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'new/new_screen.dart';
import 'profile/profile_screen.dart';
import 'reels/reels_screen.dart';

class MainWrapperScreen extends StatelessWidget {
  const MainWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const ReelScreen(),
      const NewScreen(),
       HomeScreen(),
      const CartScreen(),
      const ProfileScreen(),
      const FavoritesScreen(),
    ];

    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 800;

              return Scaffold(
                floatingActionButton:  CartFloatingButton(),


                backgroundColor: isDesktop ? Colors.white : Colors.white,
                body: Row(
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

                // --- استخدام كلاس الجوال المنفصل ---
                bottomNavigationBar: isDesktop
                    ?  SizedBox.shrink()
                    : ModernBottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (index) => context.read<NavigationCubit>().updateIndex(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}