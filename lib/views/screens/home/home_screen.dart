import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/search/app_search.dart';
import 'package:smart_store/core/widgets/app_title.dart';
import 'package:smart_store/core/widgets/app_logo.dart';
import 'package:smart_store/core/widgets/icons/app_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/titleBar.dart';
import '../../widgets/category/category_bar.dart';
import '../../widgets/discounts/discounts.dart';
import '../../widgets/product/products.dart';
import '../../widgets/sliderEds/sliderEds.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery هنا يضمن تحديث الواجهة فوراً عند تصغير المتصفح
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: isDesktop
            ? null
            : DrawerMenuButton(),
        titleSpacing:isDesktop?10: 0,
        title: isDesktop
            ?  AppTitle(firstPart: tr('firstHomeWord'),secondPart: tr('secondHomeWord'),fontSize: 20,): Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Logo(),
            const SizedBox(width: 8),
            AppTitle(),
          ],
        ),

        actions: [
          if (isDesktop)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: App_Search(widthFactor:0.3),
            ),

          AppIcon(icon: CupertinoIcons.heart),
          AppIcon(icon: CupertinoIcons.person),
          SizedBox(width: 10),
        ],
      ),


      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CategoryBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      isDesktop ? Row(
                        spacing: 12,
                        children: [
                          Expanded(child: SliderEds()),
                          Expanded(
                              flex: 2,
                              child: Discounts()),
                        ],
                      ):SliderEds(),
                      isDesktop?SizedBox():Discounts(),

                      TitleBar(title: tr('forYou'),),
                      SizedBox(child: AllProducts()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}