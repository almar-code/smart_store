import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/widgets/app_messages.dart';

import '../../../logic/cart/cart_cubit.dart';
import '../../../logic/colors/colors_cubit.dart';
import '../../../logic/size/size_cubit.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_endpoints.dart';

// زر الاضافة للسلة:
// الحافة العلوية تتمدد وتخرج منها صورة المنتج ثم تنزل داخل السلة
// السلة تمتلئ بالاخضر وترسم علامة صح ثم تنطلق رافعة عجلاتها الامامية
class AddToCartButton extends StatefulWidget {
  const AddToCartButton({super.key});

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> with TickerProviderStateMixin {
  late final AnimationController _controller; // الحركة الكاملة
  late final AnimationController _restore; // رجوع السلة والنص بعد الانتهاء
  late final AnimationController _shake; // اهتزاز عند عدم اختيار مقاس

  late final Animation<double> _press;
  late final Animation<double> _bump;
  late final Animation<double> _textOpacity;
  late final Animation<double> _imageRise;
  late final Animation<double> _imageFall;
  late final Animation<double> _imageScale;
  late final Animation<double> _imageOpacity;
  late final Animation<double> _fill;
  late final Animation<double> _check;
  late final Animation<double> _exit;
  late final Animation<double> _cartOpacity;

  bool _done = false; // عرض تمت الاضافة

  static const String _fallbackImage = 'assets/images/app icon/icon.png';
  static const double _productImageSize = 24;
  static const double _fallbackImageSize = 36; // الايقونة فيها فراغ داخلي فنكبرها
  static const double _startX = 16; // مكان السلة وقت الراحة

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
    _restore = AnimationController(vsync: this, duration: const Duration(milliseconds: 600), value: 1);
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    CurvedAnimation part(double a, double b, [Curve c = Curves.linear]) =>
        CurvedAnimation(parent: _controller, curve: Interval(a, b, curve: c));

    // ضغطة خفيفة للزر
    _press = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.96).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
    ]).animate(part(0.0, 0.10));

    // تمدد الحافة العلوية ثم رجوعها بارتداد ناعم
    _bump = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 55),
    ]).animate(part(0.04, 0.30));

    _textOpacity = Tween<double>(begin: 1, end: 0).animate(part(0.0, 0.18, Curves.easeOut));

    // الصورة تخرج من قمة الحافة وتصعد ثم تسقط في السلة
    _imageRise = Tween<double>(begin: 0, end: 1).animate(part(0.12, 0.32, Curves.easeOutCubic));
    _imageFall = Tween<double>(begin: 0, end: 1).animate(part(0.32, 0.50, Curves.easeInCubic));
    _imageScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 50),
    ]).animate(part(0.12, 0.50));
    _imageOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(part(0.12, 0.50));

    // امتلاء السلة بالاخضر ثم رسم علامة الصح
    _fill = Tween<double>(begin: 0, end: 1).animate(part(0.47, 0.58, Curves.easeOutCubic));
    _check = Tween<double>(begin: 0, end: 1).animate(part(0.56, 0.68, Curves.easeInOutCubic));

    // الانطلاق للخروج
    _exit = Tween<double>(begin: 0, end: 1).animate(part(0.70, 1.0));
    _cartOpacity = Tween<double>(begin: 1, end: 0).animate(part(0.93, 1.0, Curves.easeIn));

    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      setState(() => _done = true);
      HapticFeedback.selectionClick();
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() => _done = false);
        _controller.reset();
        _restore.forward(from: 0);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _restore.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context) {
    if (_controller.isAnimating || _done || _restore.isAnimating) return;
    final selectedSize = context.read<DialogSizeCubit>().state;
    final selectedColor = context.read<DialogProductCubit>().state;

    if (selectedSize == null) {
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
      AppToasts.showWarningToast(context, tr('cart_select_size'));
      return;
    }

    HapticFeedback.lightImpact();
    _controller.forward(from: 0.0);
    context.read<CartCubit>().addToCart(
      productId: selectedSize.pId,
      sizeId: selectedSize.sizeId,
      colorId: selectedColor.colorId,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    final selectedColor = context.watch<DialogProductCubit>().state;

    final bool hasImage = selectedColor.images.isNotEmpty && selectedColor.images.first.imgUrl.isNotEmpty;
    final String? imageUrl = hasImage
        ? (selectedColor.images.first.imgUrl.startsWith('http')
        ? selectedColor.images.first.imgUrl
        : ApiEndpoints.productImageUrl(selectedColor.images.first.imgUrl))
        : null;

    final double height = isDesktop ? 48 : 44;
    final double cartSize = isDesktop ? 25 : 20;

    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final double cartMiddle = width / 2 - cartSize / 2;
      final double cartTop = (height - cartSize) / 2;

      return AnimatedBuilder(
        animation: Listenable.merge([_controller, _restore, _shake]),
        builder: (context, _) {
          final t = _controller.value;
          final animating = t > 0;

          // موضع السلة من بداية الزر
          double cartX;
          if (!animating) {
            // رجوع السلة من خارج الزر لمكانها
            cartX = -cartSize + (_startX + cartSize) * Curves.easeOutCubic.transform(_restore.value);
          } else if (t < 0.30) {
            cartX = _startX + (cartMiddle - _startX) * Curves.easeInOutCubic.transform(t / 0.30);
          } else if (_exit.value == 0) {
            cartX = cartMiddle;
          } else {
            cartX = cartMiddle + (width + 10 - cartMiddle) * Curves.easeInCubic.transform(_exit.value);
          }

          // رفع العجلات الامامية تدريجيا مع المشي
          final tilt = 0.32 * Curves.easeInOutSine.transform((_exit.value * 1.6).clamp(0.0, 1.0));

          // اهتزاز يتلاشى
          final s = _shake.value;
          final shakeDx = math.sin(s * math.pi * 6) * 7 * (1 - s);

          final double bumpHeight = 16 * _bump.value;
          final double cartLeft = isRtl ? width - cartX - cartSize : cartX;

          return Transform.translate(
            offset: Offset(shakeDx, 0),
            child: Transform.scale(
              scale: animating ? _press.value : 1,
              child: GestureDetector(
                onTap: () => _onTap(context),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // الخلفية مع تمدد الحافة العلوية
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ButtonPainter(
                            bump: bumpHeight,
                            fill: Color.alphaBlend(
                              AppColors.background,
                              AppColors.backgroundSecondary,
                            ),
                            border: AppColors.primary.withOpacity(0.35),
                          ),
                        ),
                      ),

                      // النص
                      Positioned.fill(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(anim), child: child),
                            ),
                            child: _done ? _doneLabel(isDesktop) : _idleLabel(isDesktop),
                          ),
                        ),
                      ),

                      // السلة
                      if (!_done)
                        Positioned(
                          left: cartLeft,
                          top: cartTop,
                          child: Opacity(
                            opacity: _cartOpacity.value.clamp(0.0, 1.0),
                            child: Transform.rotate(
                              // الدوران حول العجلة الخلفية
                              angle: isRtl ? tilt : -tilt,
                              alignment: isRtl ? const Alignment(0.25, 0.75) : const Alignment(-0.25, 0.75),
                              child: CustomPaint(
                                size: Size(cartSize, cartSize),
                                painter: _CartPainter(
                                  color: AppColors.iconColor,
                                  fill: _fill.value,
                                  check: _check.value,
                                  rtl: isRtl,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // صورة المنتج
                      if (t > 0.12 && t < 0.51)
                        _flyingImage(
                          url: imageUrl,
                          startX: width / 2,
                          startY: -bumpHeight,
                          landX: cartLeft + cartSize * _CartPainter.basketCenterX(isRtl),
                          landY: cartTop + cartSize * _CartPainter.basketCenterY,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _idleLabel(bool isDesktop) {
    return Opacity(
      key: const ValueKey('idle'),
      opacity: (_textOpacity.value * _restore.value).clamp(0.0, 1.0),
      child: Text(
        tr('add_to_cart'),
        style: TextStyle(fontSize: isDesktop ? 15 : 13, fontWeight: FontWeight.bold, color: AppColors.textColor),
      ),
    );
  }

  Widget _doneLabel(bool isDesktop) {
    return Row(
      key: const ValueKey('done'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: isDesktop ? 20 : 18),
        const SizedBox(width: 6),
        Text(
          tr('cart_added'),
          style: TextStyle(fontSize: isDesktop ? 15 : 13, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  // الصورة تخرج من قمة الحافة وتصعد ثم تسقط في مركز حوض السلة
  Widget _flyingImage({
    required String? url,
    required double startX,
    required double startY,
    required double landX,
    required double landY,
  }) {
    final double size = url == null ? _fallbackImageSize : _productImageSize;
    const double peak = -44;

    final rise = _imageRise.value;
    final fall = _imageFall.value;

    // الصعود من الحافة ثم النزول للسلة
    final double cy = fall == 0 ? startY + (peak - startY) * rise : peak + (landY - peak) * fall;
    final double cx = startX + (landX - startX) * fall;

    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      child: Opacity(
        opacity: _imageOpacity.value.clamp(0.0, 1.0),
        child: Transform.scale(scale: _imageScale.value, child: _buildProductImage(url)),
      ),
    );
  }

  // صورة اللون المختار او ايقونة التطبيق بدون خلفية
  Widget _buildProductImage(String? url) {
    final fallback = Image.asset(_fallbackImage, width: _fallbackImageSize, height: _fallbackImageSize, fit: BoxFit.contain);
    if (url == null) return fallback;
    return SizedBox(
      width: _productImageSize,
      height: _productImageSize,
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (_, provider) => ClipOval(
          child: Image(image: provider, width: _productImageSize, height: _productImageSize, fit: BoxFit.cover),
        ),
        placeholder: (_, __) => OverflowBox(maxWidth: _fallbackImageSize, maxHeight: _fallbackImageSize, child: fallback),
        errorWidget: (_, __, ___) => OverflowBox(maxWidth: _fallbackImageSize, maxHeight: _fallbackImageSize, child: fallback),
      ),
    );
  }
}

// رسم الزر مع نتوء في منتصف الحافة العلوية
class _ButtonPainter extends CustomPainter {
  final double bump;
  final Color fill;
  final Color border;

  _ButtonPainter({required this.bump, required this.fill, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 12.0;
    const bw = 70.0; // عرض منطقة التمدد
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final path = Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(cx - bw / 2, 0)
    // انحناء يصعد لقمة مدببة
      ..cubicTo(cx - bw * 0.2, 0, cx - bw * 0.06, -bump, cx, -bump)
      ..cubicTo(cx + bw * 0.06, -bump, cx + bw * 0.2, 0, cx + bw / 2, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..close();

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ButtonPainter old) => old.bump != bump || old.fill != fill || old.border != border;
}

// رسم السلة مع امتلاء اخضر وعلامة صح ترسم تدريجيا
class _CartPainter extends CustomPainter {
  final Color color;
  final double fill;
  final double check;
  final bool rtl;

  _CartPainter({required this.color, required this.fill, required this.check, required this.rtl});

  // مركز الحوض كنسبة من حجم السلة
  static double basketCenterX(bool rtl) => rtl ? 1 - 14.6 / 24 : 14.6 / 24;
  static const double basketCenterY = 10.8 / 24;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24;

    canvas.save();
    // عكس السلة في العربي
    if (rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // حوض السلة
    final basket = Path()
      ..moveTo(6 * u, 6 * u)
      ..lineTo(23 * u, 6 * u)
      ..lineTo(21.36 * u, 14.39 * u)
      ..quadraticBezierTo(21 * u, 16 * u, 19.4 * u, 16 * u)
      ..lineTo(9.68 * u, 16 * u)
      ..quadraticBezierTo(8 * u, 16 * u, 7.68 * u, 14.39 * u)
      ..close();

    // الامتلاء من الاسفل للاعلى
    if (fill > 0) {
      canvas.save();
      canvas.clipPath(basket);
      final top = 16 * u - (10 * u) * fill;
      canvas.drawRect(Rect.fromLTRB(0, top, size.width, 16 * u + 1), Paint()..color = color);
      canvas.restore();
    }

    // المقبض والحوض
    final outline = Path()
      ..moveTo(1 * u, 1 * u)
      ..lineTo(5 * u, 1 * u)
      ..lineTo(7.68 * u, 14.39 * u)
      ..quadraticBezierTo(8 * u, 16 * u, 9.68 * u, 16 * u)
      ..lineTo(19.4 * u, 16 * u)
      ..quadraticBezierTo(21 * u, 16 * u, 21.36 * u, 14.39 * u)
      ..lineTo(23 * u, 6 * u)
      ..lineTo(6 * u, 6 * u);

    canvas.drawPath(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * u
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // العجلات
    final wheel = Paint()..color = color;
    canvas.drawCircle(Offset(9 * u, 21 * u), 1.7 * u, wheel);
    canvas.drawCircle(Offset(20 * u, 21 * u), 1.7 * u, wheel);
    canvas.restore();

    // علامة صح واحدة عريضة ترسم تدريجيا وبدون انعكاس
    if (check > 0) {
      final bx = size.width * basketCenterX(rtl);
      final by = size.height * basketCenterY;
      final tick = Path()
        ..moveTo(bx - 3.6 * u, by + 0.2 * u)
        ..lineTo(bx - 1.1 * u, by + 2.7 * u)
        ..lineTo(bx + 3.8 * u, by - 2.6 * u);

      final metric = tick.computeMetrics().first;
      final drawn = metric.extractPath(0, metric.length * check);
      canvas.drawPath(
        drawn,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * u
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CartPainter old) =>
      old.fill != fill || old.check != check || old.color != color || old.rtl != rtl;
}