import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../../core/widgets/titleBar.dart';
import '../../widgets/product/all_products.dart';
import '../../widgets/product/product_details.dart';

//خلينا الكلاس هناStatefulWidget علشان افتح السطر المليان واغلقه
class ProductDetailsScreen extends StatefulWidget {
  final int? productID;
  final int? subCategoryID;
  final bool isExpanded ;

  ProductDetailsScreen({super.key,this.productID,this.subCategoryID,this.isExpanded=false});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late bool _localIsExpanded;
  int imag=8;

  @override
  void initState() {
    super.initState();
    // 2. تهيئة المتغير من القيمة القادمة من الـ widget مرة واحدة فقط عند التشغيل
    _localIsExpanded = widget.isExpanded;
  }
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          child: isDesktop
              ?_buildDesktopLayout(context)
              : SingleChildScrollView(
            child:_buildMobileLayout(context),
          ),
        ),
      ),
      bottomNavigationBar: isDesktop?null: ProductActionActions(),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        SizedBox(
          height: 400,
          child: ProductImageGallery(
            images: [
              "assets/images/8.jpg",
              "assets/images/1.jpg",
              "assets/images/2.jpg",
              "assets/images/3.jpg",
              "assets/images/4.jpg",
              "assets/images/5.jpg",
              "assets/images/6.jpg",
              "assets/images/9.jpg",
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildProductInfo(),
        ),
        TitleBar(title: "product like"),
        AllProducts(
          productID: widget.productID,
          subCategoryID: 2,
          onProductTap: (id) => _navigateToProduct(context, id),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                 Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     ProductImageSlider(images: ['assets/images/1.jpg', 'assets/images/2.jpg', 'assets/images/3.jpg']),
                     SizedBox(
                         height: MediaQuery.of(context).size.height -330 ,

                         child: SingleChildScrollView(child: _buildProductInfo())),
                   ],
                 ),

             ProductActionActions(),
            ],
          ),
        ),

        const VerticalDivider(width: 20),

        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                TitleBar(title: "product like"),
                AllProducts(
                  productID: widget.productID,
                  subCategoryID: 2,
                  onProductTap: (id) => _navigateToProduct(context, id),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo( ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    
      spacing: 10,
      children: [
        SizedBox(height: 5,),
        InkWell(
          onTap: () {
            setState(() {
              _localIsExpanded = !_localIsExpanded;
            });
          },
          child: Text(
            "product like the past every top the past every top the pas  top the past every top the pas  top the past every top the pas .",
            style: TextStyle(
                color: AppColors.textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold
            ),
            maxLines: _localIsExpanded ? null : 1,
            overflow: _localIsExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        Text("85.00 ر.س", style: TextStyle(color: AppColors.textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        Divider(color: AppColors.textSecondary, thickness: 0.2),
        TitleBar(title: "color : red", isDecoration: false, color: AppColors.primary),
        const ProductColorSelector(colors: [
          {"imagePath": 'assets/images/1.jpg', "code": "#026789"},
          {"imagePath": 'assets/images/2.jpg', "code": "#000000"},
          {"imagePath": 'assets/images/2.jpg', "code": "#000000"},
        ]),
        const SizedBox(height: 7),
        TitleBar(title: 'sizes', isDecoration: false),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: const ProductSizeSelector(sizes: ['60', '50', '43', '57']),
        ),
      ],
    );
  }
  void _navigateToProduct(BuildContext context, int id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(productID: id)));
  }
}
