import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository({ChatService? chatService}) : _chatService = chatService ?? ChatService();

  Future<String> getBotReply({required String chatId, required String message}) {
    return _chatService.sendPrompt(chatId: chatId, message: message);
  }
}