import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';

class EmptyProductList extends StatelessWidget {
  const EmptyProductList({super.key});

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
              SvgPicture.asset(
                "assets/images/list-dashes.svg",
                width: isDesktop? 90 :60,
                color: AppColors.iconColor,
              ),

              SizedBox(height: isDesktop? 20 :10),

              // العنوان
              Text(
                tr('Not Found Products'),
                style: TextStyle(
                  fontSize:isDesktop? 20 :15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              // الوصف
              Text(
                tr('Not Found Products In Store'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop? 14 :10,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: isDesktop ? 30 :15),

              // زر تسجيل الدخول
            ],
          ),
        ),
      ),
    );
  }
}