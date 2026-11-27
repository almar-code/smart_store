import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_store/logic/cart/cart_cubit.dart';
import 'package:smart_store/logic/cart/cart_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../core/widgets/guest_prompt.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/share_icon.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../data/local/user_local.dart';
import '../../../data/models/cart_model.dart';
import '../../../logic/login/login_cubit.dart';
import '../../widgets/cart/cart_edit_sheet.dart';
import '../../widgets/cart/cart_item_card.dart';
import '../../widgets/cart/cart_quick_menu.dart';
import '../../widgets/cart/cart_summary.dart';
import '../../widgets/cart/emptyCart.dart';
import '../../widgets/login/phone_number.dart';
import '../address/select_user_address_screen.dart';
import '../product/product_details_screen.dart';
import '../similar products/similar_products.dart';
import '../try_on/virtual_try_on_screen.dart';

class CartScreen extends StatelessWidget {
  final bool screenOnly;
  const CartScreen({super.key, this.screenOnly = false});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1000;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Icon(CupertinoIcons.cart, color: AppColors.iconColor, size: isDesktop ? 22 : 20),
          titleSpacing: 0,
          title: AppTitle(firstPart: tr('cartShopping'), secondPart: tr('shopping'), fontSize: isDesktop ? 18 : 15, spacing: ' '),
          actions: [
            // زر مشاركة السلة
            BlocBuilder<CartCubit, CartState>(
              buildWhen: (p, c) => c is CartLoaded || c is CartEmpty,
              builder: (context, state) => state is CartLoaded && context.read<LoginCubit>().state
                  ? IconButton(
                tooltip: tr('share_cart'),
                icon: Icon(CupertinoIcons.share, color: AppColors.iconColor, size: isDesktop ? 21 : 19),
                onPressed: () => _CartActions.shareCart(context),
              )
                  : const SizedBox(),
            ),
            screenOnly ? ArrowBack() : const SizedBox(),
          ],
        ),
        body: BlocBuilder<LoginCubit, bool>(
          builder: (context, loggedIn) {
            if (!loggedIn) {
              return GuestPrompt(subtitle: tr('cart_guest_subtitle'));
            }
            return BlocBuilder<CartCubit, CartState>(
              buildWhen: (p, c) => c is! CartAdding,
              builder: (_, state) => _CartBody(state: state, screenContext: context),
            );
          },
        ),
        floatingActionButton: SmartFloatingButton(),
        // شريط الملخص للجوال والايباد
        bottomNavigationBar: isDesktop
            ? null
            : BlocBuilder<LoginCubit, bool>(
          builder: (context, loggedIn) => BlocBuilder<CartCubit, CartState>(
            buildWhen: (p, c) => c is! CartAdding,
            builder: (context, state) {
              if (!loggedIn || state is! CartLoaded || state.cartItems.isEmpty) return const SizedBox.shrink();
              return CartSummaryBar(
                totalPrice: state.totalPrice,
                totalDiscount: state.totalDiscount,
                itemCount: context.read<CartCubit>().itemCount,
                onCheckout: () => _CartActions.checkout(context),
              ).animate().slideY(begin: 1, end: 0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
            },
          ),
        ),
      ),
    );
  }
}

// محتوى السلة حسب الحالة وحجم الشاشة
class _CartBody extends StatelessWidget {
  final CartState state;
  final BuildContext screenContext;

  const _CartBody({required this.state, required this.screenContext});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1000;
    final isIpad = width > 450 && width <= 1000;
    final hPadding = isDesktop ? 24.0 : isIpad ? 20.0 : 14.0;

    final list = LayoutBuilder(
      builder: (context, constraints) {
        // عدد الاعمدة حسب المساحة المتاحة
        final listWidth = constraints.maxWidth - hPadding * 2;
        final columns = isDesktop ? (listWidth / 340).floor().clamp(1, 3) : (listWidth >= 640 ? 2 : 1);

        return RefreshIndicator(
          onRefresh: () => context.read<CartCubit>().fetchCart(silent: true),
          color: AppColors.primary,
          backgroundColor: AppColors.backgroundSecondary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: _slivers(context, columns, hPadding),
          ),
        );
      },
    );

    if (!isDesktop || state is! CartLoaded) return list;

    final loaded = state as CartLoaded;
    // الشاشات الكبيرة: القائمة مع لوحة ملخص جانبية
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: list),
        SizedBox(
          width: 360,
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(end: hPadding, top: 8, bottom: 24),
            child: CartSummaryPanel(
              totalPrice: loaded.totalPrice,
              totalDiscount: loaded.totalDiscount,
              itemCount: context.read<CartCubit>().itemCount,
              onCheckout: () => _CartActions.checkout(screenContext),
            ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(begin: 0.05, end: 0),
          ),
        ),
      ],
    );
  }

  List<Widget> _slivers(BuildContext context, int columns, double hPadding) {
    final s = state;

    if (s is CartLoading || s is CartInitial) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 24),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: 6,
            itemBuilder: (_, __) => const _CartItemShimmer(),
          ),
        ),
      ];
    }

    if (s is CartError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: SizedBox(
              height: 30,
              width: 120,
              child: RefreshButton(onPressed: () async => context.read<CartCubit>().fetchCart()),
            ),
          ),
        ),
      ];
    }

    if (s is CartLoaded && s.cartItems.isNotEmpty) {
      final products = s.cartItems;
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPadding, 4, hPadding, 12),
          sliver: SliverToBoxAdapter(child: _CartHeader(count: products.length, screenContext: screenContext)),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPadding, 0, hPadding, 90),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: products.length,
            itemBuilder: (_, index) => _CartItemTile(
              key: ValueKey('cart_tile_${products[index].cartItemId}'),
              item: products[index],
              index: index,
              screenContext: screenContext,
            ),
          ),
        ),
      ];
    }

    // السلة فارغة مع امكانية السحب للتحديث
    return [
      const SliverFillRemaining(hasScrollBody: false, child: EmptyCartScreen()),
    ];
  }
}

// راس القائمة: العدد وحذف الكل وتلميح الاستخدام
class _CartHeader extends StatelessWidget {
  final int count;
  final BuildContext screenContext;

  const _CartHeader({required this.count, required this.screenContext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tr('cart_items_count', args: ['$count']),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _CartActions.clearAll(screenContext),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.redColor,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(CupertinoIcons.trash, size: 16),
              label: Text(tr('cart_clear_all'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.swipe_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                tr('cart_swipe_hint'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// بطاقة الصنف مع السحب للحذف والضغط المطول
class _CartItemTile extends StatelessWidget {
  final CartModel item;
  final int index;
  final BuildContext screenContext;

  const _CartItemTile({super.key, required this.item, required this.index, required this.screenContext});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    final tile = Dismissible(
      key: ValueKey('cart_dismiss_${item.cartItemId}'),
      // الاتجاه ينعكس تلقائيا حسب لغة التطبيق
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.35},
      confirmDismiss: (_) => _CartActions.confirmDelete(screenContext),
      onDismissed: (_) => cubit.deleteItemFromCart(cartItemId: item.cartItemId, product: item, context: screenContext),
      background: const _DeleteBackground(),
      child: Builder(
        builder: (cardContext) => GestureDetector(
          onLongPress: () async {
            final action = await CartQuickMenu.show(cardContext, item);
            if (action != null && screenContext.mounted) {
              _CartActions.handleMenu(screenContext, action, item);
            }
          },
          child: CartItemCard(
            item: item,
            onEdit: () => CartEditSheet.show(screenContext, item),
            onIncrement: () => cubit.updateItemQuantity(product: item, newQuantity: item.quantity + 1),
            onDecrement: () async {
              if (item.quantity > 1) {
                cubit.updateItemQuantity(product: item, newQuantity: item.quantity - 1);
              } else {
                await _CartActions.delete(screenContext, item);
              }
            },
          ),
        ),
      ),
    );

    // حركة ظهور متتابعة للبطاقات
    return tile
        .animate()
        .fadeIn(delay: Duration(milliseconds: (index * 50).clamp(0, 400)), duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

// خلفية السحب للحذف
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [AppColors.redColor.withOpacity(0.15), AppColors.redColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(tr('delete'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// تحميل وهمي بشكل البطاقة الجديدة
class _CartItemShimmer extends StatelessWidget {
  const _CartItemShimmer();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(6)),
    );

    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            bar(92, 116),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(140, 14),
                  const SizedBox(height: 10),
                  bar(110, 20),
                  const SizedBox(height: 34),
                  Row(children: [bar(60, 16), const Spacer(), bar(96, 34)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// عمليات السلة المشتركة
class _CartActions {
  // رسالة تاكيد حذف صنف
  static Future<bool> confirmDelete(BuildContext context) async {
    final ok = await AppToasts.showConfirmDialog(
      context: context,
      title: tr('confirm_delete_title'),
      message: tr('confirm_delete_cartItem_msg'),
    );
    return ok == true;
  }

  static Future<void> delete(BuildContext context, CartModel item) async {
    if (await confirmDelete(context) && context.mounted) {
      context.read<CartCubit>().deleteItemFromCart(cartItemId: item.cartItemId, product: item, context: context);
    }
  }

  // حذف الكل مع التاكيد
  static Future<void> clearAll(BuildContext context) async {
    final ok = await AppToasts.showConfirmDialog(
      context: context,
      title: tr('cart_clear_all'),
      message: tr('confirm_clear_cart_msg'),
    );
    if (ok == true && context.mounted) {
      context.read<CartCubit>().clearCart(context: context);
    }
  }

  // مشاركة السلة (لاحقا)
  static void shareCart(BuildContext context) {
    AppToasts.showWarningToast(context, tr('share_cart_soon'));
  }

  static void handleMenu(BuildContext context, CartQuickAction action, CartModel item) {
    final imageUrl = ApiEndpoints.productImageUrl(item.productImage ?? item.displayImage);
    switch (action) {
      case CartQuickAction.edit:
        CartEditSheet.show(context, item);
      case CartQuickAction.details:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: item.toProduct())));
      case CartQuickAction.similar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SimilarProducts(imagePath: imageUrl)));
      case CartQuickAction.tryOn:
        Navigator.push(context, MaterialPageRoute(builder: (_) => VirtualTryOnScreen(garmentUrl: imageUrl)));
      case CartQuickAction.share:
        ProductShareHelper.share(context, item.toProduct());
      case CartQuickAction.delete:
        delete(context, item);
    }
  }

  // الانتقال للدفع مع التحقق من رقم الهاتف
  static void checkout(BuildContext context) {
    final cubit = context.read<CartCubit>();
    if (cubit.allProducts.isEmpty) {
      AppToasts.showWarningToast(context, tr('cart_empty_warning'));
      return;
    }

    void goToAddress() => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectUsrAddress(displayTotal: cubit.totalPrice - cubit.totalDiscount),
      ),
    );

    if (!UserLocal().hasPhone()) {
      AppToasts.showWarningToast(context, tr('cart_add_phone_first'));
      PhoneNumber.show(context, goToAddress);
    } else {
      goToAddress();
    }
  }
}