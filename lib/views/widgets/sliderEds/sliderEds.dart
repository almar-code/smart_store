import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_endpoints.dart';
import '../../../data/models/AdModel.dart';
import '../../screens/general adProducts/general_adProducts.dart';
import '../../screens/product/product_details_screen.dart';
import '../../screens/product/products_screen.dart';
import '../flash/flash_screen.dart'; // تأكد من إضافة المكتبة

// class SliderEds extends StatefulWidget {
//   final List<String> images;
//   final bool scrollPhysics;
//    SliderEds({super.key,required this.images,this.scrollPhysics = false});
//
//   @override
//   State<SliderEds> createState() => _SliderEdsState();
// }
//
// class _SliderEdsState extends State<SliderEds> {
//   bool _isLoading = true; // حالة التحميل
//   @override
//   void initState() {
//     super.initState();
//     // مؤقت لمدة 5 ثوانٍ للوميض
//     Future.delayed(const Duration(seconds: 4), () {
//       if (mounted) setState(() => _isLoading = false);
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     bool isDesktop = MediaQuery.of(context).size.width > 800;
//     // إذا كان في حالة تحميل، نعرض مربعاً يلمع بنفس أبعاد السلايدر
//     if (_isLoading) {
//       return Flasheds();
//     }
//
//     // الكود الأصلي الخاص بك يظهر بعد 5 ثوانٍ
//     return SizedBox(
//       child: CarouselSlider(
//         options: CarouselOptions(
//           height: isDesktop ? 185 : 160,
//           autoPlay: true,
//           autoPlayInterval: const Duration(seconds: 3),
//           enlargeCenterPage: true,
//           enlargeFactor: .15,
//
//           enlargeStrategy: CenterPageEnlargeStrategy.scale,
//           viewportFraction: 0.9,
//           // 1. يمنع المستخدم من التمرير يدوياً
//           scrollPhysics: widget.scrollPhysics ? null : NeverScrollableScrollPhysics(),
//           // 2. يمنع توقف التمرير التلقائي عند لمس الشاشة
//           pauseAutoPlayOnTouch: widget.scrollPhysics,
//           // 4. (اختياري) يمنع التوقف إذا كان المستخدم يمرر الصفحة الرئيسية (Scroll)
//           pauseAutoPlayInFiniteScroll: widget.scrollPhysics,
//         ),
//         items:  widget.images
//             .map(
//               (item) => ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.asset(
//               item,
//               fit: BoxFit.fill,
//               width: double.infinity,
//             ),
//           ),
//         )
//             .toList(),
//       ),
//     );
//   }
// }

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
              // 3️⃣ إذا كان إعلان خاص أو صورة فقط -> لا تفعل شيئاً (صورة فقط)
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ApiEndpoints.adImageUrl(ad.adsImage),
                fit: BoxFit.fill,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/image_placeholder.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}