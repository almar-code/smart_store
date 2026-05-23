import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ThreeDotsLoader extends StatefulWidget {
  const ThreeDotsLoader({super.key});

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double start) {
    return FadeTransition(
      opacity: Tween(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, start + 0.3, curve: Curves.easeInOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: CircleAvatar(
          radius: 5,
          backgroundColor: AppColors.iconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0.0),
        _dot(0.3),
        _dot(0.6),
      ],
    );
  }
}
