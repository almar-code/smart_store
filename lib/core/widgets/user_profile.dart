import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_title.dart';
import 'circleImage/circle_image.dart';
class UserProfile extends StatelessWidget {
  final bool isLoggedIn;
  final bool isDrawer;
  const UserProfile({super.key,this.isLoggedIn = true,this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return isLoggedIn ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: isDrawer ? (){} :(){
            showDialog(context: context, builder: (context){
              return CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0),
                child: CircleImage(
                  imagePath:
                  "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
                  radius: 150,
                  icon: CupertinoIcons.person,
                ),
              );
            });
          },
          child: CircleImage(
            imagePath:
            "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
            radius: isDesktop ? 23 : 20,
            icon: CupertinoIcons.person,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ali Mutahar',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: isDesktop ? 17 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "omar.abdu20187@gmail.com",
              style: TextStyle(fontSize: isDesktop ? 15 : 12, color: AppColors.textSecondary),
            )
          ],
        ),
      ],
    ) : Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 7,
      children: [
        CircleImage(
          imagePath:
          "Image_ez61caez61caez61.png",
          radius:  20,
          icon: CupertinoIcons.person,
        ),
        AppTitle(firstPart: 'Log',secondPart: 'in',),
      ],
    ) ;
  }
}
