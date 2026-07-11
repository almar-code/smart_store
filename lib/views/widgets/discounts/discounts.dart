import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_shadow.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../core/widgets/text/viewMoreText.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../screens/discounts/discounts_screen.dart';
import '../flash/flash_screen.dart';

class Discounts extends StatelessWidget {
  const Discounts({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Column(
      spacing: 5,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DiscountsScreen(categoryID: context.read<ProductCubit>().categoryID,)),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/discount.png',
                      height: isDesktop ? 25 : 20,
                      width: isDesktop ? 25 : 20,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tr('discounts'),
                      style: TextStyle(
                        fontSize: isDesktop ? 15 : 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ViewMoreText(),
                  const SizedBox(width: 4),
                  const ArrowForwardIcon()
                ],
              ),
            ],
          ),
        ),
        const DiscountsUI()
      ],
    );
  }
}

class DiscountsUI extends StatelessWidget {
  const DiscountsUI({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SizedBox(
      height: isDesktop ? 170 : 155,
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const DiscountsShimmer(); // الـ Shimmer الخاص بك أثناء التحميل
          }
          if (state is ProductError) {
            return  Center(
                child: SizedBox(
                  height: 30,
                  width: 120,
                  child: RefreshButton(onPressed: () async {
                    await context.read<ProductCubit>().fetchProducts();
                  }),
                )
            );
          }

          if (state is ProductLoaded) {
            // 2. 🌟 جلب المصفوفة المفلترة والجاهزة فورا من الكوبيت دون أي تأخير
            final List<ProductModel> discounts = context.read<ProductCubit>().discountProducts;

            if (discounts.isEmpty) {
              return  SizedBox(); // إخفاء القسم نهائياً إذا لم تكن هناك خصومات بالمتجر
            }

            bool showViewMoreCard = discounts.length > 15;
            final int displayCount = showViewMoreCard ? 15 : discounts.length;

            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListView.builder(
                      physics:ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      // 🌟 التعديل الأول: إذا كان هناك بطاقة عرض المزيد نزيد 1، وإلا يبقى العدد الفعلي للمنتجات
                      itemCount: showViewMoreCard ? displayCount + 1 : displayCount,

                      itemBuilder: (context, index) {

                        // 🌟 التعديل الثاني: لن تظهر بطاقة "عرض المزيد" إلا إذا كان الشرط مفعل والاندكس وصل للنهاية
                        if (showViewMoreCard && index == displayCount) {
                          return InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DiscountsScreen(categoryID: context.read<ProductCubit>().categoryID,)),
                              );
                            },
                            child: Container(
                              width: isDesktop ? 130 : 100,
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: AppColors.borderColor),
                                boxShadow: AppShadow.commonShadow,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const ArrowForwardIcon(size: 18,),
                                  ),
                                  const SizedBox(height: 8),
                                  ViewMoreText(fontSize: 13,),
                                ],
                              ),
                            ),
                          );
                        }
                        // جلب بيانات المنتج الحالي
                        final ProductModel item = discounts[index];

                        // 🌟 حسابات الخصم الذكية القادمة من السيرفر (خصم مالي مباشر ثابت)
                        double discountAmount = item.discount!.discountPerce ?? 0;
                        double newPrice = item.pPrice - discountAmount;

                        // حساب النسبة المئوية التقريبية لعرضها في الـ Badge (%8 مثلاً)
                        int discountPercent = 0;
                        if (item.pPrice > 0) {
                          discountPercent = ((discountAmount / item.pPrice) * 100).round();
                        }

                        return InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DiscountsScreen(productID: item.pId, categoryID: context.read<ProductCubit>().categoryID,)),
                            );
                          },
                          child: Container(
                            width: isDesktop ? 125 : 100,
                            height: 130,
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: AppShadow.commonShadow,
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(7),
                                      ),
                                      child:  CustomNetworkImage(
                                        imageUrl: ApiEndpoints.productImageUrl(item.pImage), // ممرر رابط الصورة مباشرة من الموديل
                                        width: isDesktop ? 125 : 100,
                                        height: isDesktop ? 130 : 120,
                                      ),
                                    ),
                                    //  badge نسبة الخصم المحسوبة ذكياً
                                    Positioned(
                                      top: 8,
                                      right: 8,
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // 💰 عرض السعر الجديد والسعر القديم المشطوب بدقة
                                SizedBox(
                                  height: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Row(
                                        spacing: 1,
                                        children: [
                                          Text(
                                            newPrice.toStringAsFixed(1), // تنسيق رقم عشري واحد للتناسب مع العرض الصغير
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Text(
                                            "\$",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 12,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "${item.pPrice} \$",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
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
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Center(child: CircularProgress()),
                    ) : SizedBox()

                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
