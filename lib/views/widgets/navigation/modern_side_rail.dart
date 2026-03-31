// lib/views/widgets/modern_side_rail.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';

class ModernSideRail extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernSideRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 63, // عرض العمود الجانبي
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            border: Border(
          right: BorderSide(
          color: Colors.black.withOpacity(0.2), // 👈 أسود شفاف
          width: 0.5,
        ),
        ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: NavigationRail(
            groupAlignment: 0,
            selectedIndex: currentIndex,
            minWidth: 63,
            useIndicator: false,
            onDestinationSelected: onTap,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.transparent,
            selectedIconTheme: const IconThemeData(
              color: AppColors.primary,
              size: 22,
            ),
            unselectedIconTheme: IconThemeData(
              size: 20,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
            ),
            unselectedLabelTextStyle: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
            destinations:  [

              NavigationRailDestination(
                icon: Icon(Icons.play_circle_outline),
                selectedIcon: Icon(Icons.play_circle_fill),
                label: Text('Reels'),
              ),
              NavigationRailDestination(
                icon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.auto_awesome_outlined),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.auto_awesome),
                ),
                label: Text('جديد'),
              ),

              NavigationRailDestination(
                icon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(CupertinoIcons.home),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(CupertinoIcons.house_fill),
                ),
                label: Text('home'.tr())),

              NavigationRailDestination(
                icon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(CupertinoIcons.cart),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(CupertinoIcons.cart_fill),
                ),
                label: Text('السلة'),
              ),

              NavigationRailDestination(
                icon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(CupertinoIcons.person),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(CupertinoIcons.person_fill),
                ),
                label: Text('Omar'),
              ),
              NavigationRailDestination(
                icon: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6), // 👈 المسافة
                  child: Icon(Icons.favorite_outline),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Icon(Icons.favorite),
                ),
                label: Text('المفضلة'),
              ),
            ],

          )
        ),
        Positioned(
          bottom: 20,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SocialIcon(
              icon: FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
            ),
            SizedBox(height: 6),
            SocialIcon(
              icon: FontAwesomeIcons.instagram,
              color: Color(0xFFE1306C),
            ),
            SizedBox(height: 6),
            SocialIcon(
              icon: FontAwesomeIcons.facebook,
              color: Color(0xFF1877F2),
            ),
          ],
        ),)
      ],
    );
  }
}