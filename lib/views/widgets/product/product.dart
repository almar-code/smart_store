import 'package:flutter/material.dart';
import '../subcategory/subcategory_bar.dart';
import 'all_products.dart';

class Product extends StatelessWidget {
  final int? subCategoryID;
  final int? productID;
  final int? category;
   Product({super.key,this.productID,this.subCategoryID,this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(

        children: [
          if( subCategoryID!= null && category !=null)
            Expanded(child: SubcategoryBar()),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
                child: AllProducts(productID: productID,subCategoryID: subCategoryID,showAddToCart: true,)),
          )
        ],
      ),
    );
  }
}
