import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/data/services/product_service.dart';
import 'package:smart_store/data/services/subcategory_service.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/scroll_wrapper.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../data/repos/product_repo.dart';
import '../../../data/repos/subcategory_repo.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
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
  final int? categoryID;

  const ProductScreens({
    super.key,
    this.categoryID,
    this.subCategoryID,
    this.productID,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return MultiBlocProvider(
      providers: [
        BlocProvider<SubcategoryCubit>(
          create: (context) => SubcategoryCubit(SubcategoryRepo(SubcategoryService()))..getSubcategories(categoryId:categoryID ),
        ),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(repository: ProductRepo(apiService:ProductService() ))
            ..fetchProducts(
              subCatId: subCategoryID,
              productId: productID,
              isRefresh: true,
            ),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            leadingWidth: 0,
            titleSpacing: 3,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [FavoriteIcon(), CartIcon(), SizedBox(width: 7)],
            ),
            actions: [
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                ),
                child: App_Search(widthFactor: isDesktop ? 0.3 : 0.64),
              ),
              ArrowBack(),
            ],
          ),
          body: Builder(
            builder: (blocContext) {
              return RefreshIndicator(

                onRefresh: () async {
                  if(categoryID != null){
                    blocContext.read<SubcategoryCubit>().getSubcategories(categoryId: categoryID);
                  }
                  await blocContext.read<ProductCubit>().fetchProducts(
                      subCatId: subCategoryID,
                      productId: productID,
                      isRefresh: true
                  );
                },
                color: AppColors.primary, // لون مؤشر التحميل (يمكنك ربطه بهوية المشروع)
                backgroundColor: AppColors.backgroundSecondary,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (subCategoryID != null && categoryID != null)
                        SubcategoryBar(),
                      Expanded(
                        child: ScrollWrapper(
                          bottom: 5,
                          child: AllProducts(
                            showAddToCart: true,
                            onProductTap: (product) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsScreen(product: product,),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [SmartFloatingButton(), CartFloatingButton()],
          ),
        ),
      ),
    );
  }
}
