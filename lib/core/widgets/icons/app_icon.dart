import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
class AppIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final VoidCallback? onPressed;
  AppIcon({super.key,required this.icon,this.color,this.size=20,this.onPressed});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double finalSize = isDesktop ? size : size - 5;
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 6 : 4),
      child: Container(
        width: isDesktop ? 40 : 30,
        height: isDesktop ? 40 : 30,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon:  Icon(
            icon,
            color:color ?? AppColors.iconColor,
            size: finalSize,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class ArrowForwardIcon extends StatelessWidget {
  final double size;
  final Color? color;

  // جعلنا الحجم مطلوباً، واللون اختيارياً (يأخذ لون التطبيق الافتراضي)
  const ArrowForwardIcon({
    super.key,
    this.size = 11,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios,
      size: size,
      color: color ?? AppColors.primary,
    );
  }
}
