import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.fromLTRB(16, 0, 16, 25),
      padding:  EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        // إضافة انحناء كامل للحواف
        borderRadius: BorderRadius.circular(25),
        // حدود خفيفة جداً لتعريف الشكل
        border: Border.all(
          color: Colors.grey.shade200.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset:  Offset(0, 10), // الظل للأسفل ليعطي إيحاء بالارتفاع
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.iconColor,
        selectedFontSize: 12,
        showSelectedLabels: true,    // إظهار النص للمختار
        showUnselectedLabels: false,
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline, size: 22),
            activeIcon: Icon(Icons.play_circle_fill, size: 26),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined, size: 22),
            activeIcon: Icon(Icons.auto_awesome, size: 26),
            label: 'new'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, size: 22),
            activeIcon: Icon(CupertinoIcons.house_fill, size: 26),
            label: 'home'.tr()),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart, size: 22),
            activeIcon: Icon(CupertinoIcons.cart_fill, size: 26),
            label: 'cart'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person, size: 22),
            activeIcon: Icon(CupertinoIcons.person_fill, size: 26),
            label: 'OMAR',
          ),
        ],
      ),
    );
  }
}