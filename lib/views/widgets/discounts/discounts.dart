import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_shadow.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/text/viewMoreText.dart';
class Discounts extends StatelessWidget {
  const Discounts({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Column(
      children: [
        Container(
          height: 45, // زدنا الارتفاع قليلاً ليناسب الصورة والنص بوضوح
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            // إضافة ظل خفيف جداً لتمييز البار العلوي
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // الصورة المصغرة
                  Image.asset(
                    'assets/images/discount.jpg',
                    height: isDesktop?28:20,
                    width: isDesktop?28:20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tr('discounts'),
                    style: TextStyle(
                      fontSize: isDesktop?15:12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),

              // الجزء الأيسر: زر مشاهدة المزيد
              InkWell(
                onTap: () {
                  // اضف التنقل لصفحة العروض هنا
                },
                child: Row(
                  children: [
                    ViewMoreText(),
                    SizedBox(width: 4),
                    ArrowForwardIcon()
                  ],
                ),
              ),
            ],
          ),
        ),
        // الجزئ السفلي
        DiscountsUI()
      ],
    );
  }
}
class DiscountsUI extends StatelessWidget {
  DiscountsUI({super.key});
  final List<Map<String, dynamic>> products = List.generate(
    10,
        (index) => {"price": 100, "newPrice":70, "discount":30},
  );

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {

          // 🔥 كرت مشاهدة المزيد
          if (index == products.length) {
            return Container(
              width: isDesktop ? 130 :100,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background, // شفافية خفيفة
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: AppColors.borderColor,
                ),
                boxShadow: AppShadow.commonShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔁 أيقونة مناسبة (عرض المزيد)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: ArrowForwardIcon(size: 18,),
                  ),

                  SizedBox(height: 8),

                  ViewMoreText(fontSize: 13,),

                ],
              ),
            );
          }

          final item = products[index];

          return Container(
            width: isDesktop ? 130 :100,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(7),
              boxShadow: AppShadow.commonShadow,
            ),
            child: Column(
              children: [

                //  الصورة + badge الخصم
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                      child: Image.asset(
                        'assets/images/a4.jpg',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    //  badge الخصم
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${item['discount']}%",
                          style: TextStyle(
                            color:  Colors.white,
                            fontSize: isDesktop ? 11 :9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                // 💰 السعر
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Text(
                        "${item['newPrice']} \$",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:  AppColors.primary,
                        ),
                      ),
                      Text(
                        "${item['price']} \$",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}