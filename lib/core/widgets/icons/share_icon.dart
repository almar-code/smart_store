import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http; // أو استخدم الـ Dio الخاص بمشروعك
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../constants/app_endpoints.dart';

class ShareButton extends StatelessWidget {
  final ProductModel product;

  const ShareButton({super.key, required this.product});

  // 🌟 دالة ذكية لتحميل الصورة وتحويلها لملف مؤقت قابل للمشاركة
  Future<String?> _downloadProductImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // الوصول إلى مجلد الكاش المؤقت في الهاتف
        final documentDirectory = await getTemporaryDirectory();
        // تسمية الملف باسم فريد يعتمد على الـ ID لمنع تداخل الكاش
        final file = File('${documentDirectory.path}/product_${product.pId}.png');
        // كتابة البايتات داخل الملف
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print("خطأ أثناء جلب صورة المنتج للمشاركة: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final RenderBox? box = context.findRenderObject() as RenderBox?;

        // 1. بناء رابط الويب وصياغة الرسالة التسويقية
        final String productLink = "https://smartstore.com/product?id=${product.pId}";
        final String shareMessage =
        "Nice Store : Abaya Store\n"
        "${product.pNameEn}"
            ": ${product.pName} \n\n"
            " اضغط على الرابط لتصفح المنتج:\n"
            " \n\t $productLink";

        // 2. صياغة رابط الصورة الكامل القادم من السيرفر لارافيل
        final String fullImageUrl =  ApiEndpoints.productImageUrl(product.pImage);

        // إظهار مؤشر تحميل صغير كواليسياً إن أردت، أو البدء بالتحميل فوراً
        final String? localImagePath = await _downloadProductImage(fullImageUrl);

        if (localImagePath != null) {
          // 🚀 3. مشاركة الصورة + النص معاً بنجاح
          await Share.shareXFiles(
            [XFile(localImagePath)],
            text: shareMessage,
            subject: 'مشاركة منتج من Nice Store',
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          );
        } else {
          // خطة بديلة (Fallback): إذا فشل تحميل الصورة لسبب ما في شبكة العميل، شارك النص والرابط فقط
          Share.share(
            shareMessage,
            subject: 'مشاركة منتج من Nice Store',
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          );
        }
      },
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundSecondary,
        ),
        child: Center(
          child: Icon(
            Icons.share_outlined,
            color: AppColors.iconColor,
            size: 14,
          ),
        ),
      ),
    );
  }
}