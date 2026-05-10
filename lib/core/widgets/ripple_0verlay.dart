import 'package:flutter/material.dart';

class ContinuousRippleOverlay extends StatefulWidget {
  const ContinuousRippleOverlay({super.key});

  @override
  State<ContinuousRippleOverlay> createState() => _ContinuousRippleOverlayState();
}

class _ContinuousRippleOverlayState extends State<ContinuousRippleOverlay> with TickerProviderStateMixin {
  // نحتاج أكثر من Controller لعمل تداخل في الدوائر
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // التكرار اللانهائي
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.1), // تعتيم خفيف جداً للشاشة
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // الدائرة الأولى
                _buildRipple(_controller.value, 250),
                // الدائرة الثانية (متأخرة قليلاً)
                _buildRipple((_controller.value + 0.5) % 1.0, 200),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.fastOutSlowIn,
                  height: 70,
                  width:  70,
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
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 35),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRipple(double value, double maxSize) {
    return Container(
      width: value * maxSize,
      height: value * maxSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.teal.withOpacity(1 - value),
          width: 2,
        ),
        color: Colors.teal.withOpacity((1 - value) * 0.15),
      ),
    );
  }
}