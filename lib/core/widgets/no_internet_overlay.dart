import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/ads/ads_cubit.dart';
import '../../../logic/cart/cart_cubit.dart';
import '../../../logic/categories/category_cubit.dart';
import '../../../logic/connection/connection_cubit.dart';
import '../../../logic/favorites/favorites_cubit.dart';
import '../../../logic/notifications/notification_cubit.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../../logic/subcategories/subcategory_cubit.dart';
import '../../../logic/videos/video_cubit.dart';
import '../constants/app_colors.dart';

/// طبقة زجاجية تغطي التطبيق عند انقطاع الإنترنت
class NoInternetOverlay extends StatelessWidget {
  const NoInternetOverlay({super.key});

  // إعادة جلب بيانات التطبيق بعد عودة الاتصال
  static void reloadAll(BuildContext context) {
    context.read<CategoryCubit>().getCategories();
    context.read<SubcategoryCubit>().getSubcategories();
    context.read<ProductCubit>().fetchProducts(isRefresh: true);
    context.read<AdsCubit>().fetchAds();
    context.read<VideoCubit>().getAllVideos();
    context.read<CartCubit>().fetchCart();
    context.read<FavoritesCubit>().loadInitialFavoriteCount();
    context.read<NotificationCubit>().fetch(silent: true);
  }

  Future<void> _retry(BuildContext context) async {
    final bool connected = await context.read<ConnectionCubit>().check();

    if (connected && context.mounted) {
      reloadAll(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionCubit, ConnectionStatus>(
      builder: (context, status) {
        // تظهر فقط عند الانقطاع أو أثناء إعادة الفحص
        if (status != ConnectionStatus.offline &&
            status != ConnectionStatus.retrying) {
          return const SizedBox.shrink();
        }

        final bool isChecking = status == ConnectionStatus.retrying;

        // عند وجود منتجات محفوظة نعرض شريطا صغيرا بدل تغطية التطبيق
        return BlocBuilder<ProductCubit, ProductState>(
          builder: (context, productState) {
            final bool hasCachedData = productState is ProductLoaded && productState.products.isNotEmpty;
            // اثناء تحميل المحفوظ لا نغطي التطبيق
            final bool stillLoading = productState is ProductInitial || productState is ProductLoading;

            if (hasCachedData || stillLoading) {
              return _OfflineBanner(isChecking: isChecking, onRetry: () => _retry(context));
            }
            // لا توجد اي بيانات محفوظة
            return _fullOverlay(context, isChecking);
          },
        );
      },
    );
  }

  // الطبقة الكاملة عند عدم وجود اي بيانات محفوظة
  Widget _fullOverlay(BuildContext context, bool isChecking) {
        return Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: const Icon(
                                    Icons.wifi_off_rounded,
                                    color: Colors.tealAccent,
                                    size: 44,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  tr("no_internet_title"),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tr("no_internet_message"),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, Colors.tealAccent],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: isChecking ? null : () => _retry(context),
                                    icon: isChecking
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.refresh_rounded, color: Colors.white),
                                    label: Text(
                                      isChecking ? tr("checking_connection") : tr("retry"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }
}

// شريط صغير اعلى الشاشة: غير متصل مع زر اعادة المحاولة
class _OfflineBanner extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onRetry;

  const _OfflineBanner({required this.isChecking, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsetsDirectional.only(start: 14, end: 6, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.tealAccent, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tr('offline_cached_data'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: isChecking ? null : onRetry,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 32),
                      ),
                      child: isChecking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent),
                            )
                          : Text(tr('retry'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
