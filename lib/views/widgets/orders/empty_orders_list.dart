import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_store/views/screens/product/all_products_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';

class EmptyOrdersScreen extends StatelessWidget {
  const EmptyOrdersScreen({super.key});

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
              // يمكنك استخدام نفس أيقونة السلة أو تغييرها بأيقونة مخصصة للطلبات إن وجدت
              SvgPicture.asset(
                "assets/images/list-deshes.svg",
                width: isDesktop ? 90 : 60,
                colorFilter: ColorFilter.mode(AppColors.iconColor, BlendMode.srcIn),
              ),

              SizedBox(height: isDesktop ? 20 : 10),

              // العنوان
              Text(
                tr('orders_empty_title'), // تأكد من إضافة المفتاح في ملفات الترجمة أو استبداله بنص مؤقت
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
                tr('orders_empty_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 10,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: isDesktop ? 30 : 15),

              // زر تصفح المنتجات
              SizedBox(
                width: double.infinity,
                height: isDesktop ? 45 : 35,
                child: AppButton(
                  label: tr('shop_now'),
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.buttonColor,
                  textColor: Colors.white,
                  borderColor: AppColors.borderColor,
                  iconSize: 17,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AllProductsScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}