import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_store/views/widgets/product/productdetailsheet.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../screens/product/products_screen.dart';
class AllProducts extends StatelessWidget {
   final int? subCategoryID;
   final int? productID;
   final bool showAddToCart ;
   final Function(int id)? onProductTap;
  const AllProducts({super.key,this.subCategoryID,this.productID,this.showAddToCart=false,this.onProductTap});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    List<Map<String, dynamic>> products = List.generate(
      9,
          (index) => {"image" : "assets/images/${index}.jpg","price": 100, "newPrice":70, "discount":30,"colors":[{"colorName":"اسود","code":"#000000"},{"colorName":"بني","code":"#A0522D"},{"colorName":"رمادي","code":"#D3D3D3"},{"colorName":"green","code":"#470299"}]},
    );
    return  MasonryGridView.count(
      scrollDirection: Axis.vertical,
      crossAxisCount:isDesktop ? 6 : 2,
      mainAxisSpacing: 15, //مسافة بين العنصر والذي تحتة
      crossAxisSpacing: 12, //مسافة بين العنصر والذي جنبة
      shrinkWrap: true, //حجم حسب الاب
      itemCount: products.length,
      physics: NeverScrollableScrollPhysics(), //توقيف الشريط
      itemBuilder: (context, index) {
        var item=products[index];
        int currentId = index;
        return InkWell(
          onTap: () {
            if (onProductTap != null) {
              onProductTap!(currentId);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductScreens(productID: currentId,subCategoryID: 2,category: 2,)),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: AppColors.boxShadow,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                ...AppShadow.commonShadow, // دمج ظلالك الخاصة
              ],
            ),
            child: Column(
              spacing: 6,
              children: [
                //  الصورة + badge الخصم
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.cover,
                      ),
                    ),

                    //  اللوان المنتج
                    Positioned(
                      top: 3,
                      right: 7,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2,horizontal: 2,),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          spacing: 5,
                          children: [

                            ...item['colors'].take(3).map((color){
                              return CircleOfColor(code: color['code'],width: isDesktop ? 14 :12,height: isDesktop ? 14 :12);}).toList(),
                            (item['colors'].length <= 3) ? SizedBox() : Text(
                              "+${item['colors'].length-3}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 10 :9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],

                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child:GestureDetector(
                        onTap: () {
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.heart,
                            color:  AppColors.iconColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 36,
                      left: 8,
                      child:GestureDetector(
                        onTap: () {
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_2_outlined,
                            color: AppColors.iconColor,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Kagole abaya',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),),
                  ),
                ),
                // 💰 السعر
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 1,
                            children: [
                              Text(
                                "${item['newPrice']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color:  AppColors.primary,
                                ),
                              ),
                              Text(
                                "\$",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 11,
                                  color:  AppColors.primary,
                                ),
                              ),
                            ],
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
                      showAddToCart? InkWell(
                        onTap: () => ProductDetailsDialog.show(context),

                        child: Card(
                          color: AppColors.backgroundSecondary,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: AppColors.borderColor.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 2),
                            child: Icon(
                              CupertinoIcons.cart_badge_plus,
                              color:  AppColors.iconColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ):SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },

    );
  }
}
