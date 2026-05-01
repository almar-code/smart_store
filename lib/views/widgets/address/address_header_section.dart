import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/underlined_title.dart';
class AddressHeaderSection extends StatelessWidget {
  final Function(String)? onSearchChanged;
  final VoidCallback? onAddPressed;

  const AddressHeaderSection({
    super.key,
    this.onSearchChanged,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      margin:  EdgeInsets.all(isDesktop ? 16 : 8,),
      padding:  EdgeInsets.all(isDesktop ? 16 : 5,),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(-3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // 3. العنوان مع الخط الأخضر
          UnderlinedTitle(
            firstPart:(context.locale.languageCode == 'en') ? tr('addresses') : tr('list'),
            secondPart: (context.locale.languageCode == 'en') ? tr('list') : tr('addresses'),
            fontSize: isDesktop ? 16 : 14,
          ),
          // 1. زر إضافة عنوان

          Row(
            spacing: isDesktop ? 12 : 5,
            children: [
              // 2. حقل البحث
              isDesktop  ? ConstrainedBox(
                constraints:  BoxConstraints(
                  maxWidth: isDesktop ? 350 : 140, // هنا نحدد أنه لن يكبر عن 150 بكسل مهما كانت الشاشة واسعة
                ),
                child: SizedBox(
                  height: isDesktop ? 38 : 25,
                  child: TextField(
                    onChanged: onSearchChanged,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: AppColors.textColor, fontSize: isDesktop ? 14 : 10),
                    decoration: InputDecoration(
                      hintText: tr('searchHere'),
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize:isDesktop ? 13 : 10,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: isDesktop ? 18 : 15,
                      ),
                      contentPadding:  EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 5,),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 7 : 4,),
                        borderSide: BorderSide(
                          color: AppColors.borderColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                ),
              ) : SizedBox(),
              SizedBox(
                height: isDesktop ? 38 : 25,
                child: AppButton(
                  label: tr('add_address'),
                  icon: Icons.add,
                  fontSize: isDesktop ? 14 : 10,
                  onTap: onAddPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}