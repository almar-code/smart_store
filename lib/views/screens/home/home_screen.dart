import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/search/app_search.dart';
import 'package:smart_store/core/widgets/app_title.dart';
import 'package:smart_store/core/widgets/app_logo.dart';
import 'package:smart_store/core/widgets/icons/app_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../widgets/category/category_bar.dart';
import '../../widgets/discounts/discounts.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/navigation/modern_bottom_nav_bar.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/sliderEds/sliderEds.dart';
import '../../widgets/subcategory/subcategory_bar.dart';
import '../address/select_user_address_screen.dart';
import '../favorites/favorites_screen.dart';
import '../search/search_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  get currentIndex => null;
  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery هنا يضمن تحديث الواجهة فوراً عند تصغير المتصفح
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
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
            ?  AppTitle(firstPart: tr('firstHomeWord'),secondPart: tr('secondHomeWord'),fontSize: 20,): Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Logo(),
            const SizedBox(width: 6),
            AppTitle(),
          ],
        ),

        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SearchScreen())),
                  child: const App_Search(widthFactor:0.3)),
            ),
          FavoriteIcon(),
          // AppIcon(icon: CupertinoIcons.heart,onPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen(screenOnly: true,))),),
          AppIcon(icon:  AppColors.isDark.value ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,onPressed: (){
            context.read<ThemeBloc>().add(ToggleThemeEvent());
          },),
          AppIcon(icon: CupertinoIcons.person,onPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SelectUsrAddress())),),
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
                    spacing: 8,
                    children:[
                      isDesktop ? Row(
                        spacing: 12,
                        children: [
                          Expanded(child:
                          SliderEds(
                            images: [
                              'assets/images/E3.jpg',
                              'assets/images/a4.jpg',
                              'assets/images/E.jpg',
                            ],
                          )),
                          Expanded(
                              flex: 2,
                              child: Discounts()),
                        ],
                      ):
                      SliderEds(
                        images: [
                          'assets/images/E3.jpg',
                          'assets/images/a4.jpg',
                          'assets/images/E.jpg',
                        ],
                      ),
                      if(!isDesktop) SubcategoryBar(),
                      isDesktop?SubcategoryBar():Discounts(),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: CartFloatingButton(),
      ),
    );
  }
}