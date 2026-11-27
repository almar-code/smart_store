import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repos/product_repo.dart';
import '../../../data/services/product_service.dart';
import '../../../logic/new_in/new_in_cubit.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../widgets/discounts/discounts.dart';
import '../../widgets/new/new_days_bar.dart';
import '../../widgets/new/new_hero_banners.dart';
import '../../widgets/new/new_product_card.dart';
import '../../widgets/product/empty_product_list.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  final NewInCubit _dayCubit = NewInCubit();
  // كيوبت للمنتجات الجديدة واخر للخصومات الجديدة
  final ProductCubit _products = ProductCubit(repository: ProductRepo(apiService: ProductService()));
  final ProductCubit _discounts = ProductCubit(repository: ProductRepo(apiService: ProductService()));
  late final List<NewInDay> _days = NewInCubit.buildDays();

  @override
  void initState() {
    super.initState();
    _loadProducts(0);
    _loadDiscounts();
  }

  @override
  void dispose() {
    _dayCubit.close();
    _products.close();
    _discounts.close();
    super.dispose();
  }

  // جلب منتجات الاسبوع او يوم محدد
  Future<void> _loadProducts(int index) {
    final day = _days[index];
    return day.isWeek
        ? _products.fetchProducts(isRefresh: true, dateFrom: day.raw)
        : _products.fetchProducts(isRefresh: true, date: day.raw);
  }

  // الخصومات المضافة خلال الاسبوع
  Future<void> _loadDiscounts() => _discounts.fetchProducts(isRefresh: true, discountFrom: NewInCubit.weekStart());

  void _selectDay(int index) {
    if (_dayCubit.state == index) return;
    _dayCubit.select(index);
    _loadProducts(index);
  }

  Future<void> _refresh() async {
    await Future.wait([_loadProducts(_dayCubit.state), _loadDiscounts()]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;
    final hPad = width > 1000 ? 24.0 : width > 450 ? 16.0 : 12.0;
    final columns = width > 1200 ? 5 : width > 900 ? 4 : width > 450 ? 3 : 2;
    final isLarge = width > 1000;

    return MultiBlocProvider(
      providers: [
        BlocProvider<NewInCubit>.value(value: _dayCubit),
        BlocProvider<ProductCubit>.value(value: _products),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: isDesktop ? null : DrawerMenuButton(),
          titleSpacing: isDesktop ? 10 : 1,
          title: isDesktop
              ? AppTitle(firstPart: tr('firstNewWord'), secondPart: tr('secondNewWord'), fontSize: 20)
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Logo(),
              const SizedBox(width: 6),
              AppTitle(firstPart: tr('firstNewWord'), secondPart: tr('secondNewWord')),
            ],
          ),
          actions: [
            if (isDesktop)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: App_Search(widthFactor: 0.3),
              ),
            FavoriteIcon(),
            CartIcon(),
            const SizedBox(width: 10),
          ],
        ),
        // السحب للتحديث
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          backgroundColor: AppColors.backgroundSecondary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // الشاشات الكبيرة: صورة يمين وصورة يسار والايام بالوسط
              if (isLarge)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                  sliver: SliverToBoxAdapter(child: _LargeHeader(days: _days, onSelect: _selectDay)),
                )
              else ...[
                // صور الواجهة
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 14),
                  sliver: const SliverToBoxAdapter(child: NewHeroBanners()),
                ),

                // الاسبوع والايام
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  sliver: SliverToBoxAdapter(child: NewDaysBar(days: _days, onSelect: _selectDay)),
                ),
              ],

              // الخصومات الجديدة تظهر فقط عند وجودها
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
                sliver: SliverToBoxAdapter(
                  child: BlocProvider<ProductCubit>.value(
                    value: _discounts,
                    child: BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, state) {
                        final has = state is ProductLoaded && _discounts.discountProducts.isNotEmpty;
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          child: has ? const Discounts() : const SizedBox(width: double.infinity),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // عنوان المنتجات الجديدة مع العدد
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 10),
                sliver: SliverToBoxAdapter(
                  child: BlocBuilder<ProductCubit, ProductState>(
                    builder: (context, state) {
                      final count = state is ProductLoaded ? state.products.length : 0;
                      return TitleBar(
                        title: tr('New Products'),
                        viewMoreShow: count > 0
                            ? Text(
                          tr('new_products_count', args: ['$count']),
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        )
                            : null,
                      );
                    },
                  ),
                ),
              ),

              // شبكة المنتجات
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading || state is ProductInitial) {
                    return _gridPadding(hPad, _ShimmerGrid(columns: columns));
                  }
                  if (state is ProductError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 120,
                          child: RefreshButton(onPressed: () => _loadProducts(_dayCubit.state)),
                        ),
                      ),
                    );
                  }
                  final List<ProductModel> products = state is ProductLoaded ? state.products : const <ProductModel>[];
                  if (products.isEmpty) {
                    // نفس واجهة الفراغ في الرئيسية
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50, bottom: 140),
                        child: EmptyProductList(),
                      ),
                    );
                  }
                  return _gridPadding(
                    hPad,
                    SliverMasonryGrid.count(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childCount: products.length,
                      itemBuilder: (_, i) => NewProductCard(
                        key: ValueKey('new_${products[i].pId}'),
                        item: products[i],
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: (i * 40).clamp(0, 400)), duration: const Duration(milliseconds: 300))
                          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // مسافة سفلية حتى لا يغطي الشريط السفلي اخر المنتجات
  Widget _gridPadding(double hPad, Widget sliver) =>
      SliverPadding(padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 110), sliver: sliver);
}

// راس الشاشات الكبيرة مثل التصميم السابق
class _LargeHeader extends StatelessWidget {
  final List<NewInDay> days;
  final ValueChanged<int> onSelect;
  const _LargeHeader({required this.days, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const height = 210.0;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          const Expanded(child: NewBanner(image: 'new_phon_ar_6.png', height: height)),
          const SizedBox(width: 12),
          // الايام في المنتصف
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: AppShadow.commonShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('top Collection'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('new_pick_day'),
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  NewDaysBar(days: days, onSelect: onSelect),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: NewBanner(image: 'new_phon_ar_4.png', height: height)),
        ],
      ),
    );
  }
}

// تحميل وهمي بشكل البطاقات
class _ShimmerGrid extends StatelessWidget {
  final int columns;
  const _ShimmerGrid({required this.columns});

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: columns * 2,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.baseColor,
        highlightColor: AppColors.highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 12, width: 100, color: AppColors.backgroundSecondary),
            const SizedBox(height: 6),
            Container(height: 12, width: 60, color: AppColors.backgroundSecondary),
          ],
        ),
      ),
    );
  }
}