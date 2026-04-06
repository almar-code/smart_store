import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../widgets/cart/emptyCart.dart';
import '../../widgets/flash/flash_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context){
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    Future<List<Map<String, dynamic>>> getProducts() async {
      await Future.delayed(const Duration(seconds: 3));
      return List.generate(
        10,
            (index) => {"p_name" : "Kajol abaya","size" : "52","image" : "assets/images/${index}.jpg","price": 100, "newPrice":70, "discount":30,"colors":{"colorName":"اسود","code":"#000000"}},
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
        leading:Icon(
          CupertinoIcons.cart,
          color:  AppColors.iconColor,
          size: isDesktop?25: 20,
        ),
        titleSpacing:isDesktop?0: 0,
        title: AppTitle(firstPart: tr('cartShopping'),secondPart: tr('shopping'),fontSize: isDesktop?18: 15,spacing: ' ',)
      ),
      body:Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
        child: FutureBuilder(
          future: getProducts(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return MasonryGridShimmer();
            }
            if (!asyncSnapshot.hasData) {
              return EmptyCartScreen();
            }
            final products = asyncSnapshot.data ?? [];
            return MasonryGridView.count(
                scrollDirection: Axis.vertical,
                crossAxisCount:isDesktop ? 4 : 1,
                mainAxisSpacing: 15, //مسافة بين العنصر والذي تحتة
                crossAxisSpacing: 12, //مسافة بين العنصر والذي جنبة
                shrinkWrap: true, //حجم حسب الاب
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var item=products[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                        ...AppShadow.commonShadow, // دمج ظلالك الخاصة
                      ],
                    ),
                    child:Stack(
                      children: [
                        Row(
                          children: [

                            /// 🖼️ صورة المنتج
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child:Image.asset(
                                item['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                                      item['p_name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    /// المقاس
                                    Row(
                                      children: [
                                         Text(
                                          tr('size'),
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['size'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    ///  اللون
                                    Row(
                                      children: [
                                         Text(
                                          tr('color'),
                                          style: TextStyle(fontSize: 12, color:  AppColors.textSecondary),
                                        ),
                                         SizedBox(width: 6),
                                        CircleOfColor(width: 12,height: 12,code:item['colors']["code"])
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ///  السعر
                                    Text(
                                      "230 \$",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:  AppColors.textColor,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        PositionedDirectional(
                          bottom: 15,
                          end: 15,
                          child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [

                              SizedBox(width: 8),
                              Icon(Icons.remove, size: 16),

                              SizedBox(width: 10),
                              Text(
                                "1",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              SizedBox(width: 10),
                              Icon(Icons.add, size: 16),

                              SizedBox(width: 8),
                            ],
                          ),
                        ),)
                      ],
                    ),
                  );}
            );
          }
        ),
      ),
      bottomNavigationBar: Container(
        height:  isDesktop ? 55 : 85,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            !isDesktop ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 10,
              children: [
                /// الإجمالي
                _priceItem("250", tr('total')),
                /// الخصم
                _priceItem("20%", tr('discount'), isDiscount: true),
                /// الصافي
                _priceItem("230", tr('subtotal'), isTotal: true),
              ],
            ) : SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isDesktop ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    /// الإجمالي
                    _priceItem("250", tr('total')),
                    /// الخصم
                    _priceItem("20%", tr('discount'), isDiscount: true),
                    /// الصافي
                    _priceItem("230", tr('subtotal'), isTotal: true),
                  ],
                ) : SizedBox(),
                SizedBox(width:isDesktop ? 30 : 0,),
                isDesktop ? SizedBox(
                  width:600,
                  child: AppButton(label: tr('checkout'),icon: Icons.credit_card,),
                ) : Expanded(
                  child: AppButton(label: tr('checkout'),icon: Icons.credit_card,),
                ),
                SizedBox(width: 10,),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _priceItem(
      String price,
      String label, {
        bool isDiscount = false,
        bool isTotal = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          "$price",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? Colors.red
                : isTotal
                ? AppColors.primary
                : AppColors.textColor,
          ),
        ),
      ],
    );
  }
}


