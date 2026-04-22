import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import 'dart:ui';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/text/viewMoreText.dart';
import '../flash/flash_screen.dart';

class NewProducts extends StatelessWidget {
  const NewProducts({super.key});
  Future<List<Map<String, dynamic>>> getNewProducts() async {
    await Future.delayed(const Duration(seconds: 3));
    return List.generate(
      10,
          (index) => {"image" : "assets/images/${index}.jpg","price": 100, "newPrice":70, "discount":30},
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return SizedBox(
      height: isDesktop ? 180 : 165,
      child: FutureBuilder(
          future: getNewProducts(),
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
                  return (products.length > 9) ?  Container(
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
                  ) : SizedBox();
                }

                final item = products[index];

                return Container(
                  width: isDesktop ? 115 :100,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: AppShadow.commonShadow,
                  ),
                  child: Column(
                    spacing: 5,
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
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 2,
                        children: [
                          SizedBox(
                            child: Text(
                              'Kagole abaya',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                              ),),
                          ),
                          // 💰 السعر
                          SizedBox(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 1,
                                  children: [
                                    Text(
                                      "${item['newPrice']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color:  AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      "\$",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10,
                                        color:  AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${item['price']} \$",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
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