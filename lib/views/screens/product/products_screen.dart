import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'product_details_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/subcategory/subcategory_bar.dart';
import '../search/search_screen.dart';

class ProductScreens extends StatelessWidget {
  final int? subCategoryID;
  final int? productID;
  final int? category;
   ProductScreens({super.key,this.category,this.subCategoryID,this.productID});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return  Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leadingWidth: 0,
        titleSpacing:3,
        elevation: 0,
        title: Row(
          children: [
            FavoriteIcon(),
            CartIcon(),
            SizedBox(width: 7,),

          ],
        ),
        actions: [
          InkWell(
              onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SearchScreen())),
              child:  App_Search(widthFactor: isDesktop ?0.3 :0.64)),
          ArrowBack()
        ],),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(

          children: [
            if( subCategoryID!= null && category !=null)
              SubcategoryBar(),
            Expanded(

              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: AllProducts(productID: productID,
                    subCategoryID: subCategoryID,
                    showAddToCart: true,
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
