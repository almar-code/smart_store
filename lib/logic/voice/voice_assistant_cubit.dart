import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/voice_reply_model.dart';
import '../../data/repos/voice_repo.dart';
import '../../data/services/voice_recorder_service.dart';
import 'voice_assistant_state.dart';

class VoiceAssistantCubit extends Cubit<VoiceAssistantState> {
  final VoiceRecorderService _recorder;
  final VoiceRepository _repo;
  final AudioPlayer _player = AudioPlayer();

  // كلام اطول من هذا ولم يفهم نخبر العميلة
  static const Duration _unclearSpeech = Duration(milliseconds: 1500);

  // يمنع استمرار الحلقة بعد الانهاء
  bool _sessionActive = false;

  VoiceAssistantCubit({
    VoiceRecorderService? recorder,
    VoiceRepository? repo,
  })  : _recorder = recorder ?? VoiceRecorderService(),
        _repo = repo ?? VoiceRepository(),
        super(const VoiceAssistantState());

  // مستوى الصوت لرسم التموج
  Stream<double> get level => _recorder.level;

  // بدء محادثة صوتية جديدة
  Future<void> start() async {
    if (_sessionActive) return;
    _sessionActive = true;
    emit(const VoiceAssistantState(status: VoiceStatus.listening));
    await _loop();
  }

  // حلقة: استماع ثم تفكير ثم كلام ثم استماع
  Future<void> _loop() async {
    while (_sessionActive) {
      emit(state.copyWith(status: VoiceStatus.listening, clearError: true));

      final VoiceListenOutput heard = await _recorder.listen();
      if (!_sessionActive) return;

      switch (heard.result) {
        case ListenResult.silence:
          await stop();
          return;
        case ListenResult.denied:
          await _endWithError('voice_permission_denied');
          return;
        case ListenResult.error:
          await _endWithError('voice_error_record');
          return;
        case ListenResult.speech:
          final bool ok = await _askAgent(heard);
          if (!ok) return;
      }
    }
  }

  // ارسال الصوت وتشغيل الرد
  Future<bool> _askAgent(VoiceListenOutput heard) async {
    emit(state.copyWith(status: VoiceStatus.thinking));

    final VoiceReplyModel reply;
    try {
      reply = await _repo.sendVoice(heard.audio!, mimeType: heard.mimeType);
    } catch (e) {
      debugPrint('VOICE network error: $e');
      await _endWithError('voice_error_network');
      return false;
    }

    if (!_sessionActive) return false;

    // لم يفهم الكلام
    if (reply.ignored) {
      if (heard.speechDuration >= _unclearSpeech) await _sayNotHeard();
      return _sessionActive;
    }

    emit(state.copyWith(
      status: VoiceStatus.speaking,
      transcript: reply.transcript,
      reply: reply.message,
      products: reply.similarProducts,
    ));

    // فشل تشغيل الصوت لا ينهي المحادثة
    if (reply.hasAudio) {
      try {
        await _playBytes(reply.audio!, reply.audioMime);
      } catch (e) {
        debugPrint('VOICE play error: $e');
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    return _sessionActive;
  }

  // جملة جاهزة محفوظة في التطبيق
  Future<void> _sayNotHeard() async {
    emit(state.copyWith(
      status: VoiceStatus.speaking,
      reply: 'voice_not_heard'.tr(),
      products: const [],
    ));
    try {
      await _playSource(AssetSource('audio/voice_not_heard.wav'));
    } catch (e) {
      debugPrint('VOICE asset error: $e');
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // تشغيل صوت الرد القادم من n8n
  Future<void> _playBytes(Uint8List bytes, String mime) async {
    final String ext = mime == 'audio/mpeg' ? 'mp3' : 'wav';

    final Source source;
    if (kIsWeb) {
      source = UrlSource(Uri.dataFromBytes(bytes, mimeType: mime).toString());
    } else {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/voice_reply_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await file.writeAsBytes(bytes, flush: true);
      source = DeviceFileSource(file.path);
    }
    await _playSource(source);
  }

  // تشغيل اي صوت والانتظار حتى ينتهي
  Future<void> _playSource(Source source) async {
    await _player.stop();

    final Completer<void> done = Completer<void>();
    final sub = _player.onPlayerComplete.listen((_) {
      if (!done.isCompleted) done.complete();
    });

    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(source);
      await done.future.timeout(const Duration(seconds: 60), onTimeout: () {});
    } finally {
      await sub.cancel();
    }
  }

  // ايقاف كلام المساعدة والعودة للاستماع
  Future<void> skipSpeaking() async {
    if (state.status == VoiceStatus.speaking) await _player.stop();
  }

  // انهاء المحادثة
  Future<void> stop() async {
    _sessionActive = false;
    await _recorder.cancel();
    await _player.stop();
    emit(state.copyWith(status: VoiceStatus.idle));
  }

  Future<void> _endWithError(String key) async {
    _sessionActive = false;
    await _recorder.cancel();
    await _player.stop();
    emit(state.copyWith(status: VoiceStatus.idle, errorKey: key));
  }

  @override
  Future<void> close() async {
    _sessionActive = false;
    await _recorder.dispose();
    await _player.dispose();
    return super.close();
  }
}