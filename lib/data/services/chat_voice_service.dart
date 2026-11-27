import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../../core/constants/app_endpoints.dart';
import '../models/voice_recording.dart';

// رد الوكيل على الرسالة الصوتية
class ChatVoiceReply {
  final String transcript;
  final String message;
  final List<dynamic> products;
  final Uint8List? audio;
  final String audioMime;
  final bool ignored;

  const ChatVoiceReply({
    this.transcript = '',
    this.message = '',
    this.products = const [],
    this.audio,
    this.audioMime = 'audio/wav',
    this.ignored = false,
  });

  factory ChatVoiceReply.fromJson(Map data) {
    final raw = data['audio'];
    Uint8List? audio;
    if (raw is String && raw.isNotEmpty) {
      // ازالة بادئة data uri ان وجدت
      final clean = raw.contains(',') ? raw.split(',').last : raw;
      audio = base64Decode(clean);
    }
    return ChatVoiceReply(
      transcript: (data['transcript'] ?? '').toString(),
      message: (data['message'] ?? data['output'] ?? '').toString(),
      products: data['similar_products'] is List ? data['similar_products'] : const [],
      audio: audio,
      audioMime: (data['audio_mime'] ?? 'audio/wav').toString(),
      ignored: data['ignored'] == true,
    );
  }
}

// ارسال الرسالة الصوتية الى n8n
class ChatVoiceService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  Future<ChatVoiceReply> send(VoiceRecording rec) async {
    final isM4a = rec.mimeType.contains('mp4');
    final form = FormData.fromMap({
      'audio': MultipartFile.fromBytes(
        rec.bytes,
        filename: isM4a ? 'voice.m4a' : 'voice.wav',
        contentType: DioMediaType.parse(rec.mimeType),
      ),
      'device_id': await _deviceId(),
    });

    // توكن العميل ليتعرف عليه الوكيل
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final res = await _dio.post(
      ApiEndpoints.n8nVoiceAgent,
      data: form,
      options: Options(headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }),
    );

    final data = res.data is String ? jsonDecode(res.data) : res.data;
    if (data is Map) return ChatVoiceReply.fromJson(data);
    throw Exception('bad response');
  }

  // نفس معرف الجهاز المستخدم في المساعد الصوتي
  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('voice_device_id');
    if (id == null || id.isEmpty) {
      final r = Random.secure();
      id = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
      await prefs.setString('voice_device_id', id);
    }
    return id;
  }
}
