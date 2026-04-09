import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../favorites/favorites_screen.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return  Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: isDesktop
              ? null
              : DrawerMenuButton(),
          titleSpacing:isDesktop ? 10 : 1,
          title: isDesktop
              ?  AppTitle(firstPart: tr('firstNewWord'),secondPart: tr('secondNewWord'),fontSize: 20,): Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Logo(),
              const SizedBox(width: 6),
              AppTitle(firstPart: tr('firstNewWord'),secondPart: tr('secondNewWord')),
            ],
          ),

          actions: [
            if (isDesktop)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: App_Search(widthFactor:0.3),
              ),
            FavoriteIcon(),
            CartIcon(),
            SizedBox(width: 10),
          ],
        ),
        body: Center(child: Text("Favorites Page")));
  }
}