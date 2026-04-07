import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/views/widgets/product/product.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/search/app_search.dart';

class ProductScreens extends StatelessWidget {
  final int? subCategoryID;
  final int? productID;
  final int? category;
   ProductScreens({super.key,this.category,this.subCategoryID,this.productID});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading:IconButton(icon:Icon(Icons.arrow_back_ios_new_rounded,size: 18,) ,onPressed: (){
          Navigator.of(context).pop();
        },),

        title: Center(child: App_Search()),
        actions: [
          AppIcon(icon: CupertinoIcons.heart),
          AppIcon(icon: CupertinoIcons.cart),
        ],),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Product(category: category,subCategoryID: subCategoryID,productID: productID,),
      ),

    );
  }
}
