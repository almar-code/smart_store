import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/voice/waveform_painter.dart';
import '../../../data/models/voice_recording.dart';
import '../../../logic/chat_recorder/chat_recorder_state.dart';

// شريط التسجيل الذي يحل محل حقل الكتابة
class ChatRecordingBar extends StatelessWidget {
  final ChatRecorderState state;
  final VoidCallback onCancel;

  const ChatRecordingBar({super.key, required this.state, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final locked = state.phase == RecorderPhase.locked;

    return Container(
      height: 48,
      padding: const EdgeInsetsDirectional.only(start: 6, end: 56),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          // زر الحذف يظهر بعد القفل
          if (locked)
            IconButton(
              tooltip: tr('voice_delete_recording'),
              icon: Icon(CupertinoIcons.trash, color: AppColors.redColor, size: 20),
              onPressed: onCancel,
            )
          else
            const SizedBox(width: 8),

          // نقطة حمراء نابضة
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: AppColors.redColor, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 1, end: 0.25, duration: const Duration(milliseconds: 600)),
          const SizedBox(width: 6),

          // مؤقت التسجيل
          Text(
            formatVoiceDuration(state.elapsed),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),

          // الموجة الحية
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: CustomPaint(
                size: const Size(double.infinity, 26),
                painter: WaveformPainter(
                  samples: state.samples,
                  live: true,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary,
                  barWidth: 2.5,
                  gap: 2,
                ),
              ),
            ),
          ),

          // تلميح السحب للالغاء
          if (!locked) _SlideHint(progress: state.slide),
        ],
      ),
    );
  }
}

// نص اسحب للالغاء يتحرك مع الاصبع
class _SlideHint extends StatelessWidget {
  final double progress;
  const _SlideHint({required this.progress});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == ui.TextDirection.rtl;
    final shift = progress * 40 * (rtl ? 1 : -1);

    return Transform.translate(
      offset: Offset(shift, 0),
      child: Opacity(
        opacity: (1 - progress).clamp(0.2, 1.0),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                tr('voice_slide_to_cancel'),
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// مؤشر القفل فوق زر الميكروفون
class RecordingLockHint extends StatelessWidget {
  final double progress;
  final bool visible;

  const RecordingLockHint({super.key, required this.progress, required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Transform.translate(
          offset: Offset(0, -progress * 18),
          child: Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  progress > 0.6 ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open,
                  size: 17,
                  color: Color.lerp(AppColors.textSecondary, AppColors.primary, progress),
                ),
                const SizedBox(height: 6),
                Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
