import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../flash/flash_screen.dart';

class SubcategoryBar extends StatelessWidget {
  const SubcategoryBar({super.key});

  Future<List<Map<String, dynamic>>> getCategories() async {
    await Future.delayed(const Duration(seconds: 3));
    return List.generate(
      11,
          (index) => {
        "name": " جديدة${index + 1}",
        "image": "assets/images/${index}.jpg"
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Flashsubcategory();
        }
        int rowCount =(categories.length > 30) ? 2 : 1;
        double height =(categories.length > 30) ? 180 : 83;
        return SizedBox(
          height: isDesktop ? height : 70, // مهم جدًا
          child:GridView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(top: 2),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? rowCount : 1, // صفين في اللابتوب - صف في الجوال
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: isDesktop ? 80 : 55, // عرض العنصر
            ),
            itemBuilder: (context, index) {
              final item = categories[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      (index < 10) ? item["image"] :"assets/images/a4.jpg",
                      width: isDesktop ? 55 : 45,
                      height: isDesktop ? 55 : 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item["name"],
                      maxLines: 2,
                      style:  TextStyle(
                        fontSize:  isDesktop ? 11 : 9,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}


