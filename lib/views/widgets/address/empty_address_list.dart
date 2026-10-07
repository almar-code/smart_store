import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../screens/address/add_address_screen.dart';

class EmptyAddressScreen extends StatelessWidget {
  const EmptyAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Center(
      child: SizedBox(
        width: isDesktop ? 400 : 260,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة العناوين الفارغة
              Icon(
                Icons.location_off_outlined,
                size: isDesktop ? 90 : 60,
                color: AppColors.iconColor,
              ),

              SizedBox(height: isDesktop ? 20 : 10),

              // العنوان
              Text(
                tr('address_empty_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 10),

              // الوصف
              Text(
                tr('address_empty_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 11,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: isDesktop ? 30 : 20),

              // زر إضافة عنوان جديد
              SizedBox(
                width: double.infinity,
                height: isDesktop ? 45 : 35,
                child: AppButton(
                  label:  tr('add_address'),
                  icon: Icons.add_location_alt_outlined,
                  color: AppColors.buttonColor,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  iconSize: isDesktop ? 20 : 17,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddAddress(),
                      ),
                    );
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