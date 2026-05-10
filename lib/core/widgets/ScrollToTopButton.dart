import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (widget.scrollController.offset > 300) {
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    } else {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.buttonColor.withOpacity(0.6),
        onPressed: () {
          widget.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(
          Icons.keyboard_arrow_up,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}