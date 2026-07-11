import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_store/core/widgets/scroll_wrapper.dart';
import 'package:smart_store/logic/cart/cart_cubit.dart';
import 'package:smart_store/logic/cart/cart_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../widgets/cart/emptyCart.dart';
import '../../widgets/flash/flash_screen.dart';
import '../address/select_user_address_screen.dart';

class CartScreen extends StatelessWidget {
  final bool screenOnly;
  const CartScreen({super.key,this.screenOnly =false});
  @override
  Widget build(BuildContext context){
    bool isDesktop = MediaQuery.of(context).size.width > 1000;
    bool isIpad = MediaQuery.of(context).size.width < 1000 &&  MediaQuery.of(context).size.width > 450;
    int itemCount = isDesktop ? 3 : isIpad ? 2 : 1;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
          leading:Icon(
            CupertinoIcons.cart,
            color:  AppColors.iconColor,
            size: isDesktop ? 22 : 20,
          ),
          titleSpacing:isDesktop ? 0 : 0,
          title: AppTitle(firstPart: tr('cartShopping'),secondPart: tr('shopping'),fontSize: isDesktop?18: 15,spacing: ' ',),
          actions: [
          screenOnly ? ArrowBack() : SizedBox(),
          ],
        ),
        body:RefreshIndicator(
          onRefresh: () async {
            context.read<CartCubit>().fetchCart(customerId: 1);
          },
          color: AppColors.primary, // لون مؤشر التحميل (يمكنك ربطه بهوية المشروع)
          backgroundColor: AppColors.backgroundSecondary,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
            child: BlocBuilder<CartCubit,CartState>(
                builder: (context,state) {
                if (state is CartLoading) {
                  return MasonryGridShimmer();
                }
                if (state is CartEmpty) {
                  return EmptyCartScreen();
                }
                if (state is CartError) {
                  return Center(
                    child:  SizedBox(
                      height: 30,
                      width: 120,
                      child: RefreshButton(onPressed: () async {
                        await context.read<CartCubit>().fetchCart(customerId: 1);
                      }),
                    ),
                  );
                }
                if (state is CartLoaded) {
                  final products = state.cartItems;
                  if (products.isEmpty) {
                    return EmptyCartScreen();
                  }
                  return ScrollWrapper(
                    bottom: 0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 600, // 🌟 هذا هو الحد الأدنى للطول (أصغر حجم مسموح به)
                      ),
                      child: Column(
                        children: [
                          MasonryGridView.count(
                              scrollDirection: Axis.vertical,
                              crossAxisCount: itemCount,
                              mainAxisSpacing: 15,
                              //مسافة بين العنصر والذي تحتة
                              crossAxisSpacing: 12,
                              //مسافة بين العنصر والذي جنبة
                              shrinkWrap: true,
                              //حجم حسب الاب
                              itemCount: products.length,
                              physics: NeverScrollableScrollPhysics(),
                              //توقيف الشريط
                              itemBuilder: (context, index) {
                                var item = products[index];
                                int currentId = item.productId;
                                // 🌟 منطق حساب الخصومات الديناميكية القادمة من لارافيل
                                bool hasDiscount = item.discount != null;

                                double discountAmount = hasDiscount ? (item.discount!.discountPerce ?? 0) : 0;

                                double newPrice = hasDiscount ? (item.productPrice - discountAmount) : item.productPrice;

                                double discountPercent = 0;
                                if (hasDiscount && item.productPrice > 0) {
                                  discountPercent = ((discountAmount / item.productPrice) * 100).round().toDouble();                                }
                                return Container(
                                  key: ValueKey(item.cartId),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
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
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: [

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(7),
                                              child:  Image.network(
                                                ApiEndpoints.productImageUrl(item.selectedColor?.images.first.imgUrl ),
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    color: AppColors.background,
                                                    width:100,
                                                    height: 100, // طول الصورة الأصلي الثابت في كودك
                                                    child: Center(child: ThreeDotsLoader()),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    width:100,
                                                    height: 100, // طول الصورة الأصلي الثابت في كودك
                                                    'assets/images/image_placeholder.png',
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    context.locale.languageCode =='ar' ? item.productName : item.productNameEn ?? "",
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
                                                        style: TextStyle(fontSize: 12,
                                                            color: AppColors
                                                                .textSecondary),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item.selectedSize?.sizeName ?? "",
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
                                                        style: TextStyle(fontSize: 12,
                                                            color: AppColors
                                                                .textSecondary),
                                                      ),
                                                      SizedBox(width: 6),
                                                      CircleOfColor(width: 12,
                                                          height: 12,
                                                          code: item.selectedColor?.colorCode ?? "#000000")
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),

                                                  ///  السعر
                                                  Row(
                                                    spacing: 8,
                                                    children: [
                                                      Row(
                                                        spacing: 1,
                                                        children: [
                                                          Text(
                                                            newPrice.toStringAsFixed(2), // السعر الجديد بعد الحساب برمجياً
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 12,
                                                              color: AppColors.primary,
                                                            ),
                                                          ),
                                                          Text(
                                                            "\$",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 11,
                                                              color: AppColors.textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      hasDiscount
                                                          ? Text(
                                                        "${item.productPrice} \$", // السعر الأصلي مشطوباً
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: AppColors.textSecondary,
                                                          decoration: TextDecoration.lineThrough,
                                                        ),
                                                      )
                                                          : const SizedBox(),
                                                    ],
                                                  )

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
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [

                                              const SizedBox(width: 8),
                                              InkWell(
                                                  onTap: (){
                                                    item.quantity > 1 ?
                                                    context.read<CartCubit>().updateItemQuantity(
                                                      customerId: 1,
                                                      product: item,
                                                      newQuantity: item.quantity - 1,
                                                    ): context.read<CartCubit>().deleteItemFromCart(customerId: 4, cartId: item.cartId,product: item,context: context);
                                                  },
                                                  child: item.quantity == 1 ? Icon(Icons.delete_outline, size: 16) : Icon(Icons.remove, size: 16)),

                                              const SizedBox(width: 10),
                                               Text(
                                                "${item.quantity}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),

                                              const SizedBox(width: 10),
                                              InkWell(
                                                onTap: (){
                                                  context.read<CartCubit>().updateItemQuantity(
                                                    customerId: 1,
                                                    product: item,
                                                    newQuantity: item.quantity + 1,
                                                  );
                                                },
                                                  child: const Icon(Icons.add, size: 16)),

                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                        ),)
                                    ],
                                  ),
                                );
                              }
                          ),
                          SizedBox(height: 60,),
                        ],
                      ),
                    ),
                  );
                }
                return Center(
                  child:  SizedBox(
                    height: 30,
                    width: 120,
                    child: RefreshButton(onPressed: () async {
                      await context.read<CartCubit>().fetchCart(customerId: 1);
                    }),
                  ),
                );;
              }
            ),
          ),
        ),
        floatingActionButton: SmartFloatingButton(),
        bottomNavigationBar: BlocBuilder<CartCubit,CartState>(
          builder: (context,state) {
            if (state is CartLoaded) {
              return Container(
                height: isDesktop ? 55 : 90,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.1),
                ),
                child: Column(
                  spacing: isDesktop ? 0 : 10,
                  children: [
                    !isDesktop ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 10,
                      children: [

                        /// الإجمالي
                        _priceItem("${state.totalPrice}", tr('total')),

                        /// الخصم
                        _priceItem("${state.totalDiscount}", tr('discount'), isDiscount: true),

                        /// الصافي
                        _priceItem("${state.totalPrice - state.totalDiscount}", tr('subtotal'), isTotal: true),
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
                            _priceItem("${state.totalPrice}", tr('total')),

                            /// الخصم
                            _priceItem("${state.totalDiscount}", tr('discount'), isDiscount: true),

                            /// الصافي
                            _priceItem("${state.totalPrice - state.totalDiscount}", tr('subtotal'), isTotal: true),
                          ],
                        ) : SizedBox(),
                        SizedBox(width: isDesktop ? 30 : 0,),
                        isDesktop ? SizedBox(
                          width: 600,
                          child: AppButton(label: tr('checkout'),
                            icon: Icons.credit_card,
                            onTap: () =>
                                Navigator.of(context,).push(MaterialPageRoute(
                                    builder: (context) =>
                                        SelectUsrAddress())),),
                        ) : Expanded(
                          child: SizedBox(
                            height: 27,
                            child: AppButton(label: tr('checkout'),
                              icon: Icons.credit_card,
                              onTap: () =>
                                  Navigator.of(context,).push(MaterialPageRoute(
                                      builder: (context) =>
                                          SelectUsrAddress())),),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [ Color(0xFF25F5FC), Color(0xFF03C383)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child:  Text(
                           '${context.watch<CartCubit>().itemCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return SizedBox();
  },
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


