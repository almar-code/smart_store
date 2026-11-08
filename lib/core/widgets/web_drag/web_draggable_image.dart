import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// 🌐 استيراد شرطي: نسخة الويب فقط تستخدم عناصر HTML، والجوال يأخذ نسخة فارغة
import 'web_draggable_image_stub.dart'
    if (dart.library.js_interop) 'web_draggable_image_web.dart' as impl;

/// زر صغير فوق بطاقة المنتج يعرض صورة مصغّرة قابلة للسحب (على الويب فقط)
/// تُسحب إلى أي مكان في المتصفح، مثل نافذة التجربة الافتراضية.
/// على الجوال لا يظهر شيء.
class WebDraggableImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const WebDraggableImage({
    super.key,
    required this.imageUrl,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || imageUrl == null || imageUrl!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        shape: BoxShape.circle,
      ),
      child: impl.buildDraggableImage(
        imageUrl: imageUrl!,
        size: size,
        tooltip: 'drag_to_try_on'.tr(),
      ),
    );
  }
}
