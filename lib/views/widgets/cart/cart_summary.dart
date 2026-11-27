import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/utils/badge_count.dart';
import '../../../core/widgets/buttons/app_button.dart';

// رقم سعر يتحرك بسلاسة عند تغيره
class AnimatedPrice extends StatelessWidget {
  final double value;
  final TextStyle style;
  final String prefix;

  const AnimatedPrice({super.key, required this.value, required this.style, this.prefix = ''});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text("$prefix${v.toStringAsFixed(2)} \$", style: style),
    );
  }
}

// ملخص الطلب كلوحة جانبية للشاشات الكبيرة
class CartSummaryPanel extends StatelessWidget {
  final double totalPrice;
  final double totalDiscount;
  final int itemCount;
  final VoidCallback onCheckout;

  const CartSummaryPanel({
    super.key,
    required this.totalPrice,
    required this.totalDiscount,
    required this.itemCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalPrice - totalDiscount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppShadow.commonShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.doc_text, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                tr('order_summary'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row(tr('cart_pieces_count'), Text(badgeCount(itemCount), style: _valueStyle)),
          _row(tr('cart_items_subtotal'), AnimatedPrice(value: totalPrice, style: _valueStyle)),
          _row(
            tr('discount'),
            AnimatedPrice(
              value: totalDiscount,
              prefix: totalDiscount > 0 ? '- ' : '',
              style: _valueStyle.copyWith(color: AppColors.redColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borderColor),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('cart_net_total'),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColor),
                ),
              ),
              AnimatedPrice(
                value: net,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          if (totalDiscount > 0) ...[
            const SizedBox(height: 12),
            _SavingBanner(amount: totalDiscount),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: AppButton(label: tr('checkout'), icon: Icons.credit_card, iconSize: 18, onTap: onCheckout),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.lock_shield, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(tr('cart_secure_checkout'), style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle get _valueStyle => TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColor);

  Widget _row(String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        value,
      ],
    ),
  );
}

// شريط الملخص السفلي للجوال والايباد
class CartSummaryBar extends StatelessWidget {
  final double totalPrice;
  final double totalDiscount;
  final int itemCount;
  final VoidCallback onCheckout;

  const CartSummaryBar({
    super.key,
    required this.totalPrice,
    required this.totalDiscount,
    required this.itemCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalPrice - totalDiscount;
    final isIpad = MediaQuery.of(context).size.width > 450;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      // heightFactor يمنع الشريط من التمدد لكامل الشاشة
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // المجموع والخصم
              Row(
                children: [
                  _mini(tr('cart_items_subtotal'), AnimatedPrice(value: totalPrice, style: _miniValue)),
                  const SizedBox(width: 18),
                  if (totalDiscount > 0)
                    _mini(
                      tr('discount'),
                      AnimatedPrice(value: totalDiscount, prefix: '- ', style: _miniValue.copyWith(color: AppColors.redColor)),
                    ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: totalDiscount > 0 ? _SavingBanner(amount: totalDiscount, compact: true) : const SizedBox(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // الاجمالي النهائي
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tr('cart_net_total'), style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      AnimatedPrice(
                        value: net,
                        style: TextStyle(fontSize: isIpad ? 19 : 17, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: isIpad ? 46 : 42,
                      child: AppButton(
                        onTap: onCheckout,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.credit_card, color: Colors.white, size: 17),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                tr('checkout'),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // عدد القطع
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badgeCount(itemCount),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _miniValue => TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textColor);

  Widget _mini(String label, Widget value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      value,
    ],
  );
}

// شارة مبلغ التوفير
class _SavingBanner extends StatelessWidget {
  final double amount;
  final bool compact;

  const _SavingBanner({required this.amount, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? null : double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(compact ? 20 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.tag_fill, size: compact ? 11 : 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              tr('cart_you_saved', args: [amount.toStringAsFixed(2)]),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 10.5 : 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}