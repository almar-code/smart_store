import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadow.dart';
import 'circleImage/circle_image.dart';

class CustomCategoryList extends StatelessWidget {
  final String? title;
  final List<CategoryItemModel> items;

  const CustomCategoryList({
    super.key,
    this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary, // متوافق مع الوضع الليلي
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.borderSecondary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius:  15 ,
            offset: const Offset(0, 4),
          ),
          ...AppShadow.commonShadow,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 4, right: 4),
            child: Text(
              title ?? tr("you might like this"),
              style: TextStyle(
                fontSize: isDesktop ? 15 : 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // العناصر داخل البطاقة
          Wrap(
            spacing: 10, // مسافة أفقية
            runSpacing: 12, // مسافة رأسية
            children: items.map((item) => CategoryCard(
              title: item.title,
              imageUrl: item.imageUrl,
              onTap: item.onTap,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// موديل بسيط لتمرير البيانات بسهولة
class CategoryItemModel {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  CategoryItemModel({required this.title, required this.imageUrl, this.onTap});
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.2),
          ),
          child:ListTile(
            leading: CircleImage(
              imagePath: imageUrl,
              icon: Icons.image_rounded,
              radius: 14,
            ),

            // 2. العنوان مع التحكم في النصوص الطويلة
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isDesktop ? 12 : 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            // 3. أيقونة السهم داخل حاوية
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 9,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}