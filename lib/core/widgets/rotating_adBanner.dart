// 1. ودجت المؤقت وإدارة تدوير الإعلانات تلقائياً كل 30 ثانية
import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/AdModel.dart';

class RotatingAdBanner extends StatefulWidget {
  final List<AdModel> advertisements;

  const RotatingAdBanner({
    super.key,
    required this.advertisements,
  });

  @override
  State<RotatingAdBanner> createState() => _RotatingAdBannerState();
}

class _RotatingAdBannerState extends State<RotatingAdBanner> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // تفعيل المؤقت فقط إذا كان هناك أكثر من إعلان واحد
    if (widget.advertisements.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.advertisements.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف المؤقت عند الخروج لتجنب تسرب الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    // جلب الإعلان الحالي بناءً على الترتيب
    final currentAd = widget.advertisements[_currentIndex];

    // تحويل تاريخ الانتهاء النصي إلى DateTime بأمان
    DateTime expiryDate = DateTime.tryParse(currentAd.expiresAt) ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ProductAdBanner(
        title: currentAd.adsName, // اسم الإعلان الديناميكي الحقيقي
        endDate: expiryDate,     // تاريخ الانتهاء الحقيقي
      ),
    );
  }
}

// 2. البانر التصميمي الأساسي
class ProductAdBanner extends StatelessWidget {
  final String title;
  final DateTime endDate;

  const ProductAdBanner({
    super.key,
    required this.title,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 220;

        final iconSize = compact ? 20.0 : 28.0;
        final titleFontSize = compact ? 8.0 : 11.0;
        final dateFontSize = compact ? 8.0 : 10.0;
        final badgeFontSize = compact ? 7.5 : 9.5;

        final horizontalPadding = compact ? 8.0 : 12.0;
        final verticalPadding = compact ? 4.0 : 7.0;

        final date =
            '${endDate.year}-'
            '${endDate.month.toString().padLeft(2, '0')}-'
            '${endDate.day.toString().padLeft(2, '0')}';

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF27D3A9),
                Color(0xFF04332A),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02231C).withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ArtisticWavesPainter(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: iconSize + 12,
                        height: iconSize + 12,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: iconSize + 8,
                              height: iconSize + 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF34D399).withOpacity(0.15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF34D399).withOpacity(0.25),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 1,
                              left: 3,
                              child: Icon(
                                Icons.auto_awesome,
                                color: const Color(0xFF6EE7B7),
                                size: compact ? 8 : 11,
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 3,
                              child: Icon(
                                Icons.auto_awesome,
                                color: const Color(0xFF6EE7B7),
                                size: compact ? 7 : 10,
                              ),
                            ),
                            Icon(
                              Icons.campaign_rounded,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: compact ? 2 : 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFFE2E8F0),
                                      fontSize: dateFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.access_time_rounded,
                                  color: const Color(0xFFE2E8F0),
                                  size: compact ? 10 : 13,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 10),
                      Stack(
                        alignment: Alignment.topRight,
                        clipBehavior: Clip.none,
                        children: [
                          ClipPath(
                            clipper: TagClipper(),
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: compact ? 45 : 65,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 6 : 9,
                                vertical: compact ? 6 : 8,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF86EFAC),
                                    Color(0xFF4ADE80),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Text(
                                'عرض',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF06332A),
                                  fontSize: badgeFontSize,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 3. الرسام الفني المصحح
class ArtisticWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFF047857).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.4, 0)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.4, 0, size.height * 0.7)
      ..close();

    final path2 = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.6, size.height)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.7, size.width, size.height * 0.2)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. مقص التاج المصحح
class TagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double cutWidth = 6.0;

    path.moveTo(cutWidth, 0);
    path.lineTo(size.width - cutWidth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - cutWidth, size.height);
    path.lineTo(cutWidth, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}