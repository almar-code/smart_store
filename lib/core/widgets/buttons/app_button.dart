import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final String label;
  final bool iconAfter;
  final VoidCallback? onTap;
  final Widget? child; // 👈 إضافة الخاصية هنا

  const AppButton({
    super.key,
    this.color,
    this.borderRadius = 12,
    this.fontSize = 14,
    this.iconSize = 14,
    this.icon,
    this.label = 'checkout',
    this.borderColor = Colors.white12,
    this.textColor = Colors.white,
    this.onTap,
    this.iconAfter = false,
    this.child, // 👈 إضافتها في الـ Constructor
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      decoration: BoxDecoration(
        gradient: (color == null)
            ? const LinearGradient(
          colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        borderRadius: BorderRadius.circular(
          isDesktop ? borderRadius : borderRadius - 2,
        ),
      ),
      child: MaterialButton(
        onPressed: onTap, // 👈 تفعيل تعطيل الزر بمرونة عند إرسال null
        color: color ?? Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(
            isDesktop ? borderRadius : borderRadius - 2,
          ),
        ),
        elevation: 0,
        // 👈 إذا تم تمرير child (مثل دائر التحميل) يتم عرضه، وإلا يتم عرض النص والأيقونة الافتراضية
        child: child ??
            Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (!iconAfter)
                    ? (icon != null)
                    ? Icon(icon, color: textColor, size: iconSize)
                    : const SizedBox()
                    : const SizedBox(),
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                (iconAfter)
                    ? (icon != null)
                    ? Icon(icon, color: textColor, size: iconSize)
                    : const SizedBox()
                    : const SizedBox(),
              ],
            ),
      ),
    );
  }
}