import 'dart:convert';
import 'dart:typed_data';

// رد المساعد الصوتي القادم من n8n
class VoiceReplyModel {
  final String transcript;
  final String message;
  final List<dynamic> similarProducts;
  final Uint8List? audio;
  final String audioMime;
  final bool ignored;

  const VoiceReplyModel({
    required this.transcript,
    required this.message,
    required this.similarProducts,
    this.audio,
    this.audioMime = 'audio/wav',
    this.ignored = false,
  });

  bool get hasAudio => audio != null && audio!.isNotEmpty;

  factory VoiceReplyModel.fromJson(Map<String, dynamic> json) {
    final String audioB64 = json['audio']?.toString() ?? '';

    return VoiceReplyModel(
      transcript: json['transcript']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      similarProducts: json['similar_products'] is List
          ? json['similar_products'] as List<dynamic>
          : <dynamic>[],
      audio: audioB64.isEmpty ? null : base64Decode(audioB64),
      audioMime: json['audio_mime']?.toString() ?? 'audio/wav',
      ignored: json['ignored'] == true,
    );
  }
}