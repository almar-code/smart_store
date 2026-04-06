import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  context.locale.languageCode == 'ar'
                      ? CupertinoIcons.chevron_forward
                      : CupertinoIcons.chevron_left,
                  color: Colors.black,
                  size: 18,
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Icon(icon, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.transparent),
      ],
    );
  }
}
