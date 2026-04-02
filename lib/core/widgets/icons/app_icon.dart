import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
class AppIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  AppIcon({super.key,required this.icon,this.color=AppColors.iconColor,this.size=20});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon:  Icon(
            icon,
            color:color,
            size: size,
          ),
          onPressed: (){},
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
    this.color =AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios,
      size: size,
      color: color,
    );
  }
}
