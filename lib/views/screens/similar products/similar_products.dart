import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/titleBar.dart';
import '../../widgets/product/all_products.dart';
import '../../../core/widgets/underlined_title.dart';
import 'package:flutter/foundation.dart'; // للتحقق من kIsWeb
class SimilarProducts extends StatelessWidget {
  const SimilarProducts({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // لمنع ظهور زر الرجوع التلقائي كما طلبت سابقاً
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Icon(
          Icons.center_focus_strong_outlined,
          size: isDesktop ? 25 : 21,
          color: AppColors.iconColor,
        ),
        titleSpacing: 0,
        title: AppTitle(
          firstPart: tr('similar'),
          secondPart: tr('products'),
          fontSize: isDesktop ? 18 : 15,
          spacing: ' ',
        ),
        actions: const [
          ArrowBack(),
          SizedBox(width: 6,)
        ],
      ),
      body:SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientTop, AppColors.gradientBottom],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SimilarProductsHeader(uploadedImagePath: 'assets/images/1.jpg'),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // 1. الخط العلوي (المقبض الجمالي) الذي يظهر في منتصف رأس القائمة
                        Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: AllProducts(), // استدعاء المنتجات الخاصة بك
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ) ,
    );
  }
}


class SimilarProductsHeader extends StatelessWidget {
  final String? uploadedImagePath;

  const SimilarProductsHeader({super.key, required this.uploadedImagePath});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    // تحديد عرض أقصى للحاوية لضمان التناسق على الشاشات الكبيرة
    return Center(
      child: SizedBox(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // صورة الولد الأساسية (الخلفية)
                Image.asset(
                  'assets/images/delivery_boy.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 94,
                  left: 43, // نسبة مرنة من اليسار
                  child: Container(
                    width: 95,
                    height: 102,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImageWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // دالة التعامل مع الصورة (Web vs Mobile) - كما هي في الكود السابق
  Widget _buildImageWidget() {
    if (uploadedImagePath == null || uploadedImagePath!.isEmpty) {
      return const Center(child: Icon(Icons.image, color: Colors.grey));
    }

    if (kIsWeb) {
      return Image.network(
        uploadedImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      return Image.file(
        File(uploadedImagePath!),
        fit: BoxFit.cover,
      );
    }
  }
}

