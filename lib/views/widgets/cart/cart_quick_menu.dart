import 'dart:math';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/cart_model.dart';
import '../../../core/constants/app_colors.dart';
import 'cart_item_card.dart';

enum CartQuickAction { edit, details, similar, tryOn, share, delete }

// قائمة الضغط المطول لبطاقة السلة
class CartQuickMenu {
  static Future<CartQuickAction?> show(BuildContext cardContext, CartModel item) async {
    // مكان البطاقة على الشاشة
    final box = cardContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final rect = box.localToGlobal(Offset.zero) & box.size;

    HapticFeedback.mediumImpact();

    return showGeneralDialog<CartQuickAction>(
      context: cardContext,
      barrierDismissible: true,
      barrierLabel: 'cart_menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _CartMenuView(item: item, rect: rect),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

class _MenuItem {
  final CartQuickAction action;
  final IconData icon;
  final String label;
  final bool danger;
  const _MenuItem(this.action, this.icon, this.label, {this.danger = false});
}

class _CartMenuView extends StatelessWidget {
  final CartModel item;
  final Rect rect;

  const _CartMenuView({required this.item, required this.rect});

  static const double _itemHeight = 46;

  List<_MenuItem> _items() => [
    if (item.canEditOptions) _MenuItem(CartQuickAction.edit, Icons.tune_rounded, tr('cart_edit_item')),
    _MenuItem(CartQuickAction.details, CupertinoIcons.info, tr('product_details')),
    _MenuItem(CartQuickAction.similar, Icons.center_focus_strong_outlined, tr('similar_products')),
    _MenuItem(CartQuickAction.tryOn, Icons.checkroom_outlined, tr('try_on')),
    _MenuItem(CartQuickAction.share, Icons.share_outlined, tr('share_product')),
    _MenuItem(CartQuickAction.delete, CupertinoIcons.trash, tr('cart_remove_item'), danger: true),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screen = media.size;
    final items = _items();
    final menuHeight = min(items.length * _itemHeight + 12, screen.height - media.padding.vertical - 20);

    // اختيار الجهة الأوسع بجانب البطاقة
    final spaceRight = screen.width - rect.right - 10;
    final spaceLeft = rect.left - 10;
    final sideWidth = min(230.0, max(spaceRight, spaceLeft) - 10);

    double width;
    double left;
    double top;

    if (sideWidth >= 170) {
      width = sideWidth;
      left = spaceRight >= spaceLeft ? rect.right + 10 : rect.left - width - 10;
      top = rect.top;
    } else {
      // لا توجد مساحة جانبية: تحت البطاقة او فوقها
      width = min(240.0, screen.width - 20);
      final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
      // محاذاة القائمة مع بداية البطاقة حسب اللغة
      left = isRtl ? rect.right - width : rect.left;
      top = rect.bottom + 10;
      if (top + menuHeight > screen.height - media.padding.bottom) {
        top = rect.top - menuHeight - 10;
      }
    }

    left = left.clamp(10.0, max(10.0, screen.width - width - 10));
    final minTop = media.padding.top + 10;
    final maxTop = max(minTop, screen.height - media.padding.bottom - menuHeight - 10);
    top = top.clamp(minTop, maxTop);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // خلفية ضبابية تغلق القائمة
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const ColoredBox(color: Colors.black45),
              ),
            ),
          ),

          // البطاقة مرفوعة
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                builder: (_, t, child) => Transform.translate(
                  offset: Offset(0, -8 * t),
                  child: Transform.scale(scale: 1 + 0.03 * t, child: child),
                ),
                child: CartItemCard(item: item, lifted: true, onIncrement: () {}, onDecrement: () {}),
              ),
            ),
          ),

          // القائمة الزجاجية
          Positioned(
            left: left,
            top: top,
            width: width,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) => Opacity(
                opacity: t,
                child: Transform.scale(scale: 0.92 + 0.08 * t, alignment: Alignment.topCenter, child: child),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: menuHeight),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            _MenuTile(item: items[i]),
                            if (i != items.length - 1)
                              Divider(
                                height: 1,
                                indent: 14,
                                endIndent: 14,
                                color: Colors.white.withOpacity(0.08),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  // احمر فاتح يظهر على الزجاج
  static const Color _danger = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    final color = item.danger ? _danger : AppColors.primary;

    return InkWell(
      onTap: () => Navigator.pop(context, item.action),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.06),
      child: SizedBox(
        height: _CartMenuView._itemHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Icon(item.icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: item.danger ? _danger : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}