import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/app_shadow.dart';
import 'dart:ui';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/text/viewMoreText.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../flash/flash_screen.dart';

class NewProducts extends StatelessWidget {
  const NewProducts({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1000;
    bool isIpad = MediaQuery.of(context).size.width < 1000 && MediaQuery.of(context).size.width > 450;
    int itemCount = isDesktop ? 9 : isIpad ? 5 : 3;

    return SizedBox(
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return DiscountsShimmer();
          }

          if (state is ProductError) {
            return Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: isDesktop ? 120 : 50.0),
                    child: SizedBox(
                      height: 30,
                      width: 120,
                      child: RefreshButton(onPressed: () async {
                        await context.read<ProductCubit>().fetchProducts(
                          isFavorite: true,
                          isRefresh: true,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 150)
              ],
            );
          }

          if (state is ProductLoaded) {
            final List<ProductModel> products = state.products;

            if (products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: SizedBox(
                    height: 40,
                    width: 160,
                    child: Text("لا يوجد منتجات جديدة "),
                  ),
                ),
              );
            }

            return MasonryGridView.count(
              scrollDirection: Axis.vertical,
              crossAxisCount: itemCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              itemCount: products.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = products[index];

                // 🛡️ تأمين حساب الخصومات البرمجية لمنع الـ Null Operator Crash
                double discountAmount = 0;
                double newPrice = item.pPrice;
                double discountPercent = 0;

                if (item.discount != null) {
                  discountAmount = item.discount!.discountPerce ?? 0.0;
                  newPrice = item.pPrice - discountAmount;

                  if (item.pPrice > 0) {
                    discountPercent = ((discountAmount / item.pPrice) * 100).round().toDouble();                  }
                }
                return Container(
                  width: isDesktop ? 115 : 100,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: AppShadow.commonShadow,
                  ),
                  child: Column(
                    spacing: 5,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                            child: CustomNetworkImage(
                              imageUrl: ApiEndpoints.productImageUrl(item.pImage),
                              height: isDesktop ? 150 : 120,
                              width: double.infinity,
                            ),
                          ),
                          // 🏷️ اختياري: يمكنك هنا إضافة شارة النسبة المئوية للخصم (Badge) إذا كان discountPercent > 0
                        ],
                      ),

                      // 💰 تفاصيل المنتج والسعر
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 2,
                        children: [
                          SizedBox(
                            child: Text(
                              (context.locale.languageCode == "en" ? item.pNameEn : item.pName) ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // عرض السعر بناءً على وجود خصم أو عدمه بشكل آمن
                          item.discount == null
                              ? Text(
                            "${item.pPrice} \$",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textColor,
                            ),
                          )
                              : SizedBox(
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Row(
                                  spacing: 1,
                                  children: [
                                    Text(
                                      newPrice.toStringAsFixed(1),
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
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}