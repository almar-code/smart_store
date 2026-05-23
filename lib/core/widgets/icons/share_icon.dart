import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';


class shareButton extends StatelessWidget {
  const shareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // الحصول على بيانات الموقع الحالي للزر
        final RenderBox? box = context.findRenderObject() as RenderBox?;

        Share.share(
          'تحقق من هذا المنتج الرائع على تطبيقنا!',
          subject: 'مشاركة عباية',
          // هذه الخاصية الوحيدة التي تخاطب "حجم وموقع" النافذة
          // هي تجبر النظام على محاولة حصر النافذة في هذا النطاق
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      },
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundSecondary,
        ),
        child: Center(
          child: Icon(
            Icons.share_outlined,
            color: AppColors.iconColor,
            size: 14,
          ),
        ),
      ),
    );
  }
}
