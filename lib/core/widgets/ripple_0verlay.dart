import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/icons/smart_robot_icon.dart';
import 'package:smart_store/core/widgets/voice/voice_products_strip.dart';
import 'package:smart_store/logic/voice/voice_assistant_cubit.dart';
import 'package:smart_store/logic/voice/voice_assistant_state.dart';

import '../theme/bloc/theme_bloc.dart';

class ContinuousRippleOverlay extends StatefulWidget {
  final VoiceAssistantCubit cubit;
  final VoidCallback onClose;

  const ContinuousRippleOverlay({
    super.key,
    required this.cubit,
    required this.onClose,
  });

  @override
  State<ContinuousRippleOverlay> createState() => _ContinuousRippleOverlayState();
}

class _ContinuousRippleOverlayState extends State<ContinuousRippleOverlay>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  StreamSubscription<double>? _levelSub;
  double _level = 0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // مستوى صوت العميلة لتكبير التموج
    _levelSub = widget.cubit.level.listen((v) {
      if (mounted) setState(() => _level = v);
    });
  }

  // ايقاف الميكروفون عند خروج التطبيق للخلفية
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _close();
    }
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    widget.onClose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _levelSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.sizeOf(context).height;

    return BlocConsumer<VoiceAssistantCubit, VoiceAssistantState>(
      bloc: widget.cubit,
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) async {
        // انتهت المحادثة
        if (state.status == VoiceStatus.idle) {
          if (state.errorKey != null) {
            await Future.delayed(const Duration(milliseconds: 2500));
          }
          if (mounted) _close();
        }
      },
      builder: (context, state) {
        // تصغير التموج عند وجود منتجات او شاشة قصيرة
        final bool compact = state.products.isNotEmpty || screenH < 700;
        final double rippleBox = compact ? 180 : 280;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // خلفية زجاجية مغبشة مع تعتيم خفيف
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // المحتوى
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: _buildRipples(state.status, rippleBox),
                          ),
                          const SizedBox(height: 12),
                          _StatusLabel(state: state),
                          const SizedBox(height: 16),
                          if (state.transcript.isNotEmpty)
                            _Bubble(text: state.transcript, isUser: true),
                          if (state.reply.isNotEmpty)
                            _Bubble(text: state.reply, isUser: false),
                          // منتجات الرد
                          if (state.products.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            VoiceProductsStrip(products: state.products),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            'voice_tap_robot_hint'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // زر الاغلاق
              SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: _GlassCloseButton(onTap: _close),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRipples(VoiceStatus status, double box) {
    // التموج يكبر مع صوت العميلة
    final double factor = switch (status) {
      VoiceStatus.listening => 1 + _level * 0.8,
      VoiceStatus.thinking => 0.75,
      _ => 1.0,
    };

    return SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _buildRipple(_controller.value, box * 0.9 * factor, box),
              _buildRipple((_controller.value + 0.5) % 1.0, box * 0.7 * factor, box),
              child!,
            ],
          );
        },
        // الضغط على الروبوت اثناء الكلام يوقفه
        child: AiRobotAvatar(
          iconSize: 35,
          padding: 15,
          onTap: widget.cubit.skipSpeaking,
        ),
      ),
    );
  }

  Widget _buildRipple(double value, double maxSize, double box) {
    final double size = (value * maxSize).clamp(0, box).toDouble();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(1 - value),
          width: 2,
        ),
        color: AppColors.primary.withOpacity((1 - value) * 0.15),
      ),
    );
  }
}

// زر اغلاق زجاجي
class _GlassCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'voice_close'.tr(),
      child: ClipOval(
        child: Material(
          color: context.read<ThemeBloc>().state.isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.5),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Icon(Icons.arrow_forward_ios_outlined, color: AppColors.primary, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// نص حالة المساعدة
class _StatusLabel extends StatelessWidget {
  final VoiceAssistantState state;

  const _StatusLabel({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isError = state.errorKey != null;

    final String key = isError
        ? state.errorKey!
        : switch (state.status) {
      VoiceStatus.listening => 'voice_listening',
      VoiceStatus.thinking => 'voice_thinking',
      VoiceStatus.speaking => 'voice_speaking',
      VoiceStatus.idle => 'voice_ended',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        key.tr(),
        key: ValueKey(key),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? AppColors.error : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// فقاعة كلام العميلة او رد المساعدة
class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    // اتجاه النص حسب لغة الكلام نفسه
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(text),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary.withOpacity(0.85)
              : AppColors.ContainerColor.withOpacity(0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          text,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}