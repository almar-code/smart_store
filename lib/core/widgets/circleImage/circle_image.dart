import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';

class CircleImage extends StatelessWidget {
  final String imagePath;
  final double radius;
  final IconData icon;

  const CircleImage({
    super.key,
    required this.imagePath,
    this.radius = 25,
    this.icon = Icons.store, // أيقونة افتراضية
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.backgroundSecondary,
      child: ClipOval(
        child: imagePath.startsWith('http')
            ? Image.network(
          imagePath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildFallbackIcon(); // أثناء التحميل
          },
        )
            : Image.asset(
          imagePath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      icon,
      size: radius,
      color: AppColors.iconColor,
    );
  }
}