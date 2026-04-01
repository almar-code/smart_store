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
