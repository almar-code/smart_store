import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[100],
            backgroundImage: AssetImage(imagePath),
          ),
          title: Text(title, style:  TextStyle(fontSize: 10,
            fontWeight: FontWeight.bold,
            color:  AppColors.iconColor,)),
          trailing:  Icon(Icons.arrow_forward_ios, size: 14),
          onTap: onTap,
        ),
         Divider(indent: 10, endIndent: 10, thickness: 0.5),
      ],
    );
  }
}