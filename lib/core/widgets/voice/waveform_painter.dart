import 'dart:math' as math;
import 'package:flutter/material.dart';

// رسم اعمدة الموجة الصوتية
class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double progress; // نسبة المشغل من 0 الى 1
  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final double gap;
  final bool live; // في التسجيل الحي تظهر اخر الاعمدة فقط
  final bool rtl; // رسم الموجة من اليمين لليسار

  WaveformPainter({
    required this.samples,
    required this.activeColor,
    required this.inactiveColor,
    this.progress = 1,
    this.barWidth = 3,
    this.gap = 2,
    this.live = false,
    this.rtl = false,
  });

  // تقليل العينات لعدد الاعمدة المطلوب
  static List<double> resample(List<double> data, int count) {
    if (data.isEmpty || count <= 0) return List.filled(math.max(count, 0), 0.05);
    if (data.length == count) return data;
    // التسجيل القصير: نمد العينات لتملأ العرض كاملا
    if (data.length < count) {
      if (data.length == 1) return List.filled(count, data.first);
      return List.generate(count, (i) {
        final t = i * (data.length - 1) / (count - 1);
        final a = t.floor();
        final b = math.min(a + 1, data.length - 1);
        return data[a] + (data[b] - data[a]) * (t - a);
      });
    }
    final step = data.length / count;
    return List.generate(count, (i) {
      final from = (i * step).floor();
      final to = math.min(((i + 1) * step).ceil(), data.length);
      return data.sublist(from, to).reduce(math.max);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final slot = barWidth + gap;
    final maxBars = (size.width / slot).floor();
    if (maxBars <= 0) return;

    final bars = live
        ? (samples.length > maxBars ? samples.sublist(samples.length - maxBars) : samples)
        : resample(samples, maxBars);

    final paint = Paint()..strokeCap = StrokeCap.round;
    final midY = size.height / 2;
    final startX = live ? size.width - bars.length * slot : 0.0;

    for (var i = 0; i < bars.length; i++) {
      final h = math.max(3.0, bars[i].clamp(0.0, 1.0) * size.height);
      final ltrX = startX + i * slot;
      final x = rtl ? size.width - ltrX - barWidth : ltrX;
      final played = bars.isEmpty ? false : (i + 0.5) / bars.length <= progress;
      paint.color = played ? activeColor : inactiveColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, midY - h / 2, barWidth, h),
          Radius.circular(barWidth),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter old) =>
      old.samples.length != samples.length ||
      old.progress != progress ||
      old.activeColor != activeColor ||
      old.inactiveColor != inactiveColor ||
      old.rtl != rtl;
}
