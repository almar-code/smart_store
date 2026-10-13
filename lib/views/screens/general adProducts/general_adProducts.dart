import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/scroll_wrapper.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../data/repos/AdRepo.dart';
import '../../../data/models/product_model.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/repos/product_repo.dart';
import '../../../logic/products/product_cubit.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/product/all_products.dart';
import '../product/product_details_screen.dart';

class GeneralAdProductsScreen extends StatelessWidget {
  final int adsId;
  final String adTitle;

  const GeneralAdProductsScreen({
    super.key,
    required this.adsId,
    required this.adTitle,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocProvider<ProductCubit>(
          create: (context) =>
          ProductCubit(repository: di.sl<ProductRepo>())
            ..fetchProducts(
                isRefresh: true,
                adsId: adsId
            ),


      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            titleSpacing: 10,
            elevation: 0,
            title: Row(
              children: [
                // إيقونة الإعلان / الخصم المصغرة
                Image.asset(
                  'assets/images/discount.png',
                  height: isDesktop ? 26 : 20,
                  width: isDesktop ? 26 : 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                // العنوان الديناميكي يأخذ اسم الإعلان
                Expanded(
                  child: Text(
                    adTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
            actions:  [
              FavoriteIcon(),
              CartIcon(),
              ArrowBack(),
            ],
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: di.sl<AdRepo>().fetchGeneralAdProducts(adsId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ThreeDotsLoader());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return  Center(
                  child: Text(
                    'عذراً، حدث خطأ أثناء تحميل المنتجات',
                    style: TextStyle(color: AppColors.textColor),
                  ),
                );
              }

              final List<ProductModel> products = snapshot.data!['products'] ?? [];

              if (products.isEmpty) {
                return  Center(
                  child: Text(
                    'لا توجد منتجات مرتبطة بهذا الإعلان حالياً',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ScrollWrapper(
                        bottom: 5,
                        child: AllProducts(
                          showAddToCart: true,
                          // تمرير القائمة الخاصة بالإعلان إذا كان AllProducts يدعم تمرير القائمة أو استخدام شبكة العرض الخاصة بك
                          onProductTap: (product) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [
              SmartFloatingButton(),
              CartFloatingButton(),
            ],
          ),
        ),
      ),
    );
  }
}