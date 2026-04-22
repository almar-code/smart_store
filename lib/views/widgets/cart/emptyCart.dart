import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return  Center(
      child: SizedBox(
        width:isDesktop? 400 :250,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 🛒 أيقونة السلة
              SvgPicture.asset(
                "assets/images/shopping.svg",
                width: isDesktop? 90 :60,
                color: AppColors.iconColor,
              ),

              SizedBox(height: isDesktop? 20 :10),

              // العنوان
              Text(
                tr('cart_empty_title'),
                style: TextStyle(
                  fontSize:isDesktop? 20 :15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              // الوصف
              Text(
                tr('cart_empty_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop? 14 :10,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: isDesktop ? 30 :15),

              // زر تسجيل الدخول
              SizedBox(
                  width: double.infinity,
                  height: isDesktop? 50 :30,
                  child:AppButton(label: tr('sign_in_register'),icon: Icons.person_2_outlined,color:AppColors.background ,textColor: AppColors.textColor,borderColor: AppColors.borderColor,iconSize: 17,)
              ),
              const SizedBox(height: 15),
              SizedBox(
                  width: double.infinity,
                  height: isDesktop? 50 :30,
                  child:AppButton(label: tr('shop_now'),icon: Icons.shopping_bag_outlined,color:AppColors.buttonColor ,textColor: Colors.white,borderColor: Colors.black,iconSize: 17,)
              )
            ],
          ),
        ),
      ),
    );
  }
}