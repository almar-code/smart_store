import 'package:flutter/material.dart';
import '../../core/constants/app_shadow.dart';
import '../../core/widgets/circularProgress.dart';
import '../../core/constants/app_colors.dart';
class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  Future<String> getData() async {
    await Future.delayed(const Duration(seconds: 1));
    return "تم جلب البيانات بنجاح";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // نستخدم ScreenUtil لتحديد الارتفاع ليكون متناسقاً
      height: 30,
      child: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgress(size: 20));
          }

          final List<Map<String, dynamic>> categories = List.generate(
            10,
                (index) => {"id": index, "cate_name": "Category $index"},
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                _buildInkWellItem(context, "الكل"),
                ...categories.map((item) => _buildInkWellItem(context, item["cate_name"])).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ويدجت للتعامل مع النقرات
  Widget _buildInkWellItem(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        // أضف الأكشن هنا
      },
      borderRadius: BorderRadius.circular(8),
      child: _buildCategoryItem(title),
    );
  }

  // تصميم العنصر (البطاقة مع الظل الثابت)
  Widget _buildCategoryItem(String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5), // حواف دائرية خفيفة
        boxShadow: AppShadow.commonShadow,
        border: Border.all(color: Colors.grey.withOpacity(0.1)), // إطار خفيف جداً
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
      ),
    );
  }
}