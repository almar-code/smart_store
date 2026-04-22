import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../screens/product/product_details_screen.dart';
import 'product_details.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/titleBar.dart';

class ProductDetailsDialog {
  static void show(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: isDesktop
              ? (context.locale.languageCode == 'ar'
              ? Alignment.centerRight
              : Alignment.centerLeft)
              : Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: isDesktop
                  ? MediaQuery.of(context).size.width * 0.35
                  : double.infinity,
              height: isDesktop
                  ? double.infinity
                  : MediaQuery.of(context).size.height * 0.84,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft:
                  isDesktop ? Radius.zero : const Radius.circular(10),
                  topRight:
                  isDesktop ? Radius.zero : const Radius.circular(10),
                ),
              ),
              child: buildProductDetailSheet(context), // 👈 هنا استخدمنا الدالة
            ),
          ),
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Offset beginOffset = isDesktop
            ? (context.locale.languageCode == 'ar'
            ? const Offset(1, 0)
            : const Offset(-1, 0))
            : const Offset(0, 1);

        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

Widget buildProductDetailSheet(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.close, color: AppColors.iconColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        const ProductImageSlider(images: [
          'assets/images/1.jpg',
          'assets/images/2.jpg',
          'assets/images/3.jpg'
        ]),

        const SizedBox(height: 15),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(
                          productID: 1,
                          isExpanded: true,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "mainAxisAlignmentmainAxisAlignmentmainAxisAlignment",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_outlined,
                          color: AppColors.iconColor, size: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "85.00 ر.س",
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Divider(color: AppColors.textSecondary, thickness: 0.2),

                TitleBar(
                  title: "${'color'.tr()} : red",
                  isDecoration: false,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 5),

                const ProductColorSelector(colors: [
                  {"imagePath": 'assets/images/1.jpg', "code": "#026789"},
                  {"imagePath": 'assets/images/2.jpg', "code": "#000000"},
                ]),

                const SizedBox(height: 7),

                TitleBar(title: 'size'.tr(), isDecoration: false),

                const SizedBox(height: 5),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: const ProductSizeSelector(
                    sizes: ['66', '56', '53', '48'],
                  ),
                ),
              ],
            ),
          ),
        ),

        const ProductActionActions(),
      ],
    ),
  );
}
