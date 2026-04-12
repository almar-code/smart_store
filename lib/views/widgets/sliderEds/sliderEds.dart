import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../flash/flash_screen.dart'; // تأكد من إضافة المكتبة

class SliderEds extends StatefulWidget {
  final List<String> images;
   SliderEds({super.key,required this.images});

  @override
  State<SliderEds> createState() => _SliderEdsState();
}

class _SliderEdsState extends State<SliderEds> {
  bool _isLoading = true; // حالة التحميل
  @override
  void initState() {
    super.initState();
    // مؤقت لمدة 5 ثوانٍ للوميض
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    // إذا كان في حالة تحميل، نعرض مربعاً يلمع بنفس أبعاد السلايدر
    if (_isLoading) {
      return Flasheds();
    }

    // الكود الأصلي الخاص بك يظهر بعد 5 ثوانٍ
    return SizedBox(
      child: CarouselSlider(
        options: CarouselOptions(
          height: isDesktop ? 185 : 160,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          enlargeCenterPage: true,
          enlargeFactor: .15,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
          viewportFraction: 0.9,
        ),
        items:  widget.images
            .map(
              (item) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              item,
              fit: BoxFit.fill,
              width: double.infinity,
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}