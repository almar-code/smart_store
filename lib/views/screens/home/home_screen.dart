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
import '../../../core/theme/bloc/theme_state.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/icons/theme_icon.dart';
import '../../../core/widgets/scroll_wrapper.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../data/repos/category_repo.dart';
import '../../../data/services/category_service.dart';
import '../../../logic/categories/category_cubit.dart';
import '../../../logic/categories/category_state.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../../widgets/category/category_bar.dart';
import '../../widgets/discounts/discounts.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/sliderEds/sliderEds.dart';
import '../../widgets/subcategory/subcategory_bar.dart';
import '../address/select_user_address_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  get currentIndex => null;
  static final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery هنا يضمن تحديث الواجهة فوراً عند تصغير المتصفح
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final service = CategoryService();
    final repo = CategoryRepo(service);
    Future<void> _handleRefresh() async {

    }
    return Scaffold(
       backgroundColor: Colors.transparent,
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
              child: const App_Search(widthFactor:0.3),
            ),
          FavoriteIcon(),
          // AppIcon(icon: CupertinoIcons.heart,onPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen(screenOnly: true,))),),
          // AppIcon(icon:  AppColors.isDark.value ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,onPressed: (){
          //   context.read<ThemeBloc>().add(ToggleThemeEvent());
          // },),
          ThemeIcon(),
          AppIcon(
            icon: CupertinoIcons.person,onPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SelectUsrAddress())),),
          SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
           context.read<CategoryCubit>().getCategories();
           context.read<SubcategoryCubit>().getSubcategories();
          await context.read<ProductCubit>().fetchProducts(isRefresh: true);
        },
        color: AppColors.primary, // لون مؤشر التحميل (يمكنك ربطه بهوية المشروع)
        backgroundColor: AppColors.backgroundSecondary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  return  (state is CategoryEmpty || state is CategoryInitial) ? SizedBox() : CategoryBar();
                },
              ),
              Expanded(
                child: ScrollWrapper(
                  bottom: isDesktop ? 15 :85,
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
                              ],scrollPhysics: true
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
                          ],scrollPhysics: true
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
      ),
    );
  }
}