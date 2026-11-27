import 'dart:typed_data';

import '../models/voice_reply_model.dart';
import '../services/voice_api_service.dart';

class VoiceRepository {
  final VoiceApiService _service;

  VoiceRepository({VoiceApiService? service})
      : _service = service ?? VoiceApiService();

  Future<VoiceReplyModel> sendVoice(
      Uint8List audio, {
        String mimeType = 'audio/wav',
      }) {
    return _service.sendVoice(audio, mimeType: mimeType);
  }
}