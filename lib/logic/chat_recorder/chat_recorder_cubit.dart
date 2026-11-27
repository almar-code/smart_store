import 'dart:async';
import 'dart:ui' show Offset;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/voice_recording.dart';
import '../../data/services/chat_voice_recorder.dart';
import 'chat_recorder_state.dart';

// حدث يخرج من المسجل للشاشة
class RecorderEvent {
  final VoiceRecording? recording;
  final String? messageKey;
  const RecorderEvent({this.recording, this.messageKey});
}

class ChatRecorderCubit extends Cubit<ChatRecorderState> {
  ChatRecorderCubit() : super(const ChatRecorderState());

  final ChatVoiceRecorder _recorder = ChatVoiceRecorder();
  final _events = StreamController<RecorderEvent>.broadcast();
  final Stopwatch _watch = Stopwatch();
  final List<double> _samples = [];
  Future<bool>? _starting;

  static const double _cancelDistance = 110;
  static const double _lockDistance = 80;
  static const Duration _minDuration = Duration(seconds: 1);
  static const Duration _maxDuration = Duration(minutes: 2);

  Stream<RecorderEvent> get events => _events.stream;

  // بدء التسجيل عند الضغط المطول
  Future<void> start() async {
    if (state.isActive) return;
    _starting = _doStart();
    await _starting;
  }

  Future<bool> _doStart() async {
    if (!await _recorder.hasPermission()) {
      _events.add(const RecorderEvent(messageKey: 'voice_permission_denied'));
      return false;
    }
    _samples.clear();
    _watch
      ..reset()
      ..start();
    emit(const ChatRecorderState(phase: RecorderPhase.recording));
    HapticFeedback.mediumImpact();

    try {
      await _recorder.start(onLevel: _onLevel);
      return true;
    } catch (_) {
      _reset();
      _events.add(const RecorderEvent(messageKey: 'voice_error_record'));
      return false;
    }
  }

  void _onLevel(double level) {
    if (!state.isActive) return;
    _samples.add(level);
    emit(state.copyWith(elapsed: _watch.elapsed, samples: List.of(_samples)));
    if (_watch.elapsed >= _maxDuration) finish();
  }

  // تحريك الاصبع اثناء التسجيل
  void drag(Offset offset, {required bool rtl}) {
    if (state.phase != RecorderPhase.recording) return;
    final towardStart = rtl ? offset.dx : -offset.dx;
    final up = -offset.dy;

    if (towardStart > _cancelDistance) {
      cancel();
      return;
    }
    if (up > _lockDistance) {
      lock();
      return;
    }
    emit(state.copyWith(
      slide: (towardStart / _cancelDistance).clamp(0.0, 1.0),
      lift: (up / _lockDistance).clamp(0.0, 1.0),
    ));
  }

  // رفع الاصبع
  Future<void> release() async {
    if (state.phase == RecorderPhase.recording) await finish();
  }

  // قفل التسجيل ليستمر بدون ضغط
  void lock() {
    if (state.phase != RecorderPhase.recording) return;
    HapticFeedback.selectionClick();
    emit(state.copyWith(phase: RecorderPhase.locked, slide: 0, lift: 0));
  }

  // الغاء التسجيل
  Future<void> cancel() async {
    if (_starting != null) await _starting;
    if (!state.isActive) return;
    HapticFeedback.heavyImpact();
    _reset();
    await _recorder.cancel();
  }

  // انهاء التسجيل وتجهيزه للارسال
  Future<void> finish() async {
    if (_starting != null && !await _starting!) return;
    if (!state.isActive) return;
    final duration = _watch.elapsed;
    final samples = List<double>.of(_samples);
    _reset();

    if (duration < _minDuration) {
      await _recorder.cancel();
      _events.add(const RecorderEvent(messageKey: 'voice_too_short'));
      return;
    }

    try {
      final result = await _recorder.stop();
      if (result == null) throw Exception('empty');
      _events.add(RecorderEvent(
        recording: VoiceRecording(
          bytes: result.bytes,
          mimeType: _recorder.mimeType,
          duration: duration,
          samples: samples,
          localPath: result.path,
        ),
      ));
    } catch (_) {
      _events.add(const RecorderEvent(messageKey: 'voice_error_record'));
    }
  }

  void _reset() {
    _watch.stop();
    _starting = null;
    emit(const ChatRecorderState());
  }

  @override
  Future<void> close() async {
    if (state.isActive) await _recorder.cancel();
    await _recorder.dispose();
    await _events.close();
    return super.close();
  }
}
