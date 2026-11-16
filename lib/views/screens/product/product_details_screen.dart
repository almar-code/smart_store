import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/core/widgets/scroll_wrapper.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/buttons/ScrollToTopButton.dart' show ScrollToTopButton;
import '../../../core/widgets/customer_review.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repos/product_repo.dart';
import '../../../logic/colors/colors_cubit.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/size/size_cubit.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/product/product_details.dart';
import '../../widgets/size_finder/size_finder_widgets.dart';
import '../search/search_screen.dart';
import '../../../data/local/user_local.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product; // 🌟 تعديل: استقبال كائن المنتج بالكامل لتوفير البيانات فوراَ
  final int? subCategoryID;
  final bool isExpanded;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.subCategoryID,
    this.isExpanded = false,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late bool _localIsExpanded;
  Future<int?> _customerId() => UserLocal().getCustomerId();
  final ScrollController _scrollController = ScrollController();
  int _refreshKey = 0;
  @override
  void initState() {
    super.initState();
    _localIsExpanded = widget.isExpanded;
    _recordView();
  }
  // اعادة تحميل المنتجات المشابهة والآراء
  Future<void> _refresh(BuildContext ctx) async {
    setState(() => _refreshKey++);
    await ctx.read<ProductCubit>().fetchProducts(
      subCatId: widget.product.subCatId,
      similarProductId: widget.product.pId,
      isRefresh: true,
    );
  }
  // تسجيل مشاهدة المنتج في الخلفية بدون انتظار حتى لا تتأخر الشاشة
  Future<void> _recordView() async {
    di.sl<ProductRepo>().recordProductView(
      productId: widget.product.pId,
      customerId:  await _customerId(),
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    // الحصول على اللون الافتراضي للمنتج لتهيئة الكوبيت به
    final ColorModel defaultColor = widget.product.colors.isNotEmpty
        ? widget.product.colors.first
        : ColorModel(colorId: 0, colorName: '', images: [], colorCode: '#FFFFFF');

    return MultiBlocProvider(
      providers: [
        BlocProvider<DialogProductCubit>(
          create: (_) => DialogProductCubit(defaultColor),
        ),
        BlocProvider<DialogSizeCubit>(
          create: (_) => DialogSizeCubit(),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leadingWidth: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 3,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const FavoriteIcon(),
                CartIcon(),
                const SizedBox(width: 7),
              ],
            ),
            actions: [
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen())),
                child: App_Search(widthFactor: isDesktop ? 0.3 : 0.64),
              ),
              const ArrowBack()
            ],
          ),
          body:BlocProvider<ProductCubit>(
            create: (context) => ProductCubit(repository: di.sl<ProductRepo>())
              ..fetchProducts(
                subCatId: widget.product.subCatId,
                similarProductId:widget.product.pId,
                isRefresh: true,
              ),
           child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
             child: isDesktop
                 ? _buildDesktopLayout(context, widget.product)
                 : _buildMobileLayout(context, widget.product),
          ),
),
          floatingActionButton: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [
              SmartFloatingButton(),
              CartFloatingButton()
            ],
          ),
          bottomNavigationBar: isDesktop ? null :  ProductActionActions(product:widget.product ,),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ProductModel product) {
    return Stack(
      children: [
        Builder(
          builder: (innerContext) {
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.backgroundSecondary,
              onRefresh: () => _refresh(innerContext),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // المعرض يختفي تدريجيا مع التمرير
                  SliverPersistentHeader(
                    delegate: _GalleryHeaderDelegate(product: product),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildProductInfo(),
                          ),
                          ProductReviewsSection(productId: product.pId),
                          const TitleBar(title: "product like"),
                          AllProducts(
                            onProductTap: (p) => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),

        // زر الرجوع للأعلى
        PositionedDirectional(
          bottom: 15,
          start: 10,
          child: ScrollToTopButton(scrollController: _scrollController),
        ),
      ],
    );
  }
  Widget _buildDesktopLayout(BuildContext context,ProductModel product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<DialogProductCubit, ColorModel>(
                    builder: (context, selectedColor) {
                      final imgPaths = selectedColor.images.map((img) => img.imgUrl).toList();
                      return ProductImageSlider(
                        images: imgPaths.isNotEmpty ? imgPaths : [widget.product.pImage ?? ''],
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 440,
                    child: ScrollWrapper(child: _buildProductInfo()),
                  ),
                ],
              ),
               ProductActionActions(product: product,),
            ],
          ),
        ),
        const VerticalDivider(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            children: [
               ProductReviewsSection(
                productId: product.pId,
              ),
               TitleBar(title: "product like"),
              SizedBox(height: 12,),
              Expanded(
                child: Builder(
                  builder: (innerContext) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.backgroundSecondary,
                      onRefresh: () => _refresh(innerContext),
                      child: ScrollWrapper(
                        bottom: 15,
                        child: AllProducts(
                          onProductTap: (product) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product,),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        const SizedBox(height: 5),
        Text(
            (context.locale.languageCode == 'ar'  ? widget.product.pName : widget.product.pNameEn) ?? "",
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),),
        InkWell(
          onTap: () {
            setState(() {
              _localIsExpanded = !_localIsExpanded;
            });
          },
          child: Text(
            (context.locale.languageCode == 'ar'  ? widget.product.pDescription : widget.product.pDescriptionEn) ?? "",
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: _localIsExpanded ? null : 1,
            overflow: _localIsExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),

        Row(
          children: [
            Text(
              "${widget.product.pPrice} ر.س",
              style: TextStyle(
                color: widget.product.discount != null ? Colors.grey : AppColors.textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: widget.product.discount != null ? TextDecoration.lineThrough : null,
              ),
            ),
            if (widget.product.discount != null) ...[
              const SizedBox(width: 10),
              Text(
                "${(widget.product.pPrice * (1 - (widget.product.discount!.discountPerce! / 100))).toStringAsFixed(2)} ر.س",
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  "-${widget.product.discount!.discountPerce}%",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              )
            ]
          ],
        ),

        if (widget.product.discount != null && widget.product.discount!.endDate != null)
          Text(
            "ينتهي الخصم بتاريخ: ${widget.product.discount!.endDate}",
            style: const TextStyle(color: Colors.orange, fontSize: 11),
          ),

        Divider(color: AppColors.textSecondary, thickness: 0.2),

        // 🌟 عرض اسم اللون النشط ديناميكياً باستخدام الكوبيت
        BlocBuilder<DialogProductCubit, ColorModel>(
          builder: (context, selectedColor) {
            return TitleBar(
              title: "${'color'.tr()} : ${(context.locale.languageCode == 'ar'  ? selectedColor.colorName : selectedColor.colorNameEn) ?? ""}" ,
              isDecoration: false,
              color: AppColors.primary,
            );
          },
        ),

        // 🌟 استخدام الوجت المطور للألوان المرتبط بالكوبيت والسيرفر
        ProductColorSelector(colors: widget.product.colors),

        const SizedBox(height: 1),
        TitleBar(title: 'size'.tr(), isDecoration: false),

        // 🌟 استخدام الوجت المطور للمقاسات المرتبط بكوبيت المقاسات والسيرفر
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ProductSizeSelector(sizes: widget.product.sizes),
        ),
        FindMySizeButton(sizes: widget.product.sizes),
      ],
    );
  }

}
// رأس المعرض المتقلص
class _GalleryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ProductModel product;

  _GalleryHeaderDelegate({required this.product});

  @override
  double get maxExtent => 400;

  @override
  double get minExtent => 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // نسبة التقلص من 0 الى 1
    final t = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: maxExtent,
        maxHeight: maxExtent,
        child: Opacity(
          opacity: 1 - t,
          child: Transform.scale(
            scale: 1 - 0.15 * t,
            alignment: Alignment.bottomCenter,
            child: BlocBuilder<DialogProductCubit, ColorModel>(
              builder: (context, selectedColor) {
                final imgPaths = selectedColor.images.map((img) => img.imgUrl).toList();
                return ProductImageGallery(
                  images: imgPaths.isNotEmpty ? imgPaths : [product.pImage ?? ''],
                  videoID: product.videoID,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GalleryHeaderDelegate old) => old.product != product;
}