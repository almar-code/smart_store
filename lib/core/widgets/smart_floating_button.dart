import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smart_store/core/widgets/ripple_0verlay.dart';

class SmartFloatingButton extends StatefulWidget {
  const SmartFloatingButton({super.key});

  @override
  State<SmartFloatingButton> createState() => _SmartFloatingButtonState();
}

class _SmartFloatingButtonState extends State<SmartFloatingButton> {
  bool _isExpanded = true;

  // نحدد الـ Entry كـ Static أو كمتغير ثابت على مستوى الـ State لتجنب ضياع مرجعيته
  OverlayEntry? _rippleEntry;

  void _toggleAiRipple() {
    // التحقق الفعلي: إذا كان الـ Entry موجوداً ونشطاً في الشاشة
    if (_rippleEntry != null) {
      _rippleEntry!.remove();
      _rippleEntry = null;
      // نطلب إعادة بناء الواجهة لتحديث أي عناصر بصرية مرتبطة بالزر إن وجدت
      setState(() {});
    } else {
      // إنشاء التموج الجديد
      _rippleEntry = OverlayEntry(
        builder: (context) => GestureDetector(
          // نغلق التموج أيضاً إذا ضغط المستخدم على أي مكان في الشاشة المعتمة
          onTap: _toggleAiRipple,
          child: const ContinuousRippleOverlay(),
        ),
      );

      // إدخال التموج فوق الشاشة الحالية مباشرة
      Overlay.of(context).insert(_rippleEntry!);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // إغلاق تمدد الزر بعد 3 ثوانٍ تلقائياً
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // إجراء أمان هام جداً لمنع تسريب الذاكرة (Memory Leak)
    if (_rippleEntry != null) {
      _rippleEntry!.remove();
      _rippleEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // استدعاء الدالة مباشرة دون تمرير context خارجي قد يسبب مشاكل تتبع
      onTap: _toggleAiRipple,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        height: 47,
        width: _isExpanded ? 180 : 47,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: _isExpanded ? MainAxisAlignment.spaceAround :MainAxisAlignment.center,
          children: [
            if (_isExpanded)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Call me Almar",
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}