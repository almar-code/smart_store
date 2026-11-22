import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/AdModel.dart';
import '../../screens/general adProducts/general_adProducts.dart';
import '../../screens/product/products_screen.dart';
import '../flash/flash_screen.dart';

class SliderEds extends StatelessWidget {
  final List<AdModel> ads;
  final bool scrollPhysics;

  const SliderEds({super.key, required this.ads, this.scrollPhysics = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SizedBox(
      child: CarouselSlider(
        options: CarouselOptions(
          height: isDesktop ? 185 : 160,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          enlargeCenterPage: true,
          enlargeFactor: .15,
          viewportFraction: 0.9,
          scrollPhysics: scrollPhysics ? null : const NeverScrollableScrollPhysics(),
          pauseAutoPlayOnTouch: scrollPhysics,
        ),
        items: ads.map((ad) {
          return GestureDetector(
            onTap: () {
              // 1️⃣ إذا كان إعلان منتج (يحتوي على product_id)
              if (ad.type == 'product' && ad.productId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreens(productID: ad.productId!),

                  ),
                );
              }
              // 2️⃣ إذا كان إعلان عام (general)
              else if (ad.type == 'general') {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeneralAdProductsScreen(
                      adsId: ad.adsId,
                      adTitle: ad.adsName,
                    ),
                  ),
                );
              }
              // إعلان برابط: فتح الرابط خارج التطبيق
              else if (ad.type == 'link' && (ad.adsLink ?? '').isNotEmpty) {
                _openLink(context, ad.adsLink!);
              }
              // إعلان خاص: صورة فقط
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl:ApiEndpoints.adImageUrl(ad.adsImage),
                fit: BoxFit.fill,
                width: double.infinity,
                placeholder: (context, url) => FlashAds(
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/image_placeholder.png',
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // فتح رابط الإعلان وإظهار رسالة عند الفشل
  Future<void> _openLink(BuildContext context, String link) async {
    final uri = Uri.tryParse(link);
    final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!opened && context.mounted) {
      AppToasts.showErrorToast(context, tr('ad_link_open_error'));
    }
  }
}
