import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/buttons/cart_add_button.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../core/widgets/heart_overlay_notifier.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/live_try_on/live_try_on_cubit.dart';
import '../../../logic/products/product_cubit.dart';
import '../../screens/product/products_screen.dart';
import '../product/product_quick_menu.dart';

// بطاقة منتج جديد
class NewProductCard extends StatelessWidget {
  final ProductModel item;
  const NewProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = item.discount != null;
    final discountAmount = hasDiscount ? (item.discount!.discountPerce ?? 0) : 0.0;
    final newPrice = item.pPrice - discountAmount;
    final percent = hasDiscount && item.pPrice > 0 ? ((discountAmount / item.pPrice) * 100).round() : 0;
    final name = context.locale.languageCode == 'en' ? (item.pNameEn ?? item.pName) : item.pName;

    return Builder(
      builder: (cardContext) => GestureDetector(
        // نفس قائمة الضغط المطول في الرئيسية
        onLongPress: () => ProductQuickMenu.show(cardContext, item),
        onTap: () => _open(context),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.6)),
            boxShadow: AppShadow.commonShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة مع الشارات
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: ApiEndpoints.productImageUrl(item.pImage),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.baseColor),
                      errorWidget: (_, __, ___) => Image.asset('assets/images/app icon/icon.png', fit: BoxFit.contain),
                    ),
                    // تدرج سفلي لوضوح الالوان
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x55000000)],
                        ),
                      ),
                    ),

                    // شارة جديد والخصم
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Badge(
                            text: tr('new_badge'),
                            gradient: const LinearGradient(colors: [Color(0xFF03C383), Color(0xFF25F5FC)]),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(height: 4),
                            _Badge(text: '-$percent%', color: AppColors.redColor),
                          ],
                        ],
                      ),
                    ),

                    // زر المفضلة
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: Tooltip(message: tr('tip_favorite'), child: _FavoriteButton(item: item)),
                    ),

                    // الوان المنتج
                    if (item.colors.isNotEmpty)
                      PositionedDirectional(
                        bottom: 8,
                        start: 8,
                        child: Tooltip(message: tr('tip_colors'), child: _ColorsRow(item: item)),
                      ),
                  ],
                ),
              ),

              // الاسم والسعر مع زر السلة
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 6, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColor),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${newPrice.toStringAsFixed(2)} \$',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${item.pPrice.toStringAsFixed(2)} \$',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    CartAddButton(product: item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الانتقال لواجهة المنتجات
  void _open(BuildContext context) {
    if (context.read<LiveTryOnCubit>().handleProductTap(item)) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductScreens(productID: item.pId, subCategoryID: item.subCatId),
      ),
    );
  }
}

// شارة صغيرة
class _Badge extends StatelessWidget {
  final String text;
  final Color? color;
  final Gradient? gradient;
  const _Badge({required this.text, this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// زر المفضلة الزجاجي
class _FavoriteButton extends StatelessWidget {
  final ProductModel item;
  const _FavoriteButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ProductCubit>().toggleProductFavorite(product: item);
        HeartOverlayNotifier.show(context, isLike: item.isFavorite);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          size: 16,
          color: item.isFavorite ? Colors.red : AppColors.iconColor,
        ),
      ),
    );
  }
}

// دوائر الالوان اسفل الصورة
class _ColorsRow extends StatelessWidget {
  final ProductModel item;
  const _ColorsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final extra = item.colors.length - 4;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in item.colors.take(4))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: CircleOfColor(code: c.colorCode ?? '#FFFFFF', width: 11, height: 11),
            ),
          if (extra > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 3),
              child: Text('+$extra', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
