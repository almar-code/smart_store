import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/icons/social_icons.dart';
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 0,
                    child: UserProfile(isLoggedIn: true,isDrawer: true,),
                  ),
                  SizedBox(height: 10,),
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
              PositionedDirectional(
                top: 2,
                end: 2,
                child:IconButton(
                  alignment: Alignment.topRight,
                  icon:  Icon(
                    CupertinoIcons.xmark_square_fill,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ) ,
              ),
              PositionedDirectional(
                bottom: 2,
                  child:  SocialIcons(padding: 10,))
            ],
          ),
        ),
      ),
    );
  }
}
