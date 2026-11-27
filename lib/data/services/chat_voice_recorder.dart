import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// مسجل رسائل الدردشة الصوتية
class ChatVoiceRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;

  // الويب يسجل wav والجوال m4a
  String get mimeType => kIsWeb ? 'audio/wav' : 'audio/mp4';

  Future<bool> hasPermission() => _recorder.hasPermission();

  // بدء التسجيل مع بث مستوى الصوت
  Future<void> start({required void Function(double level) onLevel}) async {
    String path = '';
    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      path = '${dir.path}/chat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }

    final config = RecordConfig(
      encoder: kIsWeb ? AudioEncoder.wav : AudioEncoder.aacLc,
      sampleRate: 16000,
      bitRate: 32000,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
    );

    await _recorder.start(config, path: path);

    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((a) => onLevel(_normalize(a.current)));
  }

  // ايقاف التسجيل وقراءة البايتات
  Future<({Uint8List bytes, String? path})?> stop() async {
    await _ampSub?.cancel();
    _ampSub = null;
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) return null;
    final bytes = await XFile(path).readAsBytes();
    return (bytes: bytes, path: kIsWeb ? null : path);
  }

  // الغاء التسجيل وحذف الملف
  Future<void> cancel() async {
    await _ampSub?.cancel();
    _ampSub = null;
    await _recorder.cancel();
  }

  Future<void> dispose() async {
    await _ampSub?.cancel();
    await _recorder.dispose();
  }

  // تحويل الديسيبل الى قيمة بين 0 و 1
  double _normalize(double db) {
    if (db.isNaN || db.isInfinite) return 0.05;
    return ((db + 50) / 50).clamp(0.05, 1.0);
  }
}
