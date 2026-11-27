import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// نتيجة جولة استماع واحدة
enum ListenResult { speech, silence, denied, error }

class VoiceListenOutput {
  final ListenResult result;
  final Uint8List? audio;
  final String mimeType;
  final Duration speechDuration;

  const VoiceListenOutput(
      this.result, [
        this.audio,
        this.mimeType = 'audio/wav',
        this.speechDuration = Duration.zero,
      ]);
}

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  // اعدادات كشف السكوت
  static const double _minSpeechDb = -45;
  static const double _aboveNoiseDb = 12;
  static const Duration _calibration = Duration(milliseconds: 400);
  static const Duration _minSpeech = Duration(milliseconds: 400);
  static const Duration _endOfSpeech = Duration(milliseconds: 1500);
  static const Duration _noSpeechTimeout = Duration(seconds: 40);
  static const Duration _maxDuration = Duration(seconds: 30);
  static const Duration _tick = Duration(milliseconds: 100);

  // اندرويد يسجل AAC اصغر بكثير، والباقي WAV
  static bool get _useAac =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static String get _mime => _useAac ? 'audio/mp4' : 'audio/wav';

  final StreamController<double> _levelController =
  StreamController<double>.broadcast();

  StreamSubscription<Amplitude>? _ampSub;
  Completer<VoiceListenOutput>? _completer;
  bool _isListening = false;

  // مدة الكلام الفعلية في الجولة الحالية
  Duration _speechDuration = Duration.zero;

  // مستوى الصوت من 0 الى 1 لرسم التموج
  Stream<double> get level => _levelController.stream;

  bool get isListening => _isListening;

  Future<bool> hasPermission() => _recorder.hasPermission();

  // يستمع حتى تنتهي الجملة او يمر وقت بدون كلام
  Future<VoiceListenOutput> listen() async {
    if (_isListening) await cancel();

    if (!await _recorder.hasPermission()) {
      return const VoiceListenOutput(ListenResult.denied);
    }

    try {
      await _recorder.start(
        RecordConfig(
          encoder: _useAac ? AudioEncoder.aacLc : AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 32000,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: await _tempPath(),
      );
    } catch (_) {
      return const VoiceListenOutput(ListenResult.error);
    }

    _isListening = true;
    _completer = Completer<VoiceListenOutput>();

    final DateTime startedAt = DateTime.now();
    DateTime? lastVoiceAt;
    DateTime? loudSince;
    DateTime? speechStartAt;
    bool heardSpeech = false;
    _speechDuration = Duration.zero;

    // قياس ضجيج الغرفة في البداية
    final List<double> noiseSamples = [];
    double threshold = _minSpeechDb;

    _ampSub = _recorder.onAmplitudeChanged(_tick).listen((amp) {
      final DateTime now = DateTime.now();
      final double db = amp.current.isFinite ? amp.current : -160;

      _levelController.add(_normalize(db));

      if (now.difference(startedAt) < _calibration) {
        noiseSamples.add(db);
        return;
      }
      if (noiseSamples.isNotEmpty) {
        final double noise =
            noiseSamples.reduce((a, b) => a + b) / noiseSamples.length;
        threshold = (noise + _aboveNoiseDb).clamp(_minSpeechDb, -20.0);
        noiseSamples.clear();
      }

      if (db > threshold) {
        // الكلام يجب ان يستمر فترة حتى لا تحسب دقة باب
        loudSince ??= now;
        if (now.difference(loudSince!) >= _minSpeech) {
          heardSpeech = true;
          speechStartAt ??= loudSince;
        }
        lastVoiceAt = now;
        if (speechStartAt != null) {
          _speechDuration = now.difference(speechStartAt!);
        }
      } else {
        loudSince = null;
      }

      // انتهت الجملة بعد سكوت قصير
      if (heardSpeech && now.difference(lastVoiceAt!) > _endOfSpeech) {
        _finish(ListenResult.speech);
        return;
      }

      // لم تتكلم العميلة ابدا
      if (!heardSpeech && now.difference(startedAt) > _noSpeechTimeout) {
        _finish(ListenResult.silence);
        return;
      }

      // كلام طويل جدا
      if (now.difference(startedAt) > _maxDuration) {
        _finish(heardSpeech ? ListenResult.speech : ListenResult.silence);
      }
    });

    return _completer!.future;
  }

  // ايقاف يدوي وارسال ما تم تسجيله
  Future<void> stopNow() => _finish(ListenResult.speech);

  // الغاء بدون ارسال
  Future<void> cancel() async {
    await _ampSub?.cancel();
    _ampSub = null;
    if (_isListening) {
      _isListening = false;
      await _recorder.cancel();
    }
    _levelController.add(0);
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(const VoiceListenOutput(ListenResult.silence));
    }
  }

  Future<void> _finish(ListenResult result) async {
    if (!_isListening) return;
    _isListening = false;

    await _ampSub?.cancel();
    _ampSub = null;
    _levelController.add(0);

    try {
      final String? path = await _recorder.stop();

      if (result != ListenResult.speech || path == null) {
        _complete(VoiceListenOutput(result));
        return;
      }

      // قراءة الملف تعمل على الجوال والويب
      final Uint8List bytes = await XFile(path).readAsBytes();
      _complete(
        VoiceListenOutput(ListenResult.speech, bytes, _mime, _speechDuration),
      );
    } catch (_) {
      _complete(const VoiceListenOutput(ListenResult.error));
    }
  }

  void _complete(VoiceListenOutput output) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(output);
    }
  }

  Future<String> _tempPath() async {
    if (kIsWeb) return '';
    final dir = await getTemporaryDirectory();
    final String ext = _useAac ? 'm4a' : 'wav';
    return '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }

  // تحويل الديسيبل الى قيمة بين 0 و 1
  double _normalize(double db) {
    if (db.isInfinite || db.isNaN) return 0;
    return ((db + 60) / 60).clamp(0.0, 1.0);
  }

  Future<void> dispose() async {
    await cancel();
    await _levelController.close();
    _recorder.dispose();
  }
}