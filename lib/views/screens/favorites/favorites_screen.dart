import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../widgets/product/products.dart';

class FavoritesScreen extends StatelessWidget {
  final bool screenOnly;
  const FavoritesScreen({super.key,this.screenOnly =false});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading:Icon(
              CupertinoIcons.heart,
              color:  AppColors.iconColor,
              size: isDesktop?22: 20,
            ),
            titleSpacing:isDesktop?0: 0,
            title: AppTitle(firstPart: tr('firstFavorites'),secondPart: tr('secondFavorites'),fontSize: isDesktop?18: 15,spacing: ' ',),
            actions: [
              AppIcon(icon:CupertinoIcons.delete,color: AppColors.iconColor,size: 15,),
              screenOnly ? ArrowBack() : SizedBox(),

          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AllProducts(),
        ),);
}
}