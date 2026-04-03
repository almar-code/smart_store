import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/user_profile.dart';
import '../category/category_bar.dart';
import '../subcategory/subcategory_drawer.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UserProfileOrLogin(
                isLoggedIn: false, // هنا نضع المتغير الحقيقي من الـ Cubit الخاص بك
                userName: "Ali Mutahar",
                userImageUrl: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png", // أو اتركها null للأيقونة
                onLoginTap: () {
                  // اذهب لصفحة تسجيل الدخول
                },
                onProfileTap: () {
                  // اذهب لصفحة الملف الشخصي
                },
              ),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark_seal, // أيقونة السهم بشكل عصري
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          CategoryBar(),
          CategoryItem(
            title: "الإلكترونيات",
            imagePath: "assets/images/imageedit_1_7845290883.jpg",
            onTap: () {},
          ),
          CategoryItem(
            title: "الملابس النسائية",
            imagePath: "assets/images/pexels-rdne-7249734.jpg",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
