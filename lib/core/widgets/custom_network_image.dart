import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/three_dots_loader.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover, // قيمة افتراضية ويمكن تغييرها عند الاستدعاء
  });

  @override
  Widget build(BuildContext context) {
    const String placeholderPath = 'assets/images/image_placeholder.png';

    // 1. التأكد أولاً ما إذا كان الرابط موجود نهائياً أم لا
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Image.asset(
        placeholderPath,
        width: width,
        height: height,
        fit: fit,
      );
    }

    // 2. إذا كان الرابط موجود، نقوم بتحميل الصورة من السيرفر
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,

      // ⏳ مؤشر التحميل المشترك
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.backgroundSecondary,
          width: width,
          height: height,
          child: const Center(child: ThreeDotsLoader()),
        );
      },

      // ⚠️ معالجة أخطاء الشبكة
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          placeholderPath,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}