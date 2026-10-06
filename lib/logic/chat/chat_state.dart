import 'dart:typed_data';
import '../../data/models/chat_message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatMessagesUpdated extends ChatState {
  final List<ChatMessage> messages;
  final Uint8List? selectedImage;
  final bool isLoading;
  final bool isTyping;

  ChatMessagesUpdated({
    required this.messages,
    this.selectedImage,
    this.isLoading = false,
    this.isTyping = false,
  });
}