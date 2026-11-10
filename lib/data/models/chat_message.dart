import 'dart:typed_data';

class ChatMessage {
  final String? text;
  final Uint8List? imagePath;
  final bool isMe;
  final bool isImage;
  final List<dynamic>? similarProducts; // حقل جديد لمصفوفة المنتجات

  ChatMessage({
    this.text,
    this.imagePath,
    required this.isMe,
    this.isImage = false,
    this.similarProducts,
  });
}