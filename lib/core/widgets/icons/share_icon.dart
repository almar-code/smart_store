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

class ShareButton extends StatefulWidget {
  final ProductModel product;

  const ShareButton({super.key, required this.product});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  // 🔒 قفل يمنع تكرار الضغط أثناء تجهيز المشاركة
  bool _isSharing = false;

  // 🌟 تحميل صورة المنتج كملف مؤقت (مع إعادة استخدامها إن كانت محمّلة سابقاً)
  Future<String?> _downloadProductImage(String imageUrl) async {
    try {
      final tempDirectory = await getTemporaryDirectory();
      final file = File('${tempDirectory.path}/product_${widget.product.pId}.png');

      // ⚡ إذا كانت الصورة محمّلة من مشاركة سابقة نستخدمها مباشرة بدون تحميل
      if (await file.exists() && await file.length() > 0) {
        return file.path;
      }

      // ⏱️ حد أقصى 6 ثوانٍ للتحميل، بعدها نشارك النص فقط
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print("خطأ أثناء جلب صورة المنتج للمشاركة: $e");
    }
    return null;
  }

  Future<void> _shareProduct() async {
    // 🔒 تجاهل أي ضغطة إضافية أثناء تنفيذ المشاركة الحالية
    if (_isSharing) return;
    setState(() => _isSharing = true);

    // 📊 تسجيل المشاركة في الإحصائيات مرة واحدة فقط (في الخلفية)
    di.sl<ProductRepo>().recordProductShare(productId: widget.product.pId);

    try {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect? origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // 1. بناء رابط الويب وصياغة الرسالة التسويقية
      final String productLink = "https://smartstore.com/product?id=${widget.product.pId}";
      final String shareMessage =
          "Nice Store : Abaya Store\n"
          "${widget.product.pNameEn}"
          ": ${widget.product.pName} \n\n"
          " اضغط على الرابط لتصفح المنتج:\n"
          " \n\t $productLink";

      // 2. صياغة رابط الصورة الكامل القادم من سيرفر لارافيل
      final String fullImageUrl = ApiEndpoints.productImageUrl(widget.product.pImage);
      final String? localImagePath = await _downloadProductImage(fullImageUrl);

      if (localImagePath != null) {
        // 🚀 3. مشاركة الصورة + النص معاً
        await Share.shareXFiles(
          [XFile(localImagePath)],
          text: shareMessage,
          subject: 'مشاركة منتج من Nice Store',
          sharePositionOrigin: origin,
        );
      } else {
        // خطة بديلة: إذا فشل تحميل الصورة نشارك النص والرابط فقط
        await Share.share(
          shareMessage,
          subject: 'مشاركة منتج من Nice Store',
          sharePositionOrigin: origin,
        );
      }
    } finally {
      // 🔓 فتح القفل بعد انتهاء العملية (نجحت أو فشلت)
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
          // ⏳ مؤشر تحميل صغير بنفس لون الأيقونة أثناء تجهيز المشاركة
          child: _isSharing
              ? SizedBox(
            width: 12,
            height: 12,
            child: CircularProgress(
              size: 15,
              color: AppColors.primary,
            ),
          )
              : Icon(
            Icons.share_outlined,
            color: AppColors.iconColor,
            size: 14,
          ),
        ),
      ),
    );
  }
}