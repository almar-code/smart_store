import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🔵 استيراد البلوك
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../screens/product/products_screen.dart';
import '../flash/flash_screen.dart';

// استيراد الطبقات الجديدة المنطقية والموديل الخاص بك
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../../../logic/subcategories/subcategory_state.dart';
import '../../../data/models/subcategory_model.dart';

class SubcategoryBar extends StatelessWidget {
  const SubcategoryBar({super.key});


  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    // 🔵 استبدال FutureBuilder بـ BlocBuilder للاستماع للحالات الحقيقية
    return BlocBuilder<SubcategoryCubit, SubcategoryState>(
      builder: (context, state) {

        // 1. حالة التحميل (Loading)
        if (state is SubcategoryLoading) {
          return const Flashsubcategory();
        }

        // 2. حالة الخطأ (Error)
        if (state is SubcategoryError) {
          return const Center(
            child: Text("حدث خطأ في جلب الفئات الفرعية"),
          );
        }

        // 3. حالة النجاح واستلام البيانات (Success)
        if (state is SubcategoryLoaded) {
          final subcategories = state.subcategories; // قائمة الموديلات الحقيقية SubcategoryModel

          // إذا كانت القائمة فارغة تماماً من السيرفر
          if (subcategories.isEmpty) {
            return const SizedBox();
          }

          int rowCount = (subcategories.length > 30) ? 2 : 1;
          double height = (subcategories.length > 30) ? 180 : 83;

          return SizedBox(
            height: isDesktop ? height : 70, // تصميمك الأصلي
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 2),
              itemCount: subcategories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? rowCount : 1, // صفين في اللابتوب - صف في الجوال
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: isDesktop ? 80 : 55, // عرض العنصر
              ),
              itemBuilder: (context, index) {
                final item = subcategories[index]; // الكائن الآن من نوع SubcategoryModel
                final String displayName = (context.locale.languageCode == 'en')
                    ? (item.subcatNameEn ?? item.subcatName) // إذا كان الإنجليزي فارغاً يعود للعربي كاحتياط
                    : item.subcatName;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreens(
                          categoryID: item.catId, //  تمرير الـ id الحقيقي للقسم
                          subCategoryID: item.subcatId, //  تمرير الـ id الحقيقي للفئة الفرعية
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomNetworkImage(
                          imageUrl: item.subcatImage, // ممرر رابط الصورة مباشرة من الموديل
                          width: isDesktop ? 55 : 45,
                          height: isDesktop ? 55 : 45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: isDesktop ? 11 : 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        // الحالة الافتراضية
        return const SizedBox();
      },
    );
  }
}