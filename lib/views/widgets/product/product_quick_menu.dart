import 'dart:math';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/heart_overlay_notifier.dart';
import '../../../core/widgets/icons/share_icon.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/products/product_cubit.dart';
import '../../screens/product/product_details_screen.dart';
import '../../screens/similar products/similar_products.dart';
import '../../screens/try_on/virtual_try_on_screen.dart';
import 'product_quick_sheets.dart';
import 'product_reviews_sheet.dart';

enum ProductQuickAction { favorite, cart, similar, share, tryOn, colors, sizes, details, reviews }

class ProductQuickMenu {
  static Future<void> show(
      BuildContext cardContext,
      ProductModel product, {
        bool isInsideFavoritesScreen = false,
      }) async {
    // مكان البطاقة على الشاشة
    final box = cardContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;

    HapticFeedback.mediumImpact();

    final action = await showGeneralDialog<ProductQuickAction>(
      context: cardContext,
      barrierDismissible: true,
      barrierLabel: 'product_menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _QuickMenuView(product: product, rect: rect),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

    if (action != null && cardContext.mounted) {
      await _handle(cardContext, product, action, isInsideFavoritesScreen);
    }
  }

  static Future<void> _handle(
      BuildContext context,
      ProductModel product,
      ProductQuickAction action,
      bool isInsideFavoritesScreen,
      ) async {
    final imageUrl = ApiEndpoints.productImageUrl(product.pImage);

    switch (action) {
      case ProductQuickAction.favorite:
      // تأكيد قبل الازالة
        if (product.isFavorite) {
          final ok = await AppToasts.showConfirmDialog(
            context: context,
            title: tr('confirm_delete_title'),
            message: tr('confirm_remove_favorite_msg'),
          );
          if (ok != true || !context.mounted) return;
        }
        context.read<ProductCubit>().toggleProductFavorite(
          product: product,
          isInsideFavoritesScreen: isInsideFavoritesScreen,
        );
        if (!isInsideFavoritesScreen) HeartOverlayNotifier.show(context, isLike: product.isFavorite);
      case ProductQuickAction.cart:
        ProductQuickSheets.addToCart(context, product);
      case ProductQuickAction.similar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SimilarProducts(imagePath: imageUrl)));
      case ProductQuickAction.share:
        ProductShareHelper.share(context, product);
      case ProductQuickAction.tryOn:
        Navigator.push(context, MaterialPageRoute(builder: (_) => VirtualTryOnScreen(garmentUrl: imageUrl)));
      case ProductQuickAction.colors:
        ProductQuickSheets.colors(context, product);
      case ProductQuickAction.sizes:
        ProductQuickSheets.sizes(context, product);
      case ProductQuickAction.details:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
      case ProductQuickAction.reviews:
        ProductReviewsSheet.show(context, productId: product.pId);
    }
  }
}

class _MenuItem {
  final ProductQuickAction action;
  final IconData icon;
  final String label;
  final bool danger;
  const _MenuItem(this.action, this.icon, this.label, {this.danger = false});
}

class _QuickMenuView extends StatelessWidget {
  final ProductModel product;
  final Rect rect;

  const _QuickMenuView({required this.product, required this.rect});

  static const double _itemHeight = 46;

  List<_MenuItem> _items() => [
    product.isFavorite
        ? _MenuItem(ProductQuickAction.favorite, CupertinoIcons.heart_slash, tr('remove_from_favorites'), danger: true)
        : _MenuItem(ProductQuickAction.favorite, CupertinoIcons.heart, tr('add_to_favorites')),
    _MenuItem(ProductQuickAction.cart, CupertinoIcons.cart_badge_plus, tr('add_to_cart')),
    _MenuItem(ProductQuickAction.similar, Icons.center_focus_strong_outlined, tr('similar_products')),
    _MenuItem(ProductQuickAction.share, Icons.share_outlined, tr('share_product')),
    _MenuItem(ProductQuickAction.tryOn, Icons.checkroom_outlined, tr('try_on')),
    _MenuItem(ProductQuickAction.colors, Icons.palette_outlined, tr('product_colors')),
    _MenuItem(ProductQuickAction.sizes, Icons.straighten_rounded, tr('product_sizes')),
    _MenuItem(ProductQuickAction.details, CupertinoIcons.info, tr('product_details')),
    _MenuItem(ProductQuickAction.reviews, CupertinoIcons.chat_bubble_text, tr('customer_reviews')),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screen = media.size;
    final items = _items();
    final menuHeight = min(items.length * _itemHeight + 12, screen.height - media.padding.vertical - 20);

    // اختيار الجهة الأوسع بجانب البطاقة
    final spaceRight = screen.width - rect.right - 10;
    final spaceLeft = rect.left - 10;
    final sideWidth = min(230.0, max(spaceRight, spaceLeft) - 10);

    double width;
    double left;
    double top;

    if (sideWidth >= 170) {
      width = sideWidth;
      left = spaceRight >= spaceLeft ? rect.right + 10 : rect.left - width - 10;
      top = rect.top;
    } else {
      // لا توجد مساحة جانبية: تحت البطاقة او فوقها
      width = min(240.0, screen.width - 20);
      left = rect.center.dx - width / 2;
      top = rect.bottom + 10;
      if (top + menuHeight > screen.height - media.padding.bottom) {
        top = rect.top - menuHeight - 10;
      }
    }

    left = left.clamp(10.0, screen.width - width - 10);
    final minTop = media.padding.top + 10;
    final maxTop = max(minTop, screen.height - media.padding.bottom - menuHeight - 10);
    top = top.clamp(minTop, maxTop);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // خلفية ضبابية تغلق القائمة
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: const ColoredBox(color: Colors.black45),
              ),
            ),
          ),

          // البطاقة مرفوعة
          Positioned.fromRect(
            rect: rect,
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                builder: (_, t, child) => Transform.translate(
                  offset: Offset(0, -8 * t),
                  child: Transform.scale(scale: 1 + 0.04 * t, child: child),
                ),
                child: _LiftedPreview(product: product),
              ),
            ),
          ),

          // القائمة
          // القائمة الزجاجية
          Positioned(
            left: left,
            top: top,
            width: width,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) => Opacity(
                opacity: t,
                child: Transform.scale(scale: 0.92 + 0.08 * t, alignment: Alignment.topCenter, child: child),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: menuHeight),
                    decoration: BoxDecoration(
                      // نفس زجاج بطاقة الدخول
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            _MenuTile(item: items[i]),
                            // فاصل خفيف بين العناصر
                            if (i != items.length - 1)
                              Divider(
                                height: 1,
                                indent: 14,
                                endIndent: 14,
                                color: Colors.white.withOpacity(0.08),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  // احمر فاتح يظهر على الزجاج
  static const Color _danger = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    final color = item.danger ? _danger : AppColors.primary;

    return InkWell(
      onTap: () => Navigator.pop(context, item.action),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.06),
      child: SizedBox(
        height: _QuickMenuView._itemHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Icon(item.icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: item.danger ? _danger : Colors.white,
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
// نسخة من البطاقة فوق الخلفية
class _LiftedPreview extends StatelessWidget {
  final ProductModel product;
  const _LiftedPreview({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount != null;
    final price = hasDiscount ? product.pPrice - (product.discount!.discountPerce ?? 0) : product.pPrice;
    final name = (context.locale.languageCode == 'en' ? product.pNameEn : product.pName) ?? '';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: ApiEndpoints.productImageUrl(product.pImage),
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (_, __, ___) => Image.asset('assets/images/app icon/icon.png', fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.textColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  "${price.toStringAsFixed(2)} \$",
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}