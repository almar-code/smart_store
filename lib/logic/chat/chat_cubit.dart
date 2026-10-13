import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/chat_message.dart';
import '../../data/repos/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository = ChatRepository();
  final String _chatId = "omar_session_2026"; // معرف الجلسة الخاص بك

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "مرحباً بك! أنا Almar مساعدك الذكي لمتجر العبايات. كيف يمكنني مساعدتك اليوم؟",
      isMe: false,
    ),
  ];

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Uint8List? _selectedImage;
  bool _isLoading = false;
// ==================== أضف هذه الأسطر هنا لتجنب أي خطأ ====================
  List<ChatMessage> get messages => _messages;
  Uint8List? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  bool get isTyping => messageController.text.trim().isNotEmpty;
  ChatCubit() : super(ChatInitial()) {
    messageController.addListener(_onTextChanged);
    _emitUpdatedState();
  }

  void _onTextChanged() {
    _emitUpdatedState();
  }

  void _emitUpdatedState() {
    emit(ChatMessagesUpdated(
      messages: List.from(_messages),
      selectedImage: _selectedImage,
      isLoading: _isLoading,
      isTyping: messageController.text.trim().isNotEmpty,
    ));
  }

  /// اختيار صورة ومعاينتها قبل الإرسال
  Future<void> pickAttachmentImage() async {
    final XFile? result = await ImagePicker().pickImage(
      imageQuality: 70,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _selectedImage = await result.readAsBytes();
      _emitUpdatedState();
    }
  }

  /// إزالة صورة المعاينة
  void removeSelectedImage() {
    _selectedImage = null;
    _emitUpdatedState();
  }

  /// إرسال الرسالة إلى الـ Agent
  Future<void> sendMessage() async {
    final String userText = messageController.text.trim();
    final bool hasText = userText.isNotEmpty;
    final bool hasImage = _selectedImage != null;

    if (!hasText && !hasImage) return;

    // إضافة رسالة المستخدم محلياً للواجهة أولاً
    _messages.add(
      ChatMessage(
        text: userText.isEmpty ? null : userText,
        imagePath: _selectedImage,
        isMe: true,
        isImage: hasImage,
      ),
    );

    _selectedImage = null;
    messageController.clear();
    _isLoading = true;
    _emitUpdatedState();
    scrollToBottom();

    try {
      final String reply = await _repository.getBotReply(
        chatId: _chatId,
        message: userText,
      );

      _messages.add(ChatMessage(text: reply, isMe: false));
    } catch (e) {
      _messages.add(ChatMessage(text: "عذراً، واجهت مشكلة في الاتصال بالخادم الرئيسي.", isMe: false));
    } finally {
      _isLoading = false;
      _emitUpdatedState();
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Future<void> close() {
    messageController.removeListener(_onTextChanged);
    messageController.dispose();
    scrollController.dispose();
    return super.close();
  }
}