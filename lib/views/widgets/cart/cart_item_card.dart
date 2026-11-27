import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/cart_model.dart';
import 'cart_quantity_counter.dart';

// بطاقة صنف السلة
class CartItemCard extends StatelessWidget {
  final CartModel item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onEdit;
  final bool lifted;

  const CartItemCard({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onEdit,
    this.lifted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final name = isAr ? item.productName : (item.productNameEn ?? item.productName);
    final colorName = isAr
        ? (item.selectedColor?.colorName ?? '')
        : (item.selectedColor?.colorNameEn ?? item.selectedColor?.colorName ?? '');
    final hasDiscount = item.discountPercent > 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: lifted
            ? [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 14))]
            : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5)),
          ...AppShadow.commonShadow,
        ],
      ),
      // ارتفاع البطاقة حسب الاعلى بين الصورة والمحتوى
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصورة مع شارة الخصم
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ApiEndpoints.productImageUrl(item.displayImage),
                      width: 92,
                      height: 116,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 92,
                        height: 116,
                        color: AppColors.background,
                        child: Center(child: ThreeDotsLoader()),
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/app icon/icon.png',
                        width: 92,
                        height: 116,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    PositionedDirectional(
                      top: 6,
                      start: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.redColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "-${item.discountPercent}%",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 116),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الاسم
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColor),
                    ),

                    const SizedBox(height: 6),

                    // اللون والمقاس قابلة للضغط للتعديل
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.selectedColor != null)
                          _OptionChip(
                            onTap: onEdit,
                            editable: item.canEditOptions,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleOfColor(width: 11, height: 11, code: item.selectedColor?.colorCode ?? "#000000"),
                                if (colorName.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 70),
                                    child: Text(
                                      colorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: AppColors.textColor),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        if (item.selectedSize != null)
                          _OptionChip(
                            onTap: onEdit,
                            editable: item.canEditOptions,
                            child: Text(
                              "${tr('size')} ${item.selectedSize!.sizeName}",
                              style: TextStyle(fontSize: 11, color: AppColors.textColor),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Spacer(),

                    // السعر والعداد
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount)
                                Text(
                                  "${item.productPrice.toStringAsFixed(2)} \$",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  "${item.unitPrice.toStringAsFixed(2)} \$",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                              // اجمالي الصنف عند اكثر من قطعة
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: item.quantity > 1
                                    ? Text(
                                  "${tr('cart_item_total')}: ${item.lineTotal.toStringAsFixed(2)} \$",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                )
                                    : const SizedBox(width: double.infinity),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        CartQuantityCounter(
                          quantity: item.quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// شريحة اللون او المقاس
class _OptionChip extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool editable;

  const _OptionChip({required this.child, this.onTap, this.editable = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: editable ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            if (editable && onTap != null) ...[
              const SizedBox(width: 2),
              Icon(CupertinoIcons.chevron_down, size: 10, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}