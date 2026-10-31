import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/circularProgress.dart';
import 'package:smart_store/core/widgets/search/app_search.dart';
import 'package:smart_store/core/widgets/app_title.dart';
import 'package:smart_store/core/widgets/app_logo.dart';
import 'package:smart_store/core/widgets/icons/app_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_store/views/screens/profile/profile_screen.dart';
import 'package:smart_store/views/widgets/login/login.dart';
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
import '../../../logic/ads/ads_cubit.dart';
import '../../../logic/ads/ads_state.dart';
import '../../../logic/categories/category_cubit.dart';
import '../../../logic/categories/category_state.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../../../logic/login/login_cubit.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../widgets/category/category_bar.dart';
import '../../widgets/discounts/discounts.dart';
import '../../widgets/flash/flash_screen.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/product/empty_product_list.dart';
import '../../widgets/sliderEds/sliderEds.dart';
import '../../widgets/subcategory/subcategory_bar.dart';
import '../address/select_user_address_screen.dart';
import '../search/search_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  get currentIndex => null;
  static final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery هنا يضمن تحديث الواجهة فوراً عند تصغير المتصفح
    bool isDesktop = MediaQuery.of(context).size.width > 800;
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
          ThemeIcon(),
          BlocBuilder<LoginCubit,bool>(
              builder: (context, state) {
              return state ? AppIcon(icon: CupertinoIcons.search,onPressed:()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SearchScreen())),) :AppIcon(icon: CupertinoIcons.person,onPressed:() async{
                Login login =Login();
                login.loginDialog(context);
              },);
            }
          ),
          SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
           context.read<CategoryCubit>().getCategories();
           context.read<SubcategoryCubit>().getSubcategories();
           context.read<AdsCubit>().fetchAds();
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
                        isDesktop ? Builder(
                          builder: (context) {
                            // 1. فحص قائمة الخصومات
                            final discountProducts = context.watch<ProductCubit>().discountProducts;
                            final hasDiscounts = discountProducts.isNotEmpty;

                            return BlocBuilder<AdsCubit, AdsState>(
                              builder: (context, state) {
                                // 2. فحص حالة وقائمة الإعلانات
                                final bool isLoadingAds = state is AdsLoading;
                                final bool isErrorAds = state is AdsError;
                                final bool hasAdsList = state is AdsLoaded && state.adsList.isNotEmpty;

                                // 3. إذا لم تكن هناك إعلانات ولا خصومات (ولسنا في حالة تحميل أو خطأ للإعلانات)، لا نُظهر أي شيء
                                if (!isLoadingAds && !isErrorAds && !hasAdsList && !hasDiscounts) {
                                  return const SizedBox(height: 7,);
                                }

                                return Row(
                                  spacing: 12,
                                  children: [
                                    // --- قسم الإعلانات ---
                                    // يظهر فقط في حالة التحميل/الخطأ أو عند وجود إعلانات بالفعل
                                    if (isLoadingAds || isErrorAds || hasAdsList)
                                      Expanded(
                                        child: Builder(
                                          builder: (_) {
                                            if (isLoadingAds) {
                                              return FlashAds();
                                            } else if (state is AdsLoaded && hasAdsList) {
                                              return SliderEds(
                                                ads: state.adsList,
                                                scrollPhysics: true,
                                              );
                                            } else if (isErrorAds) {
                                              return Center(child: Text(state.message));
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),

                                    // --- قسم الخصومات ---
                                    // يظهر فقط إذا كانت هناك منتجات خصومات
                                    if (hasDiscounts)
                                      const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.0),
                                          child: Discounts(),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ):
                      BlocBuilder<AdsCubit, AdsState>(
                  builder: (context, state) {
                    if (state is AdsLoading) {
                      return FlashAds();
                    } else if (state is AdsLoaded && state.adsList.isNotEmpty) {
                      return SliderEds(
                        ads: state.adsList,
                        scrollPhysics: true,
                      );
                    }
                    return const SizedBox.shrink(); // في حال التحميل أو الخطأ أو القائمة الفارغة لا يظهر شيئاً مزعجاً
                  },
                  ),
                        if(!isDesktop) SubcategoryBar(),
                        isDesktop?SubcategoryBar():( context.watch<ProductCubit>().discountProducts).isEmpty ? SizedBox() :Discounts(),
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