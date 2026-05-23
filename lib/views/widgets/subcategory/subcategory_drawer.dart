import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../screens/product/products_screen.dart';
import '../flash/flash_screen.dart'; // حامي لكلاس FlashSubcategoryDrawer

// استيراد الطبقات المنطقية والموديل الخاص بك
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../../../logic/subcategories/subcategory_state.dart';
import '../../../data/models/subcategory_model.dart';

class SubCategoryItems extends StatelessWidget {
  const SubCategoryItems({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubcategoryCubit, SubcategoryState>(
      builder: (context, state) {

        // 1. حالة التحميل (Loading) باستخدام كلاس الوميض المخصص للـ Drawer
        if (state is SubcategoryLoading) {
          return const FlashSubcategoryDrawer();
        }

        // 2. حالة الخطأ (Error)
        if (state is SubcategoryError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("حدث خطأ في جلب الفئات الفرعية"),
            ),
          );
        }

        // 3. حالة النجاح واستلام البيانات (Success)
        if (state is SubcategoryLoaded) {
          final subcategories = state.subcategories; // قائمة الموديلات الحقيقية SubcategoryModel

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // استخدام .map للتكرار البرمجي وعرض كل عنصر بناءً على هيكل الـ ListTile الخاص بك
              ...subcategories.map((item) {

                // 🌐 معالجة الترجمة ديناميكياً (نفس منطقك الأصلي)
                final String displayName = (context.locale.languageCode == 'en')
                    ? (item.subcatNameEn ?? item.subcatName) // احتياط للعربي في حال غياب الإنجليزي
                    : item.subcatName;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[100],
                        // 🖼️ استدعاء دالة بناء الصورة الذكية المجهزة بالفحص ومؤشر التحميل
                        child: ClipOval(
                          child: CustomNetworkImage(
                            imageUrl: ApiEndpoints.subCategoryImageUrl(item.subcatImage), // ممرر رابط الصورة مباشرة من الموديل
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.iconColor,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // 🔄 الانتقال الحقيقي لصفحة المنتجات وتمرير الـ IDs المطلوبة
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductScreens(
                              categoryID: item.catId,       // تمرير الـ id الحقيقي للقسم
                              subCategoryID: item.subcatId, // تمرير الـ id الحقيقي للفئة الفرعية
                            ),
                          ),
                        );
                      },
                    ),
                    // الخط الفاصل المتطابق مع تصميمك الأساسي
                    const Divider(indent: 10, endIndent: 10, thickness: 0.5),
                  ],
                );
              }), // نهاية الـ map
            ],
          );
        }

        // الحالة الافتراضية
        return const SizedBox();
      },
    );
  }
}