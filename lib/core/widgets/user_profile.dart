import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/app_colors.dart';

class UserProfileOrLogin extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final String? userImageUrl;
  final VoidCallback onLoginTap;
  final VoidCallback onProfileTap;
  final double avatarRadius; // أضفنا هذا للتحكم بالحجم حسب المكان

  const UserProfileOrLogin({
    super.key,
    required this.isLoggedIn,
    this.userName,
    this.userImageUrl,
    required this.onLoginTap,
    required this.onProfileTap,
    this.avatarRadius = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.grey[300],
              backgroundImage: (isLoggedIn && userImageUrl != null && userImageUrl!.isNotEmpty)
                  ? NetworkImage(userImageUrl!)
                  : null,
              child: (!isLoggedIn || userImageUrl == null)
                  ? Icon(Icons.person, size: avatarRadius * 0.8, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            InkWell(
              onTap: isLoggedIn ? onProfileTap : onLoginTap,
              child: Text(
                isLoggedIn ? (userName ?? "User") : "login".tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: !isLoggedIn ? AppColors.primary : AppColors.iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}