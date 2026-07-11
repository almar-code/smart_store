import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/colors/colors_cubit.dart';
import '../../../logic/size/size_cubit.dart';
import '../../screens/product/product_details_screen.dart';
import 'product_details.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/titleBar.dart';

class ProductDetailsDialog {
  static void show(BuildContext context,ProductModel product) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (context, animation, secondaryAnimation) {
        bool isDesktop = MediaQuery.of(context).size.width > 800;

        return SafeArea(
          child: Align(
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
                child: buildProductDetailSheet(context,product), // 👈 هنا استخدمنا الدالة
              ),
            ),
          ),
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        bool isDesktop = MediaQuery.of(context).size.width > 800;

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
Widget buildProductDetailSheet(BuildContext context, ProductModel product) {
  // إذا لم يكن هناك ألوان قادمة من لارافيل، نضع كائن وهمي لمنع الأخطاء
  final ColorModel defaultColor = product.colors.isNotEmpty
      ? product.colors.first
      : ColorModel(colorId: 0, colorName: '', images: []);

  return MultiBlocProvider(
      providers: [
        BlocProvider<DialogProductCubit>(
          create: (_) => DialogProductCubit(defaultColor),
        ),
        BlocProvider<DialogSizeCubit>(
          create: (_) => DialogSizeCubit(), // سيبدأ تلقائياً بالقيمة null
        ),
      ], // حقن الكوبيت المؤقت للون الافتراضي
    child:  BlocBuilder<DialogProductCubit, ColorModel>(
      builder: (context, selectedColor) {
        final imgPaths = selectedColor.images.map((img) => img.imgUrl).toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hexToColor(selectedColor.colorCode ?? "#000000").withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
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

          // 🌟 معرض الصور يستمع الآن ديناميكياً للون المختار
          ProductImageSlider(images: imgPaths.isNotEmpty ? imgPaths : [product.pImage ?? '']),

          const SizedBox(height: 15),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      // انتقال لشاشة التفاصيل الكاملة مع تمرير الآيدي
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product, isExpanded: true)));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (context.locale.languageCode == 'ar'  ? product.pDescription : product.pDescriptionEn) ?? "", // 🌟 اسم المنتج الحقيقي
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textColor, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined, color: AppColors.iconColor, size: 12),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🌟 عرض السعر والخصم ديناميكياً بناءً على بيانات السيرفر
                  Row(
                    children: [
                      Text(
                        "${product.pPrice} ر.س",
                        style: TextStyle(
                          color: product.discount != null ? AppColors.textSecondary : AppColors.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: product.discount != null ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (product.discount != null) ...[
                        const SizedBox(width: 10),
                        // حساب السعر الجديد بعد الخصم
                        Text(
                          "${(product.pPrice -product.discount!.discountPerce! ).toStringAsFixed(2)} ر.س",
                          style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            "${((product.discount!.discountPerce! / product.pPrice) * 100).round()}%",
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        )
                      ]
                    ],
                  ),

                  if (product.discount != null && product.discount!.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "ينتهي الخصم بتاريخ: ${product.discount!.endDate}",
                        style: const TextStyle(color: Colors.orange, fontSize: 11),
                      ),
                    ),

                  Divider(color: AppColors.textSecondary, thickness: 0.2),

                  // 🌟 عرض اسم اللون المختار حالياً ديناميكياً بفضل الـ BlocBuilder
                  TitleBar(
                    title: "${'color'.tr()} : ${(context.locale.languageCode == 'ar'  ? selectedColor.colorName : selectedColor.colorNameEn) ?? ""}" ,
                    isDecoration: false,
                    color: AppColors.hexToColor(selectedColor.colorCode ?? "#000000"),
                  ),

                  const SizedBox(height: 5),

                  // تمرير مصفوفة الألوان الكاملة للوجت الاختيار
                  ProductColorSelector(colors: product.colors),

                  const SizedBox(height: 7),

                  TitleBar(title: 'size'.tr(), isDecoration: false),

                  const SizedBox(height: 5),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProductSizeSelector(sizes: product.sizes), // 🌟 تمرير مصفوفة المقاسات الحقيقية
                  ),
                ],
              ),
            ),
          ),

           ProductActionActions(product: product,),
        ],
      ),
    );
  },
),
  );
}
