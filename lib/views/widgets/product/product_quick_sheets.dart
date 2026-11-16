import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/buttons/add_to_cart_button.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/colors/colors_cubit.dart';
import '../../../logic/size/size_cubit.dart';
import '../size_finder/size_finder_widgets.dart';
import 'product_details.dart';

class ProductQuickSheets {
  // اطار موحد للقوائم المنبثقة
  static Future<void> _open(BuildContext context, {required String title, required Widget child}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        return Container(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + media.padding.bottom),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.iconColor, size: 20),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              Divider(height: 1, color: AppColors.borderColor.withOpacity(0.5)),
              const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        );
      },
    );
  }

  // ===================== الاضافة للسلة =====================
  static Future<void> addToCart(BuildContext context, ProductModel product) {
    final ColorModel defaultColor = product.colors.isNotEmpty
        ? product.colors.first
        : ColorModel(colorId: 0, colorName: '', images: []);

    return _open(
      context,
      title: tr('choose_color_size'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DialogProductCubit>(create: (_) => DialogProductCubit(defaultColor)),
          BlocProvider<DialogSizeCubit>(create: (_) => DialogSizeCubit()),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductHeader(product: product),
            const SizedBox(height: 16),

            // اللون المختار
            BlocBuilder<DialogProductCubit, ColorModel>(
              builder: (context, c) => TitleBar(
                title: "${'color'.tr()} : ${(context.locale.languageCode == 'ar' ? c.colorName : c.colorNameEn) ?? ''}",
                isDecoration: false,
                color: AppColors.hexToColor(c.colorCode ?? '#000000'),
              ),
            ),
            const SizedBox(height: 8),
            ProductColorSelector(colors: product.colors),
            const SizedBox(height: 14),

            TitleBar(title: 'size'.tr(), isDecoration: false),
            const SizedBox(height: 8),
            ProductSizeSelector(sizes: product.sizes),
            const SizedBox(height: 8),
            FindMySizeButton(sizes: product.sizes),
            const SizedBox(height: 18),

            const SizedBox(width: double.infinity, child: AddToCartButton()),
          ],
        ),
      ),
    );
  }

  // ===================== الالوان =====================
  static Future<void> colors(BuildContext context, ProductModel product) {
    final isAr = context.locale.languageCode == 'ar';

    return _open(
      context,
      title: tr('product_colors'),
      child: product.colors.isEmpty
          ? _empty(tr('no_colors'))
          : Wrap(
        spacing: 10,
        runSpacing: 10,
        children: product.colors.map((c) {
          return _Chip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleOfColor(code: c.colorCode ?? '#FFFFFF', width: 15, height: 15),
                const SizedBox(width: 8),
                Text(
                  (isAr ? c.colorName : c.colorNameEn) ?? '',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===================== المقاسات =====================
  static Future<void> sizes(BuildContext context, ProductModel product) {
    return _open(
      context,
      title: tr('product_sizes'),
      child: product.sizes.isEmpty
          ? _empty(tr('no_sizes'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: product.sizes
                .map((s) => _Chip(
              child: Text(
                s.sizeName,
                style: TextStyle(color: AppColors.textColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 16),
          FindMySizeButton(sizes: product.sizes),
        ],
      ),
    );
  }

  static Widget _empty(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(child: Text(text, style: TextStyle(color: AppColors.textSecondary))),
  );
}

class _Chip extends StatelessWidget {
  final Widget child;
  const _Chip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
      ),
      child: child,
    );
  }
}

// صورة واسم وسعر المنتج
class _ProductHeader extends StatelessWidget {
  final ProductModel product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount != null;
    final price = hasDiscount ? product.pPrice - (product.discount!.discountPerce ?? 0) : product.pPrice;
    final name = (context.locale.languageCode == 'en' ? product.pNameEn : product.pName) ?? '';

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: ApiEndpoints.productImageUrl(product.pImage),
            width: 60,
            height: 72,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(width: 60, height: 72, color: AppColors.backgroundSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                "${price.toStringAsFixed(2)} \$",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}