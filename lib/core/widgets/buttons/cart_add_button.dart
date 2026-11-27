import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../views/widgets/product/productdetailsheet.dart';
import '../../constants/app_colors.dart';

// زر السلة الموحد في بطاقات المنتجات بكل الصفحات
// يفتح نافذة اختيار اللون والمقاس
class CartAddButton extends StatelessWidget {
  final ProductModel product;
  final double iconSize;
  final double padding;

  const CartAddButton({
    super.key,
    required this.product,
    this.iconSize = 18,
    this.padding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tr('add_to_cart'),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => ProductDetailsDialog.show(context, product),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(CupertinoIcons.cart_badge_plus, size: iconSize, color: AppColors.primary),
        ),
      ),
    );
  }
}