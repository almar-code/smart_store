import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../logic/categories/category_cubit.dart';
import '../../../logic/categories/category_state.dart';
// 🌟 1. استيراد الكيوبيت الخاص بالفئات الفرعية للتمكن من استدعائه عند onTap
import '../../../logic/products/product_cubit.dart';
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../flash/flash_screen.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.borderColor),
        ),
      ),
      width: double.infinity,
      height: 34,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {

          if (state is CategoryLoading) {
            return const CategoryBarShimmer();
          }

          if (state is CategoryError) {
            final message = state.message ;
            return  Center(
              child: Text(message ?? ""),
            );
          }

          if (state is CategoryLoaded) {
            final categories = state.categories;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  // 🌟 2. تعديل زر "كل الأقسام" ليمرر null لـ catId
                  _buildInkWellItem(
                    context,
                    title: tr('all'),
                    catId: null,
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            ...categories.map(
                                  (item) => (item.nameEn != null && item.name.trim().isNotEmpty)
                                  ? _buildInkWellItem(
                                context,
                                title: (context.locale.languageCode == 'en')
                                    ? item.nameEn ?? ''
                                    : item.name ?? '',
                                // 🌟 3. تمرير الـ id الحقيقي للقسم القادم من لارافيل
                                catId: item.id,
                              )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // 🔹 InkWell المعدل لاستقبال الـ ID
  Widget _buildInkWellItem(
      BuildContext context, {
        required String title,
        required int? catId, // 🌟 أضفنا المعرف هنا ليستقبل الاختيار
      }) {
    return InkWell(
      onTap: () async{
        // 🌟 4. السحر يحدث هنا! عند الضغط، نقوم بإعلام SubcategoryCubit بالـ ID المختار
        // لارافيل سيتلقى هذا الـ id ويقوم بفلترة الفئات الفرعية بناءً عليه فوراً
        context.read<SubcategoryCubit>().getSubcategories(categoryId: catId);
        await context.read<ProductCubit>().fetchProducts(categoryId: catId , isRefresh: true);
      },
      borderRadius: BorderRadius.circular(8),
      child: _buildCategoryItem(title),
    );
  }

  // 🔹 التصميم الأصلي حقك (لم يتغير فيه شيء)
  Widget _buildCategoryItem(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(5),
        boxShadow: AppShadow.commonShadow,
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
      ),
    );
  }
}