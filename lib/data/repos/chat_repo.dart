import '../services/chat_service.dart';
import 'dart:typed_data';
class ChatRepository {
  final ChatService _chatService;

  ChatRepository({ChatService? chatService}) : _chatService = chatService ?? ChatService();
  Future<Map<String, dynamic>> getBotReply({
    required String message,
    Uint8List? image,
    String? imageName,
  }) {
    return _chatService.sendPrompt(
      message: message,
      image: image,
      imageName: imageName,
    );
  }
}