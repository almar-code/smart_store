import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// نسخة الويب: عنصر <img> حقيقي داخل الصفحة، فيدعم السحب الأصلي للمتصفح
/// (Flutter يرسم صوره على Canvas فلا يمكن سحبها، لذلك نستخدم عنصر HTML)
Widget buildDraggableImage({
  required String imageUrl,
  required double size,
  required String tooltip,
}) {
  return SizedBox(
    width: size,
    height: size,
    child: HtmlElementView.fromTagName(
      key: ValueKey(imageUrl),
      tagName: 'img',
      onElementCreated: (Object element) {
        final img = element as web.HTMLImageElement;
        img
          ..src = imageUrl
          ..draggable = true
          ..title = tooltip
          ..alt = tooltip;
        img.style
          ..width = '100%'
          ..height = '100%'
          ..objectFit = 'cover'
          ..borderRadius = '50%'
          ..cursor = 'grab'
          ..display = 'block';
      },
    ),
  );
}
