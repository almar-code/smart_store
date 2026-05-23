import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'buttons/ScrollToTopButton.dart';

class ScrollWrapper extends StatefulWidget {
  final Widget child;
  final double bottom ;
  const ScrollWrapper({
    super.key,
    required this.child,
    this.bottom = 85
  });

  @override
  State<ScrollWrapper> createState() => _ScrollWrapperState();
}

class _ScrollWrapperState extends State<ScrollWrapper> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: widget.child,
        ),

        PositionedDirectional(
          bottom: widget.bottom,
          start: 10,
          child: ScrollToTopButton(
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }
}