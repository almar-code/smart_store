import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/voice_recording.dart';
import '../../data/repos/chat_repo.dart';
import '../../data/services/chat_voice_player.dart';
import '../../data/services/chat_voice_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository = ChatRepository();
  final ChatVoiceService _voiceService = ChatVoiceService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "مرحباً بك! أنا Almar مساعدك الذكي لمتجر العبايات. كيف يمكنني مساعدتك اليوم؟",
      isMe: false,
    ),
  ];

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Uint8List? _selectedImage;
  String? _selectedImageName;
  bool _isLoading = false;
  bool _isVoiceReply = false; // انتظار رد صوتي

  // 1. إنشاء نسخة ثابتة (Static Instance)
  static final ChatCubit _instance = ChatCubit._internal();

  // 2. Constructor خاص للـ Singleton
  ChatCubit._internal() : super(ChatInitial()) {
    messageController.addListener(_onTextChanged);
    _emitUpdatedState();
  }

  // 3. Factory Constructor لإرجاع نفس النسخة دائماً وعدم فقدان المحادثة
  factory ChatCubit() {
    return _instance;
  }

  // Getters
  List<ChatMessage> get messages => _messages;
  Uint8List? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  bool get isTyping => messageController.text.trim().isNotEmpty;

  void _onTextChanged() {
    _emitUpdatedState();
  }

  void _emitUpdatedState() {
    emit(ChatMessagesUpdated(
      messages: List.from(_messages),
      selectedImage: _selectedImage,
      isLoading: _isLoading,
      isTyping: messageController.text.trim().isNotEmpty,
      isVoiceReply: _isVoiceReply,
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
      _selectedImageName = result.name;
      _emitUpdatedState();
    }
  }

  /// إزالة صورة المعاينة
  void removeSelectedImage() {
    _selectedImage = null;
    _selectedImageName = null;
    _emitUpdatedState();
  }

  /// إرسال الرسالة إلى الـ Agent
  Future<void> sendMessage() async {
    final String userText = messageController.text.trim();
    final bool hasText = userText.isNotEmpty;
    final Uint8List? imageToSend = _selectedImage;
    final String? imageNameToSend = _selectedImageName;
    final bool hasImage = imageToSend != null;
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
      final Map<String, dynamic> responseMap = await _repository.getBotReply(
        message: userText,
        image: imageToSend,
        imageName: imageNameToSend,
      );

      final String replyMessage = responseMap['message'] ?? '';
      final List<dynamic> productsList = responseMap['similar_products'] ?? [];

      _messages.add(
        ChatMessage(
          text: replyMessage,
          isMe: false,
          similarProducts: productsList, // إرفاق المنتجات بالرسالة
        ),
      );
    } catch (e) {
      _messages.add(ChatMessage(text: "عذراً، واجهت مشكلة في الاتصال بالخادم الرئيسي.", isMe: false));
    } finally {
      _isLoading = false;
      _emitUpdatedState();
      scrollToBottom();
    }
  }

  /// ارسال رسالة صوتية وانتظار رد صوتي
  Future<void> sendVoiceMessage(VoiceRecording rec) async {
    final mine = ChatMessage(
      isMe: true,
      audioBytes: rec.bytes,
      audioMime: rec.mimeType,
      audioPath: rec.localPath,
      audioDuration: rec.duration,
      waveform: rec.samples,
    );
    _messages.add(mine);
    _isLoading = true;
    _isVoiceReply = true;
    _emitUpdatedState();
    scrollToBottom();

    try {
      final reply = await _voiceService.send(rec);

      // اضافة نص ما قاله العميل لرسالته
      if (reply.transcript.trim().isNotEmpty) {
        final i = _messages.indexWhere((m) => m.id == mine.id);
        if (i != -1) {
          _messages[i] = ChatMessage(
            id: mine.id,
            text: reply.transcript.trim(),
            isMe: true,
            audioBytes: mine.audioBytes,
            audioMime: mine.audioMime,
            audioPath: mine.audioPath,
            audioDuration: mine.audioDuration,
            waveform: mine.waveform,
          );
        }
      }

      if (reply.ignored) {
        _messages.add(ChatMessage(text: tr('voice_not_heard'), isMe: false));
      } else if (reply.audio != null) {
        final botVoice = ChatMessage(
          text: reply.message,
          isMe: false,
          similarProducts: reply.products,
          audioBytes: reply.audio,
          audioMime: reply.audioMime,
        );
        _messages.add(botVoice);
        // تشغيل الرد تلقائيا
        ChatVoicePlayer.instance.toggle(botVoice);
      } else {
        // لو فشل الصوت نعرض الرد نصا
        _messages.add(ChatMessage(text: reply.message, isMe: false, similarProducts: reply.products));
      }
    } catch (e) {
      debugPrint('voice send error: $e');
      _messages.add(ChatMessage(text: tr('voice_error_network'), isMe: false));
    } finally {
      _isLoading = false;
      _isVoiceReply = false;
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
    // بما أننا نستخدم Singleton، لن نقوم بحذف الـ Listeners أو إغلاق الكلاس نهائياً
    // لكي تظل الرسائل محفوظة عند الخروج والعودة للشاشة.
    return Future.value();
  }

}