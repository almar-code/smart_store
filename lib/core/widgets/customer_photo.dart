import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_colors.dart';
import '../utils/avatar_provider.dart';

// صورة العميل في كل التطبيق مع إطار اختياري
// بدون image تؤخذ صورة المستخدم الحالي وتتحدث تلقائيا
class CustomerPhoto extends StatelessWidget {
  final double radius;
  final double? iconSize;
  final String? image;
  // أول حرف من الاسم بدل الأيقونة عند عدم وجود صورة
  final String? name;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  // الفراغ بين الإطار والصورة
  final double gap;
  // ويدجت فوق الصورة مثل التحميل
  final Widget? overlay;

  const CustomerPhoto({
    super.key,
    this.radius = 20,
    this.iconSize,
    this.image,
    this.name,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.gap = 1.5,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) return _buildAvatar(image!);

    // متابعة صورة المستخدم في Hive
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('user_info_box').listenable(keys: ['image']),
      builder: (_, box, __) => _buildAvatar(box.get('image') ?? ''),
    );
  }

  Widget _buildAvatar(String photo) {
    final provider = avatarProvider(photo);
    final hasName = name != null && name!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(showBorder ? borderWidth : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: showBorder ? (borderColor ?? AppColors.primary) : Colors.transparent,
      ),
      child: Container(
        padding: EdgeInsets.all(showBorder ? gap : 0),
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary.withOpacity(0.12),
          backgroundImage: provider,
          child: overlay ??
              (provider != null
                  ? null
                  : hasName
                  ? Text(
                name!.trim().characters.first,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.8,
                ),
              )
                  : Icon(CupertinoIcons.person, size: iconSize ?? radius, color: AppColors.iconColor)),
        ),
      ),
    );
  }
}