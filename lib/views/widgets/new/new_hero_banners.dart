import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_shadow.dart';

// صور الواجهة اعلى صفحة الجديد
class NewHeroBanners extends StatelessWidget {
  const NewHeroBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1000;
    final isIpad = width > 450 && width <= 1000;

    // الشاشات الكبيرة تعرض ثلاث صور
    final images = isDesktop
        ? ['new_phon_ar_6.png', 'new_phon_ar_4.png', 'new_phon_ar_3.png']
        : ['new_phon_ar_6.png', 'new_phon_ar_4.png'];
    final height = isDesktop ? 200.0 : isIpad ? 160.0 : 115.0;

    return Row(
      children: [
        for (var i = 0; i < images.length; i++) ...[
          Expanded(
            child: NewBanner(image: images[i], height: height)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 80 * i), duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          ),
          if (i != images.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

// صورة واحدة بحواف دائرية
class NewBanner extends StatelessWidget {
  final String image;
  final double height;
  const NewBanner({super.key, required this.image, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadow.commonShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/$image', fit: BoxFit.cover),
          // تدرج خفيف يعطي عمقا
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.18)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}