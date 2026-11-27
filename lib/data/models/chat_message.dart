import 'dart:typed_data';

class ChatMessage {
  final String id;
  final String? text;
  final Uint8List? imagePath;
  final bool isMe;
  final bool isImage;
  final List<dynamic>? similarProducts; // حقل جديد لمصفوفة المنتجات

  // حقول الرسالة الصوتية
  final Uint8List? audioBytes;
  final String? audioMime;
  final String? audioPath;
  final Duration? audioDuration;
  final List<double>? waveform;

  ChatMessage({
    String? id,
    this.text,
    this.imagePath,
    required this.isMe,
    this.isImage = false,
    this.similarProducts,
    this.audioBytes,
    this.audioMime,
    this.audioPath,
    this.audioDuration,
    this.waveform,
  }) : id = id ?? _nextId();

  bool get isVoice => audioBytes != null || audioPath != null;

  // معرف فريد لكل رسالة
  static int _counter = 0;
  static String _nextId() => '${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
}
