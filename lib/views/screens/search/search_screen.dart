import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../../core/widgets/titleBar.dart';
import '../../widgets/product/all_products.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 0,
        titleSpacing:3,
        title:App_Search(widthFactor:1),
        actions: [
          ArrowBack()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  // إضافة ظل خفيف جداً لتمييز البار العلوي
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
                    Text(
                      tr('searchHistory'),
                      style: TextStyle(
                        fontSize: isDesktop?15:12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
          
                    // الجزء الأيسر: زر مشاهدة المزيد
                    InkWell(
                      onTap: () {
                        // اضف التنقل لصفحة العروض هنا
                      },
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.delete,color: AppColors.iconColor,size: 15,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                direction: Axis.horizontal,
                // الـ alignment الأساسي (للأفقي)
                alignment: WrapAlignment.start,
                // الـ crossAxisAlignment (للرأسي داخل السطر الواحد)
                crossAxisAlignment: WrapCrossAlignment.start,
                // مسافات بين العناصر لضمان عدم الالتصاق
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildInkWellItem(context,"abayas"),
                  _buildInkWellItem(context,"abayas"),
                  _buildInkWellItem(context,"abayas kajol"),
                  _buildInkWellItem(context,"abayas"),
                  _buildInkWellItem(context,"abayas"),
                ],
              ),
              TitleBar(title: tr('SearchResults'),),
              AllProducts(),
          
            ],
          ),
        ),
      ),);
  }
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      // alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
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