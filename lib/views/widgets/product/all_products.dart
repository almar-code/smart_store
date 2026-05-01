import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_store/views/widgets/product/productdetailsheet.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../core/widgets/customCategoryList.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../screens/product/products_screen.dart';
import '../../screens/similar products/similar_products.dart';
class AllProducts extends StatelessWidget {
   final int? subCategoryID;
   final int? productID;
   final bool showAddToCart ;
   final bool isDiscount ;
   final Function(int id)? onProductTap;
  const AllProducts({super.key,this.subCategoryID,this.productID,this.showAddToCart=false,this.onProductTap,this.isDiscount=false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    List<Map<String, dynamic>> products = List.generate(
      12,
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
                      child: _buildProductImage(item),
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
                    isDiscount ? Positioned(
                      top: 8,
                      left: 8,
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
                    ) : SizedBox(),
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
                            color: AppColors.backgroundSecondary,
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
                        onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SimilarProducts())),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.center_focus_strong_outlined,
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
Widget _buildProductImage(dynamic item) {
  // 1. التأكد أولاً ما إذا كان الرابط موجود نهائياً أم لا
  if (item['image'] == null || item['image'].toString().isEmpty) {
    // إذا لم تكن هناك صورة نهائياً، اعرض الصورة الوهمية فوراً
    return _buildFakeImage();
  }

  // 2. إذا كان الرابط موجود، نحاول تحميل الصورة
  return Image.network(
    item['image'],
    fit: BoxFit.cover,

    // -- مؤشر التحميل (كما هو في كودك السابق) --
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        // الصورة انتهى تحميلها
        return child;
      }
      return Container(
        color: AppColors.backgroundSecondary,
        width: double.infinity,
        height: 250,
        child: Center(child: ThreeDotsLoader()), // جاري التحميل
      );
    },

    // -- 3. التعامل مع الأخطاء (إذا انكسر الرابط أو فشل التحميل) --
    errorBuilder: (context, error, stackTrace) {
      // في حال حدوث أي خطأ، اعرض الصورة الوهمية
      return _buildFakeImage();
    },
  );
}

Widget _buildFakeImage() {
  return Image.asset(
    'assets/images/image_placeholder.png',
    fit: BoxFit.contain,
  );
}