import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/widgets/ripple_0verlay.dart';
import 'package:smart_store/logic/voice/voice_assistant_cubit.dart';

class AiRippleManager {
  // نسخة واحدة للتموج يمكن التحكم بها من اي مكان
  static OverlayEntry? _rippleEntry;
  static VoiceAssistantCubit? _cubit;

  static bool get isOpen => _rippleEntry != null;

  static void toggleRipple(BuildContext context, {VoidCallback? onStateChanged}) {
    if (_rippleEntry != null) {
      closeRipple();
      return;
    }

    _cubit = context.read<VoiceAssistantCubit>();

    _rippleEntry = OverlayEntry(
      builder: (_) => ContinuousRippleOverlay(
        cubit: _cubit!,
        onClose: closeRipple,
      ),
    );

    Overlay.of(context).insert(_rippleEntry!);

    // بدء المحادثة الصوتية
    _cubit!.start();
    onStateChanged?.call();
  }

  // اغلاق التموج وانهاء المحادثة
  static void closeRipple() {
    if (_rippleEntry == null) return;
    _rippleEntry!.remove();
    _rippleEntry = null;
    _cubit?.stop();
    _cubit = null;
  }
}