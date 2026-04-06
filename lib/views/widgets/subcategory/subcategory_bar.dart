import 'package:flutter/material.dart';
import '../flash/flash_screen.dart';

class SubcategoryBar extends StatelessWidget {
  const SubcategoryBar({super.key});

  Future<List<Map<String, dynamic>>> getCategories() async {
    await Future.delayed(const Duration(seconds: 3));
    return List.generate(
      11,
          (index) => {
        "name": "فئة جديدة ${index + 1}",
        "image": "assets/images/a${index + 1}.jpg"
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SizedBox(
      height: (isDesktop)?null:85,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: getCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Flashsubcategory();
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            // السر هنا: في الكمبيوتر نخليه رأسي عشان ينزل سطر جديد، وفي الجوال أفقي
            scrollDirection: isDesktop ? Axis.vertical : Axis.horizontal,
            // تفعيل shrinkWrap لكي يأخذ الجريد مساحة عناصره فقط في الكمبيوتر
            shrinkWrap: isDesktop,
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // في الكمبيوتر: 13 عنصر في السطر | في الجوال: سطر واحد فقط
              crossAxisCount: isDesktop ? 13 : 1,
              mainAxisSpacing: 2,
              crossAxisSpacing: isDesktop?10:0,
              // التحكم في عرض/ارتفاع العنصر
              mainAxisExtent: isDesktop ? 110 : 70,
            ),
            itemBuilder: (context, index) {
              final item = categories[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"],
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item["name"],
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}


