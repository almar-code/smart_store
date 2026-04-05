import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/widgets/itemCount.dart';

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
      margin:  EdgeInsets.only(bottom: 14,left: 14,right: 14),
      // padding:  EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        // إضافة انحناء كامل للحواف
        borderRadius: BorderRadius.circular(20),
        // حدود خفيفة جداً لتعريف الشكل
        border: Border.all(
          color: Colors.transparent,
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
            icon: Badge(
                backgroundColor: Colors.transparent,
                alignment: Alignment.topRight,
                padding: EdgeInsets.only(bottom: 13,left: 8),
                label: ItemCount(fontSize: 11,),
                child: Icon(CupertinoIcons.cart, size: 22)),
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