import 'package:flutter/material.dart';
import 'package:smart_store/core/widgets/ripple_0verlay.dart';

class AiRippleManager {
  // نسخة ثابتة واحدة في الذاكرة لتتبع حالة التموج من أي مكان
  static OverlayEntry? _rippleEntry;

  static void toggleRipple(BuildContext context, {VoidCallback? onStateChanged}) {
    if (_rippleEntry != null) {
      // إذا كان التموج يعمل، نقوم بإغلاقه فوراً
      _rippleEntry!.remove();
      _rippleEntry = null;

      // لتحديث واجهة الزر (setState) إذا مررتها له
      if (onStateChanged != null) onStateChanged();
    } else {
      // إنشاء التموج الجديد
      _rippleEntry = OverlayEntry(
        builder: (overlayContext) => GestureDetector(
          // عند الضغط على الشاشة المعتمة، يستدعي الدالة نفسها للإغلاق
          onTap: () => toggleRipple(context, onStateChanged: onStateChanged),
          child: const ContinuousRippleOverlay(),
        ),
      );

      // إدخال التموج فوق واجهة التطبيق
      Overlay.of(context).insert(_rippleEntry!);

      if (onStateChanged != null) onStateChanged();
    }
  }

  // دالة إضافية للإغلاق المباشر (تفيدك عند الخروج من الصفحات كإجراء أمان)
  static void closeRipple() {
    if (_rippleEntry != null) {
      _rippleEntry!.remove();
      _rippleEntry = null;
    }
  }
}