import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/badge_count.dart';

// عداد الكمية مع حركة الرقم كشريط للأعلى أو للأسفل
class CartQuantityCounter extends StatefulWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final double height;

  const CartQuantityCounter({
    super.key,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.height = 34,
  });

  @override
  State<CartQuantityCounter> createState() => _CartQuantityCounterState();
}

class _CartQuantityCounterState extends State<CartQuantityCounter> {
  // اتجاه الحركة 1 للزيادة و -1 للنقصان
  double _direction = 1;

  @override
  void didUpdateWidget(covariant CartQuantityCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _direction = widget.quantity > oldWidget.quantity ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOne = widget.quantity <= 1;

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(widget.height),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterButton(
            size: widget.height - 6,
            danger: isOne,
            onTap: widget.onDecrement,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isOne ? CupertinoIcons.trash : CupertinoIcons.minus,
                key: ValueKey(isOne),
                size: 14,
                color: isOne ? AppColors.redColor : AppColors.iconColor,
              ),
            ),
          ),

          // الرقم المتحرك
          SizedBox(
            width: 32,
            height: widget.height - 6,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  children: [...previous, if (current != null) current],
                ),
                transitionBuilder: (child, anim) {
                  final isIncoming = child.key == ValueKey(widget.quantity);
                  // الداخل يأتي من جهة الاتجاه والخارج يخرج من الجهة الاخرى
                  final offset = Tween<Offset>(
                    begin: Offset(0, isIncoming ? _direction : -_direction),
                    end: Offset.zero,
                  ).animate(anim);
                  return SlideTransition(
                    position: offset,
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: Text(
                  badgeCount(widget.quantity),
                  key: ValueKey(widget.quantity),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ),

          _CounterButton(
            size: widget.height - 6,
            filled: true,
            onTap: widget.onIncrement,
            child: const Icon(CupertinoIcons.plus, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// زر دائري صغير للعداد
class _CounterButton extends StatefulWidget {
  final double size;
  final bool filled;
  final bool danger;
  final VoidCallback? onTap;
  final Widget child;

  const _CounterButton({
    required this.size,
    required this.child,
    this.filled = false,
    this.danger = false,
    this.onTap,
  });

  @override
  State<_CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<_CounterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled
        ? AppColors.primary
        : widget.danger
        ? AppColors.redColor.withOpacity(0.10)
        : AppColors.backgroundSecondary;

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap == null
          ? null
          : () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: widget.child,
        ),
      ),
    );
  }
}