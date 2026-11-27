import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/wav_waveform.dart';
import '../../../core/widgets/customer_photo.dart';
import '../../../core/widgets/icons/smart_robot_icon.dart';
import '../../../core/widgets/voice/waveform_painter.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/voice_recording.dart';
import '../../../data/services/chat_voice_player.dart';

// فقاعة رسالة صوتية مثل واتساب
// البوت: صورة ثم تشغيل ثم موجة من اليسار
// العميل: نفس الترتيب معكوسا من اليمين
class VoiceMessageBubble extends StatefulWidget {
  final ChatMessage message;
  const VoiceMessageBubble({super.key, required this.message});

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _player = ChatVoicePlayer.instance;
  late List<double> _samples;
  late Duration _total;
  bool _showText = false;

  // عرض الصورة وزر التشغيل لمحاذاة سطر المدة تحت الموجة
  static const double _sideSize = 36;
  static const double _playSize = 36;
  static const double _gap = 6;

  ChatMessage get m => widget.message;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  // تجهيز الموجة والمدة مرة واحدة
  void _prepare() {
    final wav = (m.waveform == null || m.audioDuration == null) && m.audioBytes != null
        ? WavWaveform.parse(m.audioBytes!)
        : null;
    _samples = (m.waveform != null && m.waveform!.isNotEmpty)
        ? m.waveform!
        : wav?.samples ?? List.generate(40, (i) => 0.25 + 0.2 * math.sin(i * 0.7).abs());
    _total = m.audioDuration ?? wav?.duration ?? Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final width = math.min(280.0, MediaQuery.of(context).size.width * 0.68);
    final hasText = m.text?.trim().isNotEmpty ?? false;
    final isMe = m.isMe;

    // الوان الموجة حسب صاحب الرسالة
    final playedColor = isMe ? Colors.black87 : AppColors.primary;
    final restColor = isMe ? Colors.white.withOpacity(0.65) : AppColors.textColor.withOpacity(0.3);
    final iconColor = isMe ? Colors.white : AppColors.primary;
    final metaColor = isMe ? Colors.white.withOpacity(0.85) : AppColors.textSecondary;

    return AnimatedBuilder(
      animation: _player.listenable,
      builder: (context, _) {
        final active = _player.activeId.value == m.id;
        final playingNow = active && _player.playing.value;
        final total = active && _player.duration.value > Duration.zero ? _player.duration.value : _total;
        final pos = active ? _player.position.value : Duration.zero;
        final progress = total.inMilliseconds > 0 ? (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0) : 0.0;

        // زر التشغيل
        final playButton = GestureDetector(
          onTap: () => _player.toggle(m, total: _total),
          child: SizedBox(
            width: _playSize,
            height: _playSize,
            child: Icon(
              playingNow ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 34,
              color: iconColor,
            ),
          ),
        );

        // الموجة مع اللمس والسحب للتقديم
        final wave = Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              void seekAt(double dx) {
                final f = dx / c.maxWidth;
                _player.seek(m, isMe ? 1 - f : f, total: _total);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => seekAt(d.localPosition.dx),
                onHorizontalDragUpdate: (d) => seekAt(d.localPosition.dx),
                child: CustomPaint(
                  size: Size(c.maxWidth, 30),
                  painter: WaveformPainter(
                    samples: _samples,
                    progress: progress,
                    activeColor: playedColor,
                    inactiveColor: restColor,
                    barWidth: 2.5,
                    gap: 2,
                    rtl: isMe,
                  ),
                ),
              );
            },
          ),
        );

        // الصورة او زر السرعة اثناء التشغيل
        final side = SizedBox(
          width: _sideSize,
          height: _sideSize,
          child: Center(
            child: active
                ? _SpeedChip(rate: _player.rate.value, isMe: isMe, onTap: _player.cycleRate)
                : isMe
                ? const CustomerPhoto(radius: 18)
                : const AiRobotAvatar(padding: 7, iconSize: 20),
          ),
        );

        // المدة
        final time = Text(
          formatVoiceDuration(active && pos > Duration.zero ? pos : total),
          style: TextStyle(
            fontSize: 11,
            color: metaColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );

        // زر عرض النص مقابل المدة
        final textToggle = hasText
            ? GestureDetector(
          onTap: () => setState(() => _showText = !_showText),
          child: Text(
            _showText ? tr('voice_hide_text') : tr('voice_show_text'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isMe ? Colors.white : AppColors.primary,
            ),
          ),
        )
            : const SizedBox();

        // ازاحة سطر المدة ليبدأ تحت الموجة
        const indent = _sideSize + _gap + _playSize + 2;

        return SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصف الرئيسي في منتصف واحد
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: isMe
                    ? [wave, const SizedBox(width: 2), playButton, const SizedBox(width: _gap), side]
                    : [side, const SizedBox(width: _gap), playButton, const SizedBox(width: 2), wave],
              ),
              const SizedBox(height: 2),

              // المدة وعرض النص في سطر واحد تحت الموجة
              Padding(
                padding: isMe ? const EdgeInsets.only(right: indent) : const EdgeInsets.only(left: indent),
                child: Row(
                  children: isMe ? [textToggle, const Spacer(), time] : [time, const Spacer(), textToggle],
                ),
              ),

              // النص عند الطلب
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _showText && hasText
                    ? Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Text(
                    m.text!,
                    textDirection: _isArabic(m.text!) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    style: TextStyle(color: AppColors.textColor, fontSize: 13.5, height: 1.8),
                  ),
                )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isArabic(String s) => RegExp(r'[؀-ۿ]').hasMatch(s);
}

// زر سرعة التشغيل
class _SpeedChip extends StatelessWidget {
  final double rate;
  final bool isMe;
  final VoidCallback onTap;

  const _SpeedChip({required this.rate, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = rate == 1 ? '1x' : rate == 1.5 ? '1.5x' : '2x';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMe ? Colors.black.withOpacity(0.18) : AppColors.primary.withOpacity(0.15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isMe ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
