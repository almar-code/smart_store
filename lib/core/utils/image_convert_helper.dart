import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageConvertHelper {
  // تحويل الصورة المختارة الى JPG خفيف يعمل في الويب والجوال
  static Future<Uint8List?> toJpg(XFile file, {int maxSize = 1024}) async {
    final bytes = await file.readAsBytes();
    return compute(_convert, _Args(bytes, maxSize));
  }

  static Uint8List? _convert(_Args args) {
    final decoded = img.decodeImage(args.bytes);
    if (decoded == null) return null;

    // تعديل الاتجاه حسب الكاميرا
    var image = img.bakeOrientation(decoded);

    // تصغير الصورة الكبيرة
    if (image.width > args.maxSize || image.height > args.maxSize) {
      image = image.width >= image.height
          ? img.copyResize(image, width: args.maxSize)
          : img.copyResize(image, height: args.maxSize);
    }

    return img.encodeJpg(image, quality: 85);
  }
}

class _Args {
  final Uint8List bytes;
  final int maxSize;
  _Args(this.bytes, this.maxSize);
}
