import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';

// ألوان ثابتة لبطاقة المعلومات لأن خلفيتها فاتحة دائما
const _kText = Color(0xFF111827);
const _kLabel = Color(0xFF6B7280);
const _kMint = Color(0xFFDDF6EE);
const _kGreen = Color(0xFF0B6E58);

// عنوان القسم
class AccountSectionTitle extends StatelessWidget {
  final String text;
  const AccountSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isDesktop ? 14 : 13,
          fontWeight: FontWeight.bold,
          letterSpacing: .3,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// بطاقة تجمع عناصر القسم مع فواصل وخلفية اختيارية
class AccountSectionCard extends StatelessWidget {
  final List<Widget> children;
  final String? background;
  final String? title;

  const AccountSectionCard({super.key, required this.children, this.background, this.title});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(
          height: 1,
          indent: isDesktop ? 76 : 64,
          endIndent: 16,
          color: Colors.black.withValues(alpha: .06),
        ));
      }
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 26 : 22),
        border: Border.all(color: _kMint),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // صورة الخلفية خلف المحتوى
            if (background != null)
              Positioned.fill(
                child: Transform.flip(
                  // قلب الصورة في الإنجليزي عشان الرسمة تبقى مقابل الصفوف
                  flipX: Directionality.of(context) == TextDirection.ltr,
                  child: _buildBackground(background!),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان القسم على شكل تبويب
                if (title != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 18 : 14, vertical: isDesktop ? 10 : 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFBFEFDF), Color(0xFFE6F8F2)]),
                      borderRadius: BorderRadiusDirectional.only(bottomEnd: Radius.circular(22)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.person_2_fill, size: isDesktop ? 20 : 17, color: _kGreen),
                        const SizedBox(width: 8),
                        Text(
                          title!,
                          style: TextStyle(fontSize: isDesktop ? 15 : 13.5, fontWeight: FontWeight.bold, color: _kText),
                        ),
                      ],
                    ),
                  ),
                ...items,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // يدعم svg و png
  Widget _buildBackground(String path) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.cover, alignment: Alignment.centerLeft);
    }
    return Image.asset(path, fit: BoxFit.cover, alignment: Alignment.centerLeft);
  }
}

// مربع الأيقونة
class AccountIconBox extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const AccountIconBox(this.icon, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final c = color ?? _kGreen;
    return Container(
      width: isDesktop ? 48 : 42,
      height: isDesktop ? 48 : 42,
      decoration: BoxDecoration(
        color: color == null ? _kMint : c.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(isDesktop ? 15 : 13),
      ),
      child: Icon(icon, size: isDesktop ? 23 : 20, color: c),
    );
  }
}

// صف عرض معلومة (اسم، إيميل، هاتف)
class AccountInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final TextDirection? valueDirection;

  const AccountInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.valueDirection,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 18 : 14, vertical: isDesktop ? 16 : 13),
        child: Row(
          children: [
            AccountIconBox(icon),
            SizedBox(width: isDesktop ? 14 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: isDesktop ? 13 : 11.5, color: _kLabel),
                  ),
                  const SizedBox(height: 3),
                  // محاذاة القيمة مع بداية السطر حتى لو كانت ltr
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: valueDirection,
                      style: TextStyle(
                        fontSize: isDesktop ? 16.5 : 15,
                        fontWeight: FontWeight.bold,
                        color: _kText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

// زر صغير دائري (تعديل)
class AccountPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const AccountPillButton({super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Material(
      color: Colors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 14 : 12, vertical: isDesktop ? 8 : 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: isDesktop ? 15 : 13, color: _kGreen),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  fontWeight: FontWeight.bold,
                  color: _kGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// علامة الحقل غير القابل للتعديل
class AccountLockedBadge extends StatelessWidget {
  const AccountLockedBadge({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tr('account_email_locked'),
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        shape: BoxShape.circle,
        border: Border.all(color: _kMint),
      ),
      child: const Icon(CupertinoIcons.lock_fill, size: 13, color: _kLabel),
    ),
  );
}

// بطاقة تسجيل الخروج
class AccountLogoutCard extends StatelessWidget {
  final VoidCallback onTap;
  const AccountLogoutCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final red = AppColors.redColor;
    final radius = BorderRadius.circular(isDesktop ? 26 : 22);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: red.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              // خلفية وردية متدرجة
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [red.withValues(alpha: .10), red.withValues(alpha: .05)],
              ),
              border: Border.all(color: red.withValues(alpha: .22)),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  // الموجة البيضاء بالخلفية
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LogoutWavePainter(isRtl: Directionality.of(context) == TextDirection.rtl),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(isDesktop ? 18 : 14),
                    child: Row(
                      children: [
                        // مربع الأيقونة
                        Container(
                          width: isDesktop ? 58 : 50,
                          height: isDesktop ? 58 : 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isDesktop ? 18 : 16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [red.withValues(alpha: .18), red.withValues(alpha: .10)],
                            ),
                            border: Border.all(color: Colors.white.withValues(alpha: .6)),
                          ),
                          child: Icon(Icons.logout_rounded, color: red, size: isDesktop ? 28 : 24),
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),

                        // العنوان والوصف
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tr('logout'),
                                style: TextStyle(
                                  fontSize: isDesktop ? 19 : 17,
                                  fontWeight: FontWeight.bold,
                                  color: red,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 5 : 3),
                              Text(
                                tr('account_logout_hint'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: isDesktop ? 13.5 : 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        // السهم ينقلب تلقائيا حسب اللغة
                        Icon(Icons.arrow_forward_ios_rounded, size: isDesktop ? 18 : 16, color: red),
                        SizedBox(width: isDesktop ? 6 : 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// رسم الموجة البيضاء داخل بطاقة الخروج
class _LogoutWavePainter extends CustomPainter {
  final bool isRtl;
  _LogoutWavePainter({required this.isRtl});

  @override
  void paint(Canvas canvas, Size size) {
    // قلب الرسم في الإنجليزي
    if (!isRtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final w = size.width;
    final h = size.height;

    // الموجة الكبيرة
    final wave = Path()
      ..moveTo(w * .30, 0)
      ..cubicTo(w * .48, h * .15, w * .42, h * .85, w * .62, h)
      ..lineTo(w * .78, h)
      ..cubicTo(w * .58, h * .80, w * .62, h * .20, w * .46, 0)
      ..close();

    canvas.drawPath(
      wave,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: .75), Colors.white.withValues(alpha: .15)],
        ).createShader(Offset.zero & size),
    );

    // خط رفيع بجانب الموجة
    final line = Path()
      ..moveTo(w * .26, 0)
      ..cubicTo(w * .44, h * .18, w * .38, h * .85, w * .56, h);

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.redColor.withValues(alpha: .18),
    );
  }

  @override
  bool shouldRepaint(covariant _LogoutWavePainter old) => old.isRtl != isRtl;
}