import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/subcategory/subcategory_bar.dart';
import '../product/product_details_screen.dart';
import '../search/search_screen.dart';

class DiscountsScreen extends StatelessWidget {
  final int? subCategoryID;
  final int? productID;
  final int? category;
  DiscountsScreen({super.key,this.category,this.subCategoryID,this.productID});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return  Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        titleSpacing:10,
        elevation: 0,
        title: Row(
          children: [
            // الصورة المصغرة
            Image.asset(
              'assets/images/discount.png',
              height: isDesktop?28:20,
              width: isDesktop?28:20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 5),
            AppTitle(firstPart: tr('Nice'),secondPart: tr('discounts'),fontSize: isDesktop?18: 15,spacing: ' ',),

          ],
        ),
        actions: [
          FavoriteIcon(),
          CartIcon(),
          ArrowBack(),
        ],),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(

          children: [
            Expanded(

              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: AllProducts(productID: productID,
                      subCategoryID: subCategoryID,
                      showAddToCart: true,
                      isDiscount: true,
                      onProductTap: (id) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(productID: id)));
                      })),
            )
          ],
        ),
      ),

    );
  }
}
