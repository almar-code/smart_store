import 'package:flutter/widgets.dart';

/// نسخة الجوال: لا يوجد سحب HTML، فلا نعرض شيئاً
Widget buildDraggableImage({
  required String imageUrl,
  required double size,
  required String tooltip,
}) =>
    const SizedBox.shrink();
