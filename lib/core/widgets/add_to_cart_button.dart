import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';

class AddToCartButton extends StatefulWidget {
  const AddToCartButton({super.key});

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cartX;
  late Animation<double> _cartOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _shirtY;
  late Animation<double> _shirtOpacity;
  late Animation<double> _checkOpacity;
  late Animation<double> _shirtScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // سيتم تعريف _cartX لاحقاً داخل الـ Builder بناءً على عرض الزر

    _cartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _textOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    _shirtY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -40.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -40.0, end: 10.0).chain(CurveTween(curve: Curves.easeIn)), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)));

    _shirtOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.75)));

    _shirtScale = Tween<double>(begin: 0.6, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)),
    );

    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.66, 0.7)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1200), () => _controller.reset());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // معرفة اتجاه اللغة (هل هي عربية؟)
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return LayoutBuilder(builder: (context, constraints) {
      // عرض الزر يتغير حسب الهاتف أو الكمبيوتر
      final double buttonWidth = constraints.maxWidth;

      // حركة السلة تبدأ من خارج الزر وتنتهي في الطرف الآخر
      _cartX = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 40.0, end: buttonWidth / 2 - 14).chain(CurveTween(curve: Curves.easeOut)),
          weight: 35,
        ),
        TweenSequenceItem(tween: ConstantTween(buttonWidth / 2 - 14), weight: 30),
        TweenSequenceItem(
          tween: Tween(begin: buttonWidth / 2 - 14, end: buttonWidth).chain(CurveTween(curve: Curves.easeIn)),
          weight: 35,
        ),
      ]).animate(_controller);

      return GestureDetector(
        onTap: () => _controller.forward(from: 0.0),
        child: Container(
          width: double.infinity, // يأخذ كامل العرض المتاح (responsive)
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color:AppColors.borderColor),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // النص
                  Opacity(
                    opacity: _textOpacity.value,
                    child:  Text(
                      'إضافة إلى السلة',
                      style: TextStyle( fontSize: isDesktop ? 15 :12, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // أيقونة السلة (تستخدم PositionedDirectional لدعم RTL تلقائياً)
                  PositionedDirectional(
                    start: _cartX.value,
                    child: Opacity(
                      opacity: _cartOpacity.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildCartIcon(),
                          Positioned(
                            top: 0,
                            right: isRtl ? null : 0,
                            left: isRtl ? 0 : null,
                            child: Opacity(
                              opacity: _checkOpacity.value,
                              child: Icon(Icons.done_all, color:AppColors.primary, size: isDesktop ?  18 : 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // القميص
                  Positioned(
                    top: _shirtY.value,
                    child: Opacity(
                      opacity: _shirtOpacity.value,
                      child: Transform.scale(
                        scale: _shirtScale.value,
                        child: _buildShirtIcon(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildCartIcon() {
    // معرفة اتجاه اللغة الحالي
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    bool isDesktop = MediaQuery.of(context).size.width > 800;


    return Transform.flip(
      // إذا كانت اللغة عربية (RTL)، نقوم بعكس الأيقونة أفقياً
      flipX: isRtl,
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-shopping-cart color"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>',
        width: isDesktop ? 26 : 20,
        height: isDesktop ? 26 : 20,
        // ignore: deprecated_member_use
        color: AppColors.iconColor,
      ),
    );
  }

  Widget _buildShirtIcon() {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 640 512"><path d="M211.8 0c7.8 0 14.3 5.7 16.7 13.2C240.8 51.9 277.1 80 320 80s79.2-28.1 91.5-66.8C413.9 5.7 420.4 0 428.2 0h12.6c22.5 0 44.2 7.9 61.5 22.3L628.5 127.4c6.6 5.5 10.7 13.5 11.4 22.1s-2.1 17.1-7.8 23.6l-56 64c-11.4 13.1-31.2 14.6-44.6 3.5L480 197.7V448c0 35.3-28.7 64-64 64H224c-35.3 0-64-28.7-64-64V197.7l-51.5 42.9c-13.3 11.1-33.1 9.6-44.6-3.5l-56-64c-5.7-6.5-8.5-15-7.8-23.6s4.8-16.6 11.4-22.1L137.7 22.3C155 7.9 176.7 0 199.2 0h12.6z"></path></svg>',
    width: isDesktop ? 24 : 19,
    height: isDesktop ? 24 : 19,
    color: AppColors.iconColor,

  );
  }
}