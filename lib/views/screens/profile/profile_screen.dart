import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/user_profile.dart';
import '../home/home_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>  Scaffold(
    appBar: AppBar(
        toolbarHeight: 90, // تحديد نفس ارتفاع الودجيت
        titleSpacing: 0,
     title:  UserProfileOrLogin(
       avatarRadius:20,
       isLoggedIn: true,
       userName: "Ali Mutahar",
       userImageUrl: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png", // أو اتركها null للأيقونة
       onLoginTap: () {
       },
       onProfileTap: () {
       },
     )

    ),
      body: Center(child: Text("Profile Page")
      ));
}