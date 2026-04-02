
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
class SliderEds extends StatelessWidget {
  SliderEds({super.key});
  final List<String> imgList = [
    'assets/images/E3.jpg',
    'assets/images/a4.jpg',
    'assets/images/E.jpg',
    'assets/images/E2.jpg',
    'assets/images/a4.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 6),
          enlargeCenterPage: true,
          enlargeFactor: .15,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
          viewportFraction: 0.9,
        ),
        items: imgList
            .map(
              (item) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              item,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
