import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../views/widgets/login/login.dart';

class GuestPrompt extends StatelessWidget {
  final String? title;
  final String subtitle;
  const GuestPrompt({
    super.key,
    this.title,
    required this.subtitle
    ,});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Center(
      child: SizedBox(
        width: isDesktop ? 400 : 250,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/svg/user-plus.svg",
                width: isDesktop ? 90 : 60,
                colorFilter: ColorFilter.mode(AppColors.iconColor, BlendMode.srcIn),
              ),

              SizedBox(height: isDesktop ? 20 : 10),

              // العنوان
              Text(
                title ?? tr('guest_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.textColor,
                ),
              ),

              const SizedBox(height: 10),

              // الوصف
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 10,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: isDesktop ? 30 : 15),

              SizedBox(
                width: double.infinity,
                height: isDesktop ? 45 : 35,
                child: AppButton(
                  label: tr('sign_in_register'),
                  icon: Icons.person_2_outlined,
                  color: AppColors.buttonColor,
                  textColor: Colors.white,
                  borderColor: AppColors.borderColor,
                  iconSize: 17,
                  onTap: () {
                    Login login = Login();
                    if (context.mounted) {
                      login.loginDialog(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}