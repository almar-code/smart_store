import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/cart_icon.dart';
import '../../../core/widgets/icons/favorite_icon.dart';
import '../../../core/widgets/scroll_wrapper.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/AdModel.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repos/AdRepo.dart';
import '../../../data/repos/product_repo.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/product/all_products.dart';
import '../product/product_details_screen.dart';

class GeneralAdProductsScreen extends StatefulWidget {
  final int adsId;
  final String adTitle;
  final int? focusProductId; // المنتج الذي ضغط العميل على عرضه

  const GeneralAdProductsScreen({
    super.key,
    required this.adsId,
    required this.adTitle,
    this.focusProductId,
  });

  @override
  State<GeneralAdProductsScreen> createState() => _GeneralAdProductsScreenState();
}

class _GeneralAdProductsScreenState extends State<GeneralAdProductsScreen> {
  // يجلب مرة واحدة فقط بدل كل إعادة بناء
  late final Future<Map<String, dynamic>> _future =
  di.sl<AdRepo>().fetchGeneralAdProducts(widget.adsId);

  // تاريخ الانتهاء من السيرفر، وإن لم يصل نأخذه من إعلانات المنتجات المحملة
  String _expiresAt(AdModel? ad, ProductState state) {
    if ((ad?.expiresAt ?? '').isNotEmpty) return ad!.expiresAt;
    if (state is! ProductLoaded) return '';
    for (final p in state.products) {
      for (final a in p.generalAdvertisements) {
        if (a.adsId == widget.adsId && a.expiresAt.isNotEmpty) return a.expiresAt;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return BlocProvider<ProductCubit>(
      create: (context) => ProductCubit(repository: di.sl<ProductRepo>())
        ..fetchProducts(isRefresh: true, adsId: widget.adsId),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            titleSpacing: 10,
            elevation: 0,
            title: Text(
              widget.adTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            actions: [
              const FavoriteIcon(),
              CartIcon(),
              const ArrowBack(),
            ],
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ThreeDotsLoader());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return _Message(icon: Icons.wifi_off_rounded, text: tr('offer_load_error'));
              }

              final List<ProductModel> products = snapshot.data!['products'] ?? [];
              final AdModel? ad = snapshot.data!['ad'];

              return ScrollWrapper(
                bottom: 5,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 8, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: BlocBuilder<ProductCubit, ProductState>(
                                builder: (context, state) => _OfferBanner(
                                  title: ad?.adsName ?? widget.adTitle,
                                  expiresAt: DateTime.tryParse(_expiresAt(ad, state)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (products.isEmpty)
                            _Message(icon: Icons.shopping_bag_outlined, text: tr('offer_no_products'))
                          else ...[
                            _SectionTitle(count: products.length),
                            const SizedBox(height: 12),
                            AllProducts(
                              showAddToCart: true,
                              pinnedProductId: widget.focusProductId,
                              currentAdsId: widget.adsId,
                              onProductTap: (product) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 90),
                          ],
                        ],
                      ),
                    ),
                  ),
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

// بانر العرض: صورة فيها ثلاث خانات (عروض، اسم العرض، المدة)
class _OfferBanner extends StatelessWidget {
  final String title;
  final DateTime? expiresAt;

  const _OfferBanner({required this.title, required this.expiresAt});

  // مقاس الصورة الأصلي لحساب أماكن الخانات
  static const double _imgW = 800;
  static const double _imgH = 446;

  // المدة المتبقية من اليوم حتى تاريخ الانتهاء
  String _remainingText() {
    if (expiresAt == null) return '';
    final today = DateUtils.dateOnly(DateTime.now());
    final days = DateUtils.dateOnly(expiresAt!).difference(today).inDays;
    if (days < 0) return tr('offer_expired');
    if (days == 0) return tr('offer_ends_today');
    return plural('offer_ends_in', days);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: _imgW / _imgH,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;

            // تحويل إحداثيات الصورة لمقاس الشاشة
            Widget slot({
              required double left,
              required double top,
              required double right,
              required double bottom,
              required Widget child,
            }) {
              return Positioned(
                left: w * left / _imgW,
                top: h * top / _imgH,
                width: w * (right - left) / _imgW,
                height: h * (bottom - top) / _imgH,
                child: Center(child: child),
              );
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/images/ads.jpg', fit: BoxFit.cover),
                ),

                // الخانة الأولى: عروض
                slot(
                  left: 445, top: 114, right: 630, bottom: 188,
                  child: _SlotText(
                    text: tr('offers_title'),
                    color: Colors.white,
                    maxSize: w * 0.06,
                  ),
                ),

                // الخانة الثانية: اسم العرض
                slot(
                  left: 472, top: 202, right: 718, bottom: 276,
                  child: Transform.rotate(
                    angle: -0.089,
                    child: _SlotText(
                      text: title,
                      color: const Color(0xFF2F5741),
                      maxSize: w * 0.040,
                      maxLines: 2,
                    ),
                  ),
                ),

                // الخانة الثالثة: مدة العرض

                // الخانة الثالثة: مدة العرض بنفس ميلان الشكل
                slot(
                  left: 493, top: 302, right: 677, bottom: 345,
                  child: Transform.rotate(
                    angle: -0.089, // حوالي 5 درجات عكس عقارب الساعة
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 12 / _imgW),
                      child: _SlotText(
                        text: _remainingText(),
                        color: Colors.white,
                        maxSize: w * 0.034,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// نص يصغر تلقائيا ليناسب الخانة
class _SlotText extends StatelessWidget {
  final String text;
  final Color color;
  final double maxSize;
  final int maxLines;
  final FontWeight weight;

  const _SlotText({
    required this.text,
    required this.color,
    required this.maxSize,
    this.maxLines = 1,
    this.weight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxLines > 1 ? maxSize * 9 : double.infinity),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: maxSize,
            fontWeight: weight,
            height: 1.2,
            shadows: color == Colors.white
                ? [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 3)]
                : null,
          ),
        ),
      ),
    );
  }
}

// عنوان قسم المنتجات
class _SectionTitle extends StatelessWidget {
  final int count;
  const _SectionTitle({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tr('offer_products_title'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// رسالة فارغة أو خطأ
class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}