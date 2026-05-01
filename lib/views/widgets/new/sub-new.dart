import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
      child: FutureBuilder(
          future: getNewProducts(),
          builder: (context, asyncSnapshot) {
            final products = asyncSnapshot.data ?? [];
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return DiscountsShimmer();
            }
            return MasonryGridView.count(
              scrollDirection: Axis.vertical,
              crossAxisCount:isDesktop ? 6 : 3,
              mainAxisSpacing: 10, //مسافة بين العنصر والذي تحتة
              crossAxisSpacing: 10, //مسافة بين العنصر والذي جنبة
              shrinkWrap: true, //حجم حسب الاب
              itemCount: products.length,
              physics: NeverScrollableScrollPhysics(), //توقيف الشريط
              itemBuilder: (context, index) {
                final item = products[index];
                return Container(
                  width: isDesktop ? 115 :100,
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