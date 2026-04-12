import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import 'dart:ui';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/text/viewMoreText.dart';
import '../flash/flash_screen.dart';

class DiscountsUI extends StatelessWidget {
  DiscountsUI({super.key});
  Future<List<Map<String, dynamic>>> getDiscounts() async {
    await Future.delayed(const Duration(seconds: 3));
    return List.generate(
      6,
          (index) => {"image" : "assets/images/${index}.jpg","price": 100, "newPrice":70, "discount":30},
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return SizedBox(
      height: isDesktop ? 170 : 155,
      child: FutureBuilder(
          future: getDiscounts(),
          builder: (context, asyncSnapshot) {
            final products = asyncSnapshot.data ?? [];
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return DiscountsShimmer();
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length + 1,

              itemBuilder: (context, index) {

                // 🔥 كرت مشاهدة المزيد
                if (index == products.length) {
                  return Container(
                    width: isDesktop ? 130 :100,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        SizedBox(height: 8),

                        ViewMoreText(fontSize: 13,),

                      ],
                    ),
                  );
                }

                final item = products[index];

                return Container(
                  width: isDesktop ? 125 :100,
                  height: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: AppShadow.commonShadow,
                  ),
                  child: Column(
                    children: [

                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                            child: Image.asset(
                              item['image'],
                              height: isDesktop ? 130 :120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        ],
                      ),


                      // 💰 السعر
                      Column(

                        spacing: 3,
                        children: [
                          Text(
                            "عبايه رغد",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "${item['price']} \$",
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          ]
                      ),
                    ],
                  ),
                );
              },
            );
          }
      ),
    );
  }
}