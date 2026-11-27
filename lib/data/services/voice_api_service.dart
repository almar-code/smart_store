import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

import '../../core/constants/app_endpoints.dart';
import '../../core/utils/device_id_helper.dart';
import '../models/voice_reply_model.dart';

class VoiceApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static const String _deviceKey = 'voice_device_id';

  // ارسال صوت العميلة واستقبال الرد
  Future<VoiceReplyModel> sendVoice(
      Uint8List audio, {
        String mimeType = 'audio/wav',
      }) async {
    final String? token =
        Supabase.instance.client.auth.currentSession?.accessToken;

    final FormData data = FormData.fromMap({
      'device_id': await DeviceIdHelper.get(),
      'audio': MultipartFile.fromBytes(
        audio,
        filename: mimeType == 'audio/mp4' ? 'voice.m4a' : 'voice.wav',
        contentType: DioMediaType.parse(mimeType),
      ),
    });

    final Response response = await _dio.post(
      ApiEndpoints.n8nVoiceAgent,
      data: data,
      options: Options(
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );

    final dynamic body = response.data;
    if (body is Map<String, dynamic>) {
      return VoiceReplyModel.fromJson(body);
    }
    throw Exception('voice_bad_response');
  }
}