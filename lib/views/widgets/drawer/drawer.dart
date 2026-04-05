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
          Expanded(
            flex: 0,
            child: UserProfileOrLogin(
              isLoggedIn: false,
              isDrawer:true,
              userName: "Ali Mutahar",
              userImageUrl: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
              onLoginTap: () {
              },
              onProfileTap: () {
              },
            ),
          ),
          Expanded(flex: 0, child: CategoryBar()),
          Expanded(
            flex: 4,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [

                CategoryItem(
                  title: "عبايه رغد ",
                  imagePath: "assets/images/imageedit_1_7845290883.jpg",
                  onTap: () {},
                ),
                CategoryItem(
                  title: "الفخامه ",
                  imagePath: "assets/images/pexels-rdne-7249734.jpg",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
