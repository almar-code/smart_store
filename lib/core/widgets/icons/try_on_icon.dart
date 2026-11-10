import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../../views/screens/try_on/virtual_try_on_screen.dart';

/// نفس تصميم ProductVisualSearchIcon
class ProductTryOnIcon extends StatelessWidget {
  final String? imageUrl; // ApiEndpoints.productImageUrl(item.pImage)

  const ProductTryOnIcon({super.key, required this.imageUrl});

  void _openTryOn(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VirtualTryOnScreen(garmentUrl: imageUrl!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openTryOn(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.checkroom_outlined,
          color: AppColors.iconColor,
          size: 15,
        ),
      ),
    );
  }
}
