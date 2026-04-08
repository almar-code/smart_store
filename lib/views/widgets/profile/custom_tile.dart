import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/icons/app_icon.dart';

class CustomTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomTile({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
    InkWell(
    onTap: onTap,
          child: ListTile(
            leading: Icon(icon, color: AppColors.primary, size: 16),
            title:  Text(
              title,
              style:  TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:AppColors.textColor),
            ),
            trailing:   ArrowForwardIcon(),
          ),
        ),
         Divider(height: 1, color: Colors.transparent),
      ],
    );
  }
}
