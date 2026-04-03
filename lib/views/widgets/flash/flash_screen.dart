import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class Flasheds extends StatelessWidget {
  const Flasheds({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}



class Flashsubcategory extends StatelessWidget {
  const Flashsubcategory({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child:SizedBox(
        height: (isDesktop)?200:88,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:  (isDesktop)?2:1,
            // تقسيم عرض الشاشة على 13 لكي تظهر جميعها في سطر واحد
            mainAxisExtent: (isDesktop)? MediaQuery.of(context).size.width / 13:70,
            // mainAxisExtent: 70,
            mainAxisSpacing: 2,
            crossAxisSpacing:  (isDesktop)?10:0,
          ),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
