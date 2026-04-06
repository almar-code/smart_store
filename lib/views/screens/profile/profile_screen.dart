import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/widgets/user_profile.dart';
import '../../widgets/profile/profile_list.dart';
import 'package:easy_localization/easy_localization.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
    appBar: AppBar(

    ),
      body: Column(

        children: [
          SizedBox(
            height: 90,
            child: UserProfileOrLogin(
              avatarRadius:20,
              isLoggedIn: true,
              userName: "Ali Mutahar",
              userImageUrl: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png", // أو اتركها null للأيقونة
              onLoginTap: () {
              },
              onProfileTap: () {
              },
            ),
          ),
          Expanded(child: ProfileList()),
        ],
      ),
      );
  }
}