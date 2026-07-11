import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🌟 تم تفعيلها للمنطق
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_store/core/widgets/buttons/refresh_button.dart';
import 'package:smart_store/views/widgets/product/productdetailsheet.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../core/widgets/heart_overlay_notifier.dart';
import '../../../core/widgets/icons/share_icon.dart';
import '../../../core/widgets/customCategoryList.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/product_model.dart'; // 🌟 استيراد الموديل
import '../../../logic/products/product_cubit.dart'; // 🌟 استيراد الكوبيت
import '../../../logic/products/product_state.dart'; // 🌟 استيراد الحالة
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/product/products_screen.dart';
import '../../screens/similar products/similar_products.dart';
import '../favorites/empty_favorites.dart';
import '../flash/flash_screen.dart';
import 'empty_product_list.dart';

class AllProducts extends StatelessWidget {
  final bool showAddToCart;
  final bool isInsideFavoritesScreen;
  final Function(ProductModel product)? onProductTap;
  const AllProducts({
    super.key,
    this.showAddToCart = false,
    this.onProductTap,
    this.isInsideFavoritesScreen = false,
  });
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    bool isIpad = MediaQuery.of(context).size.width < 900 && MediaQuery.of(context).size.width > 450;
    int itemCount = isDesktop ? 5 : isIpad ? 4 : 2;

    // 🌟 تطبيق منطق الـ BlocBuilder على الكود الخاص بك دون المساس بالتصميم
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return FlashProducts();
        }

        if (state is ProductError) {
          return  Column(
            children: [
          Center(
          child:  SizedBox(
          height: 30,
            width: 120,
            child: RefreshButton(onPressed: () async {
              await context.read<ProductCubit>().fetchProducts(isRefresh: true);
            }),
          ),
        ),
        SizedBox(
        height: 150,)
            ],
          );
        }

        if (state is ProductLoaded) {
          final List<ProductModel> products = state.products;

          if (products.isEmpty) {
            return  Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child:  isInsideFavoritesScreen ?  EmptyFavorites() : EmptyProductList(),
              )
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MasonryGridView.count(
                scrollDirection: Axis.vertical,
                crossAxisCount: itemCount,
                mainAxisSpacing: 15, // مسافة بين العنصر والذي تحته كودك الأصلي
                crossAxisSpacing: 12, // مسافة بين العنصر والذي جنبه كودك الأصلي
                shrinkWrap: true,
                itemCount: products.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final ProductModel item = products[index];
                  int currentId = item.pId;
                  // 🌟 منطق حساب الخصومات الديناميكية القادمة من لارافيل
                  bool hasDiscount = item.discount != null;

                  double discountAmount = hasDiscount ? (item.discount!.discountPerce ?? 0) : 0;

                  double newPrice = hasDiscount ? (item.pPrice - discountAmount) : item.pPrice;

                  double discountPercent = 0;
                  if (hasDiscount && item.pPrice > 0) {
                    discountPercent = ((discountAmount / item.pPrice) * 100).round().toDouble();
                  }

                  return InkWell(
                    onTap: () {
                      if (onProductTap != null) {
                        onProductTap!(item);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductScreens(
                              productID: currentId,
                              subCategoryID: item.subCatId,
                              categoryID: null,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.boxShadow,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          ...AppShadow.commonShadow,
                        ],
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          // الصورة + badge الخصم (تصميم الـ Stack الأصلي بدون تعديل)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7),
                                ),
                                child: _buildProductImage(item),
                              ),

                              // ألوان المنتج ديناميكياً
                              Positioned(
                                top: 3,
                                right: 7,
                                child: Container(
                                  padding:  EdgeInsets.symmetric(vertical: (item.colors.length > 1) ? 2 : 0, horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    spacing: (item.colors.length > 1) ? 5 : 2,
                                    children: [
                                      if(item.colors.length == 1)
                                      SizedBox(),
                                      ...item.colors.take(3).map((color) {
                                        return CircleOfColor(
                                          code: color.colorCode ?? "#FFFFFF",
                                          width: isDesktop ? 14 : 12,
                                          height: isDesktop ? 14 : 12,
                                        );
                                      }).toList(),
                                      (item.colors.length <= 3)
                                          ? const SizedBox()
                                          : Text(
                                        "+${item.colors.length - 3}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isDesktop ? 10 : 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // شارة الخصم تعتمد على منطق السيرفر والشاشة معاً
                              (hasDiscount)
                                  ? Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.redColor.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "$discountPercent%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 11 : 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                                  : const SizedBox(),
                              PositionedDirectional(
                                bottom: 6,
                                start: 6,
                                child: GestureDetector(
                                  onLongPress: () =>Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen(screenOnly: true))),
                                  onTap: () {
                                    // 🚀 استدعاء الدالة من الـ Cubit مباشرة ليقوم هو بكل السحر في الخلفية
                                    context.read<ProductCubit>().toggleProductFavorite(
                                      customerId: 1,
                                      product: item,
                                      isInsideFavoritesScreen: isInsideFavoritesScreen
                                    );
                                    if(!isInsideFavoritesScreen){
                                      item.isFavorite ? HeartOverlayNotifier.show(context) : HeartOverlayNotifier.show(context,isLike: false);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                      color: item.isFavorite ? Colors.red : AppColors.iconColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                bottom: 6,
                                end: 6,
                                child:ShareButton(product: item,),
                              ),
                              PositionedDirectional(
                                bottom: 36,
                                start: 8,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const SimilarProducts()),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.center_focus_strong_outlined,
                                      color: AppColors.iconColor,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                (context.locale.languageCode == 'en')
                                    ? item.pNameEn ?? ''
                                    : item.pName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // 💰 السعر من كودك الأصلي تماماً
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 8,
                                  children: [
                                    Row(
                                      spacing: 1,
                                      children: [
                                        Text(
                                          newPrice.toStringAsFixed(2), // السعر الجديد بعد الحساب برمجياً
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          "\$",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    hasDiscount
                                        ? Text(
                                      "${item.pPrice} \$", // السعر الأصلي مشطوباً
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    )
                                        : const SizedBox(),
                                  ],
                                ),
                                showAddToCart
                                    ? InkWell(
                                  onTap: () => ProductDetailsDialog.show(context,item),
                                  child: Card(
                                    color: AppColors.backgroundSecondary,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: AppColors.borderColor.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                                      child: Icon(
                                        CupertinoIcons.cart_badge_plus,
                                        color: AppColors.iconColor,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              (context.select((ProductCubit cubit) => cubit.isFetchingMore)) ? Padding(
                padding: EdgeInsets.only(bottom: 50.0,top: 10),
                child: CircularProgress(),
              ) : SizedBox(height: 0,),
              SizedBox(height: 30,)
            ],
          );
        }
        return Center(
          child:  SizedBox(
            height: 30,
            width: 120,
            child: RefreshButton(onPressed: () async {
              await context.read<ProductCubit>().fetchProducts(isRefresh: true);
            }),
          ),
        );
      },
    );
  }
}

// 🌟 دالة قراءة مسار الصورة مع الحفاظ التام على هيكل دالة التحميل والأخطاء السابقة في كودك
Widget _buildProductImage(ProductModel item) {
  if (item.pImage == null || item.pImage!.toString().isEmpty) {
    return _buildFakeImage();
  }
  return Image.network(
    ApiEndpoints.productImageUrl(item.pImage),
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return Container(
        color: AppColors.background,
        width: double.infinity,
        height: 250, // طول الصورة الأصلي الثابت في كودك
        child: Center(child: ThreeDotsLoader()),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return _buildFakeImage();
    },
  );
}

Widget _buildFakeImage() {
  return Image.asset(
    'assets/images/image_placeholder.png',
    fit: BoxFit.contain,
  );
}