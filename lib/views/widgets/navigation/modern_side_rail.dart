import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/cart/cart_cubit.dart';
import '../../../logic/login/login_cubit.dart';
import '../../../logic/notifications/notification_cubit.dart';
import '../../../logic/notifications/notification_state.dart';
import '../../../logic/products/product_event_bus.dart';

class ModernSideRail extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernSideRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernSideRail> createState() => _ModernSideRailState();
}

class _ModernSideRailState extends State<ModernSideRail> {
  // المقاسات
  static const double _collapsed = 76;
  static const double _expanded = 250;
  static const Duration _duration = Duration(milliseconds: 280);
  static const Curve _curve = Curves.easeOutCubic;

  bool isExpanded = false;
  Timer? _exitTimer;

  // فتح فوري
  void _open() {
    _exitTimer?.cancel();
    if (!isExpanded) setState(() => isExpanded = true);
  }

  // إغلاق بتأخير بسيط لمنع الوميض
  void _close() {
    _exitTimer?.cancel();
    _exitTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => isExpanded = false);
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => _open(),
        onExit: (_) => _close(),
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          width: isExpanded ? _expanded : _collapsed,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientTop, AppColors.gradientBottom],
            ),
            border: BorderDirectional(
              end: BorderSide(color: AppColors.borderColor.withOpacity(0.6)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isExpanded ? 0.08 : 0.02),
                blurRadius: isExpanded ? 30 : 10,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          // المحتوى بعرض ثابت حتى لا يعاد ترتيبه أثناء الحركة
          child: ClipRect(
            child: OverflowBox(
              alignment: AlignmentDirectional.centerStart,
              minWidth: _expanded,
              maxWidth: _expanded,
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  _buildLogo(),
                  const SizedBox(height: 22),
                  Expanded(child: _buildItems()),
                  _buildSocial(),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== الشعار ====================
  Widget _buildLogo() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: _collapsed,
            child: Center(child: Logo(width: 38, height: 38)),
          ),
          Expanded(
            child: _fade(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nice abayas",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    "SMART STORE",
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== العناصر ====================
  Widget _buildItems() {
    return BlocBuilder<LoginCubit, bool>(
      builder: (context, loggedIn) {
        final box = Hive.box('user_info_box');
        final String userName = box.isEmpty ? '' : (box.get('name') ?? '');
        final String labelName = loggedIn && userName.isNotEmpty ? userName : tr('guest');
        final int cartCount = context.watch<CartCubit>().allProducts.length;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _section(tr('menu_browse')),
            _item(0, Icons.play_circle_outline, Icons.play_circle, tr('reel')),
            _item(1, Icons.auto_awesome_outlined, Icons.auto_awesome, tr('new')),
            _item(2, CupertinoIcons.home, CupertinoIcons.house_fill, tr('home')),
            _item(3, CupertinoIcons.cart, CupertinoIcons.cart_fill, tr('cart'),
                count: cartCount, badgeColor: AppColors.redColor),
            StreamBuilder<ProductModel>(
              stream: ProductEventBus.stream,
              builder: (context, _) => _item(
                5,
                CupertinoIcons.heart,
                CupertinoIcons.heart_fill,
                tr('favorite'),
                count: ProductEventBus.favoriteCount,
                badgeColor: AppColors.primary,
              ),
            ),

            _section(tr('menu_account')),
            _item(4, CupertinoIcons.person, CupertinoIcons.person_fill, labelName),
            BlocBuilder<NotificationCubit, NotificationState>(
              buildWhen: (a, b) => a.unreadCount != b.unreadCount,
              builder: (context, state) => _item(
                6,
                CupertinoIcons.bell,
                CupertinoIcons.bell_fill,
                tr('notifications'),
                count: state.unreadCount,
                badgeColor: AppColors.redColor,
              ),
            ),
            _item(7, CupertinoIcons.list_bullet_below_rectangle,
                CupertinoIcons.list_bullet_below_rectangle, tr('orders')),
            _item(8, Icons.location_on_outlined,  Icons.location_on, tr('addresses')),
            _item(9,  Icons.smart_toy_outlined,  Icons.smart_toy,
                tr('smart assistant')),
          ],
        );
      },
    );
  }

  // عنوان القسم يظهر عند الفتح وخط عند الإغلاق
  Widget _section(String title) {
    return SizedBox(
      height: 34,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          AnimatedOpacity(
            duration: _duration,
            opacity: isExpanded ? 0 : 1,
            child: Container(
              width: 22,
              height: 1.5,
              margin: const EdgeInsetsDirectional.only(start: (_collapsed - 22) / 2),
              color: AppColors.borderColor,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 26),
            child: _fade(
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
      int index,
      IconData icon,
      IconData activeIcon,
      String label, {
        int count = 0,
        Color? badgeColor,
      }) {
    final bool selected = widget.currentIndex == index;
    final bool hasCount = count > 0;
    final Color color = selected ? AppColors.primary : AppColors.iconColor;
    final String countText = count > 9 ? '9+' : '$count';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        height: 46,
        child: Stack(
          children: [
            // خلفية العنصر المختار تتمدد مع القائمة
            PositionedDirectional(
              start: 12,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: _duration,
                curve: _curve,
                width: (isExpanded ? _expanded : _collapsed) - 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            // مؤشر جانبي للعنصر المختار
            PositionedDirectional(
              start: 0,
              top: 12,
              bottom: 12,
              child: AnimatedContainer(
                duration: _duration,
                curve: _curve,
                width: selected ? 4 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    end: Radius.circular(4),
                  ),
                ),
              ),
            ),

            // المحتوى
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  hoverColor: AppColors.primary.withOpacity(0.05),
                  onTap: () => widget.onTap(index),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _collapsed,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                selected ? activeIcon : icon,
                                key: ValueKey(selected),
                                size: 21,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        // مساحة للرقم بجانب الاسم
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(end: hasCount ? 60 : 16),
                          child: _fade(
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: selected ? AppColors.primary : AppColors.textColor,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // رقم واحد ينتقل من فوق الأيقونة الى جانب الاسم
            if (hasCount)
              AnimatedPositionedDirectional(
                duration: _duration,
                curve: _curve,
                start: isExpanded ? _expanded - 24 - 30 : _collapsed / 2 + 2,
                top: isExpanded ? 13 : 3,
                child: IgnorePointer(child: _badge(countText, badgeColor)),
              ),
          ],
        ),
      ),
    );
  }

  // الرقم يكبر ويصغر مع الانتقال
  Widget _badge(String text, Color? color) {
    return AnimatedContainer(
      duration: _duration,
      curve: _curve,
      width: isExpanded ? 30 : 18,
      height: isExpanded ? 20 : 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? AppColors.redColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isExpanded ? Colors.transparent : AppColors.background,
          width: 1.5,
        ),
      ),
      child: AnimatedDefaultTextStyle(
        duration: _duration,
        curve: _curve,
        style: TextStyle(
          color: Colors.white,
          fontSize: isExpanded ? 10 : 8,
          fontWeight: FontWeight.bold,
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  // ظهور واختفاء النصوص بسلاسة
  Widget _fade(Widget child) {
    // اتجاه الانزلاق حسب اللغة
    final double dx = Directionality.of(context) == ui.TextDirection.rtl ? 0.08 : -0.08;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      curve: _curve,
      opacity: isExpanded ? 1 : 0,
      child: AnimatedSlide(
        duration: _duration,
        curve: _curve,
        offset: isExpanded ? Offset.zero : Offset(dx, 0),
        child: child,
      ),
    );
  }

  // ==================== التواصل الاجتماعي ====================
  Widget _buildSocial() {
    final icons = [
      SocialIcon(icon: FontAwesomeIcons.whatsapp, color: const Color(0xFF25D366)),
      SocialIcon(icon: FontAwesomeIcons.x, color: AppColors.iconColor),
      SocialIcon(icon: FontAwesomeIcons.instagram, color: const Color(0xFFE1306C)),
      SocialIcon(icon: FontAwesomeIcons.facebook, color: const Color(0xFF1877F2)),
      SocialIcon(icon: FontAwesomeIcons.threads, color: AppColors.iconColor),
    ];

    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          color: AppColors.borderColor.withOpacity(0.6),
        ),
        // تغيير الاتجاه مع تحريك الارتفاع
        AnimatedSize(
          duration: _duration,
          curve: _curve,
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: _curve,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(animation), child: child),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [...previous, if (current != null) current],
            ),
            child: isExpanded
                ? Padding(
              key: const ValueKey('row'),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: icons,
              ),
            )
                : SizedBox(
              key: const ValueKey('column'),
              width: _collapsed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: icons,
              ),
            ),
          ),
        ),
      ],
    );
  }
}