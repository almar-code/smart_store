import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class DropCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? expandedContent;
  final bool isExpandable;
  final bool isSmall; // للتحكم في الحجم بداخل القائمة المنسدلة

  const DropCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.expandedContent,
    this.isExpandable = true,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: isSmall ? 8 : 12),
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
          border: Border.all(
            color: isSelected ?  color.withOpacity(0.4) : Colors.transparent, // دائرة الاختيار البرتقالية
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: isSmall ? 38 : 48,
                  height: isSmall ? 38 : 48,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: isSmall ? 20 : 24),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: isSmall ? 10 : 12)),
                  ],
                ),
                const Spacer(),
                // دائرة الاختيار (Radio)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.3), width: 2),
                  ),
                  child: isSelected
                      ? Center(child: Container(width: 12, height: 12, decoration:  BoxDecoration(color: color.withOpacity(0.6), shape: BoxShape.circle)))
                      : null,
                ),
              ],
            ),
            if (isSelected && isExpandable && expandedContent != null) expandedContent!,
          ],
        ),
      ),
    );
  }
}
