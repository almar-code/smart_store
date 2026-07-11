import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeartOverlayNotifier {
  // دالة الاستدعاء الستاتيك لكي تتمكن من تشغيلها من أي مكان بطلب سطر واحد
  static void show(BuildContext context, {bool isLike = true}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedHeartWidget(
        isLike: isLike,
        onAnimationComplete: () {
          // 🚀 إزالة الـ entry من الشاشة فور انتهاء التوقيت تلقائياً لعدم تسريب الذاكرة
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

// 🌟 وجت داخلية مخصصة لإدارة حالة الانميشن (Scale) تلقائياً بمجرد البناء
class _AnimatedHeartWidget extends StatefulWidget {
  final bool isLike;
  final VoidCallback onAnimationComplete;

  const _AnimatedHeartWidget({
    required this.isLike,
    required this.onAnimationComplete,
  });

  @override
  State<_AnimatedHeartWidget> createState() => _AnimatedHeartWidgetState();
}

class _AnimatedHeartWidgetState extends State<_AnimatedHeartWidget> {
  double _scale = 0.0; // تبدأ من الصفر لكي تظهر وتكبر فجأة

  @override
  void initState() {
    super.initState();
    // بدء الانميشن في تيك الـ Frame القادم مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _scale = 4.0; // الحجم المستهدف
        });
      }
    });

    // إطلاق مؤقت لإغلاق وتدمير الـ Overlay بعد انتهاء وقت الانميشن والظهور (مثلاً 1.2 ثانية)
    Future.delayed(const Duration(milliseconds: 900), () {
      widget.onAnimationComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 250.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 600),
          // Curves.bounceOut يعطي تأثير ارتدادي أجمل بكثير عند التكبير من bounceIn
          curve: Curves.bounceOut,
          child: Icon(
            CupertinoIcons.heart_fill,
            color: widget.isLike ? Colors.red : Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}