import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../views/screens/similar products/similar_products.dart';
import '../../utils/image_convert_helper.dart';
import '../app_messages.dart';

/// 1. أيقونة الكاميرا في شريط البحث
class CameraSearchIcon extends StatelessWidget {
  const CameraSearchIcon({super.key});

  // قائمة اختيار الكاميرا أو المعرض
  Future<void> _showSourceSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source != null && context.mounted) {
      await _pickAndSearch(context, source);
    }
  }

  Future<void> _pickAndSearch(BuildContext context, ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (image == null) return;

      // تحويل الصورة الى JPG قبل الارسال
      final bytes = await ImageConvertHelper.toJpg(image);
      if (!context.mounted) return;

      if (bytes == null) {
        AppToasts.showErrorToast(context, tr('image_convert_error'));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SimilarProducts(imagePath: image.path, imageBytes: bytes),
        ),
      );
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (context.mounted) AppToasts.showErrorToast(context, tr('image_convert_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return IconButton(
      tooltip: tr('visual_search_title'),
      onPressed: () => _showSourceSheet(context),
      icon: Icon(
        CupertinoIcons.photo_camera,
        color: AppColors.iconColor,
        size: isDesktop ? 20 : 15,
      ),
    );
  }
}

// تصميم القائمة المنسدلة
class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.ContainerColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderSecondary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.10),
              ),
              child: Icon(Icons.center_focus_strong_outlined, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              tr('visual_search_title'),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textColor),
            ),
            const SizedBox(height: 4),
            Text(
              tr('visual_search_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: CupertinoIcons.camera,
                    label: tr('take_photo'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceOption(
                    icon: CupertinoIcons.photo_on_rectangle,
                    label: tr('choose_from_gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2. أيقونة البحث البصري فوق بطاقة المنتج
class ProductVisualSearchIcon extends StatelessWidget {
  final String? imageUrl;

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
