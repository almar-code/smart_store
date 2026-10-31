import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/search/search_cubit.dart';
import '../../../views/screens/search/search_screen.dart';
import '../../../views/screens/similar%20products/similar_products.dart';
import '../../constants/app_colors.dart';
import '../../di/injection_container.dart' as di;
import '../icons/visual_search_icons.dart';

class App_Search extends StatelessWidget {
  final double widthFactor;
  final bool isSearchScreen ;
  final TextEditingController? controller;
  const App_Search({super.key, this.widthFactor = 0.4 , this.isSearchScreen =false,this.controller});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height:  isDesktop ? 35 : 30, // زيادة الارتفاع قليلاً ليعطي مظهرًا مريحًا وسهل الضغط
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(isDesktop ? 10 : 7), // حواف دائرية عصرية
        border: Border.all(
          color: AppColors.borderColor, // إطار خفيف جداً يبرز التصميم
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isDesktop ? 10 : 7),
        child: Row(
          children: [
            // 3. أيقونة الكاميرا للبحث بالصور في نهاية شريط البحث كزر مخصص
            Padding(
                padding:  EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 7),
                child: CameraSearchIcon()
            ),
            // 1. أيقونة البحث الأساسية في البداية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                CupertinoIcons.search,
                color: AppColors.primary.withOpacity(0.7), // استخدام لون الهوية الأساسي بجرأة خفيفة
                size: isDesktop ? 20 : 15,
              ),
            ),

            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  // إرسال الكلمة للكوبيت لتوليد الاقتراحات المنسدلة
                  context.read<SearchCubit>().onSearchTextChanged(value);
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<SearchCubit>().performGlobalSearch(value);
                  }
                },
                textAlignVertical: TextAlignVertical.center,
                readOnly: isSearchScreen ? false : true,
                onTap: isSearchScreen
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: tr('searchHere'),
                  hintStyle: TextStyle(
                    color: AppColors.textColor.withOpacity(0.4),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 14 : 13),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}