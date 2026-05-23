import 'package:flutter/material.dart';
import 'package:smart_store/core/widgets/icons/smart_robot_icon.dart';

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
                AiRobotAvatar(iconSize: 35,padding: 15,),
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