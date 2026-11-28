import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/size_finder/size_finder_widgets.dart';
import 'size_manual_screen.dart';
import 'size_photo_screen.dart';

// اختيار طريقة معرفة المقاس: يدوي أو بالصور
class SizeFinderScreen extends StatelessWidget {
  /// مقاسات المنتج الحالي (اختياري) لاختيار المقاس الناتج تلقائياً
  final List<SizeModel>? productSizes;

  const SizeFinderScreen({super.key, this.productSizes});

  // فتح الطريقة المختارة وإرجاع المقاس المختار للصفحة السابقة
  Future<void> _open(BuildContext context, Widget screen) async {
    final String? picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (picked == null || !context.mounted) return;
    // الرجوع من صفحة النتيجة يغلق صفحة الاختيار أيضاً
    Navigator.of(context).pop(picked == kSizeFlowClose ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isWide = width > 600; // الآيباد والشاشات الكبيرة

    final manualCard = SizeMethodCard(
      icon: Icons.edit_note_rounded,
      title: tr('size_method_manual_title'),
      description: tr('size_method_manual_desc'),
      points: [tr('size_method_manual_p1'), tr('size_method_manual_p2')],
      image: 'assets/images/size_method_manual.png',
      onTap: () => _open(context, SizeManualScreen(productSizes: productSizes)),
    );
    final photoCard = SizeMethodCard(
      icon: Icons.photo_camera_outlined,
      title: tr('size_method_photo_title'),
      description: tr('size_method_photo_desc'),
      points: [tr('size_method_photo_p1'), tr('size_method_photo_p2')],
      image: 'assets/images/size_method_photo.png',
      badge: tr('size_method_photo_badge'),
      highlighted: true,
      onTap: () => _open(context, SizePhotoScreen(productSizes: productSizes)),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Icon(Icons.straighten_rounded, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('size_finder_first'),
            secondPart: tr('size_finder_second'),
            fontSize: isDesktop ? 18 : 15,
            spacing: ' ',
          ),
          actions: const [ArrowBack()],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? width * 0.15 : 20,
            vertical: 10,
          ),
          child: Column(
            spacing: 18,
            children: [
              const SizeMethodHeader(),
              // بطاقتين جنب بعض في الشاشات العريضة وتحت بعض في الجوال
              if (isWide)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [Expanded(child: photoCard), Expanded(child: manualCard)],
                  ),
                )
              else ...[
                photoCard,
                manualCard,
              ],
              const SizePrivacyBar(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}