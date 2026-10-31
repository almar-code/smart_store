import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../views/screens/similar products/similar_products.dart';

/// 1. أداة الكاميرا المضيئة (تُستخدم عادة في الهيدر أو شريط البحث)
class CameraSearchIcon extends StatelessWidget {
  const CameraSearchIcon({super.key});

  Future<void> _pickImageAndNavigate(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      // فتح المعرض لاختيار صورة (أو يمكن استخدام ImageSource.camera)
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // ضغط ممتاز للحفاظ على السرعة والأداء
      );

      if (image != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SimilarProducts(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return IconButton(
      tooltip: 'البحث عن طريق الصورة',
      onPressed: () => _pickImageAndNavigate(context),
      icon: Icon(
        CupertinoIcons.photo_camera, // الشكل الفخم الاحترافي
        color: AppColors.iconColor,
        size: isDesktop ? 20 : 15,
      ),
    );
  }
}

/// 2. أداة التركيز البصري (تُستخدم فوق بطاقة كل منتج)
class ProductVisualSearchIcon extends StatelessWidget {
  final String? imageUrl; // رابط صورة المنتج المحددة

  const ProductVisualSearchIcon({
    super.key,
    required this.imageUrl,
  });

  void _navigateToSimilar(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimilarProducts(imagePath: imageUrl!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSimilar(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.center_focus_strong_outlined,
          color: AppColors.iconColor,
          size: 15,
        ),
      ),
    );
  }
}