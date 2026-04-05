import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/app_colors.dart';
class UserProfileOrLogin extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final String? userImageUrl;
  final VoidCallback onLoginTap;
  final VoidCallback onProfileTap;
  final double avatarRadius;
  final bool isDrawer;

  const UserProfileOrLogin({
    super.key,
    required this.isLoggedIn,
    this.userName,
    this.userImageUrl,
    required this.onLoginTap,
    required this.onProfileTap,
    this.avatarRadius = 17,
    this.isDrawer=false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:isDrawer?80: 90,
      padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 1),
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isLoggedIn? avatarRadius + 1 :avatarRadius,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (isLoggedIn &&
                      userImageUrl != null &&
                      userImageUrl!.isNotEmpty)
                      ? NetworkImage(userImageUrl!)
                      : null,
                  child: (!isLoggedIn || userImageUrl == null)
                      ? Icon(
                    Icons.person,
                    size: avatarRadius * 1.2,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
              Text(
                isLoggedIn ? (userName ?? "User") : "username".tr(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconColor,
                ),
              ),
              if (!isDrawer && isLoggedIn)
                const Text(
                  "omar.abdu20187@gmail.com",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),

          isDrawer?
          IconButton(
            alignment: Alignment.topRight,
            icon: const Icon(
              CupertinoIcons.xmark_square_fill,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ):InkWell(
            onTap: isLoggedIn ? onProfileTap : onLoginTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLoggedIn? "log out".tr():"login".tr(),
                  style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.login_outlined,
                  color: AppColors.primary,
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}