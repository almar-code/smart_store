import 'dart:typed_data';

// تسجيل صوتي جاهز للإرسال
class VoiceRecording {
  final Uint8List bytes;
  final String mimeType;
  final Duration duration;
  final List<double> samples; // ارتفاعات الموجة بين 0 و 1
  final String? localPath;

  const VoiceRecording({
    required this.bytes,
    required this.mimeType,
    required this.duration,
    required this.samples,
    this.localPath,
  });
}

// تنسيق المدة بشكل 0:07
String formatVoiceDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
