import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/add_to_cart_button.dart';


class ProductImageSlider extends StatelessWidget {
  final List<String> images;
  const ProductImageSlider({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        spacing: 8,
        children: images.map((path) => Container(
          width: 140, height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(path),
              fit: BoxFit.cover,
            ),
          ),
        )).toList(),
      ),
    );
  }
}


class ProductImageGallery extends StatefulWidget {
  final List<String> images;

  const ProductImageGallery({super.key, required this.images});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        // الصورة الرئيسية الكبيرة
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(widget.images[selectedIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedIndex == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : null,
                    image: DecorationImage(
                      image: AssetImage(widget.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class ProductColorSelector extends StatelessWidget {
  final List<Map<String, String>> colors;
  const ProductColorSelector({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 10, runSpacing: 10,
        alignment: WrapAlignment.start,
        children: colors.map((color) => Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.hexToColor(color["code"]!),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: AppColors.hexToColor(color["code"]!)),
          ),
          child: CircleAvatar(
            radius: 10,
            child: ClipOval(
              child: Image.asset(
                color['imagePath']!,
                width: 20, height: 20,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}



class ProductSizeSelector extends StatelessWidget {
  final List<String> sizes;
  const ProductSizeSelector({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 10, runSpacing: 10,
        alignment: WrapAlignment.start,
        children: sizes.map((size) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(5),
            boxShadow: AppShadow.commonShadow,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Text(
            size,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
        )).toList(),
      ),
    );
  }
}



class ProductActionActions extends StatelessWidget {
  const ProductActionActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.textSecondary)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(5),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(CupertinoIcons.heart, color: AppColors.textSecondary, size: 23),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: AddToCartButton()),
        ],
      ),
    );
  }
}
