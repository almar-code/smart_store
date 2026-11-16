import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:smart_store/core/widgets/circularProgress.dart';
import '../../constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../constants/app_endpoints.dart';
import '../../di/injection_container.dart' as di;
import '../../../data/repos/product_repo.dart';

// منطق المشاركة للزر ولقائمة الخيارات
class ProductShareHelper {
  // تحميل صورة المنتج مؤقتا
  static Future<String?> _downloadImage(ProductModel product) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/product_${product.pId}.png');
      if (await file.exists() && await file.length() > 0) return file.path;

      final response = await http
          .get(Uri.parse(ApiEndpoints.productImageUrl(product.pImage)))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> share(BuildContext context, ProductModel product) async {
    // تسجيل المشاركة في الاحصائيات
    di.sl<ProductRepo>().recordProductShare(productId: product.pId);

    final box = context.findRenderObject() as RenderBox?;
    final Rect? origin = (box != null && box.hasSize) ? box.localToGlobal(Offset.zero) & box.size : null;

    final String link = "https://smartstore.com/product?id=${product.pId}";
    final String message =
        "Nice Store : Abaya Store\n"
        "${product.pNameEn}"
        ": ${product.pName} \n\n"
        " اضغط على الرابط لتصفح المنتج:\n"
        " \n\t $link";

    final imagePath = await _downloadImage(product);

    if (imagePath != null) {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: message,
        subject: 'مشاركة منتج من Nice Store',
        sharePositionOrigin: origin,
      );
    } else {
      await Share.share(message, subject: 'مشاركة منتج من Nice Store', sharePositionOrigin: origin);
    }
  }
}

class ShareButton extends StatefulWidget {
  final ProductModel product;

  const ShareButton({super.key, required this.product});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  // منع تكرار الضغط
  bool _isSharing = false;

  Future<void> _shareProduct() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await ProductShareHelper.share(context, widget.product);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isSharing ? null : _shareProduct,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundSecondary,
        ),
        child: Center(
          child: _isSharing
              ? SizedBox(
            width: 12,
            height: 12,
            child: CircularProgress(size: 15, color: AppColors.primary),
          )
              : Icon(Icons.share_outlined, color: AppColors.iconColor, size: 14),
        ),
      ),
    );
  }
}