import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/AiRippleManager.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/smart_robot_icon.dart';

class ChatMessage {
  final String? text;

  final Uint8List? imagePath;

  final bool isMe;

  final bool isImage;

  ChatMessage({
    this.text,
    this.imagePath,
    required this.isMe,
    this.isImage = false,
  });
}

class SmartChatScreen extends StatefulWidget {
  const SmartChatScreen({super.key});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "مرحباً بك! أنا Almar مساعدك الذكي. كيف يمكنني مساعدتك اليوم؟",
      isMe: false,
    ),
  ];

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  /// الصورة المؤقتة قبل الإرسال
  // File? _selectedImage;
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();

    _messageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// إرسال الرسالة
  void _sendMessage() {
    final bool hasText = _messageController.text.trim().isNotEmpty;

    final bool hasImage = _selectedImage != null;

    if (!hasText && !hasImage) return;

    final String userText = _messageController.text.trim();

    setState(() {
      /// رسالة واحدة تحتوي صورة + نص
      _messages.add(
        ChatMessage(
          text: userText.isEmpty ? null : userText,

          imagePath: _selectedImage != null ? _selectedImage : null,

          isMe: true,

          isImage: _selectedImage != null,
        ),
      );

      _selectedImage = null;

      _messageController.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(text: "جاري معالجة طلبك الآن...", isMe: false),
          );
        });

        _scrollToBottom();
      }
    });
  }

  /// اختيار صورة فقط بدون إرسال
  void _handleAttachmentPressed() async {
    final XFile? result = await ImagePicker().pickImage(
      imageQuality: 70,
      source: ImageSource.gallery,
    );

    if (result != null) {
      setState(() async {
        _selectedImage = await result.readAsBytes();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,

        elevation: 0,

        scrolledUnderElevation: 0,

        leadingWidth: 0,

        automaticallyImplyLeading: false,

        titleSpacing: 8,

        title: Row(
          children: [
            const AiRobotAvatar(),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Almar AI",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                Text(
                  "To meet your needs",
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),

        actions: const [ArrowBack(), SizedBox(width: 6)],
      ),

      body: Stack(
        children: [
          /// الرسائل
          ListView.builder(
            controller: _scrollController,

            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),

            itemCount: _messages.length,

            itemBuilder: (context, index) {
              final message = _messages[index];

              return Column(
                children: [
                  if (index ==0 )
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          spacing: 15,
                          children: [
                            SizedBox(height: 150,),
                            AiRobotAvatar(padding: 15, iconSize: 40),
                            Text('WELLCOME OMAR' , style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor
                            ),),
                            SizedBox(height: 20,)
                          ],
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),

                    child: Row(
                      mainAxisAlignment: message.isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        if (!message.isMe) ...[
                          const AiRobotAvatar(padding: 4, iconSize: 14),

                          const SizedBox(width: 8),
                        ],

                        ChatBubble(
                          clipper: ChatBubbleClipper1(
                            type: message.isMe
                                ? BubbleType.sendBubble
                                : BubbleType.receiverBubble,
                          ),

                          alignment: message.isMe
                              ? Alignment.topRight
                              : Alignment.topLeft,

                          margin: const EdgeInsets.only(top: 4),

                          backGroundColor: (message.isMe && !message.isImage)
                              ? AppColors.primary
                              : AppColors.backgroundSecondary,

                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// الصورة
                                if (message.imagePath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),

                                    child: Image.memory(
                                      message.imagePath!,

                                      fit: BoxFit.cover,

                                      width: 220,
                                    ),
                                  ),

                                /// النص تحت الصورة مباشرة
                                if (message.text != null &&
                                    message.text!.trim().isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: message.imagePath != null ? 10 : 0,
                                    ),

                                    child: Text(
                                      message.text!,

                                      style: TextStyle(
                                        color: message.isMe
                                            ? AppColors.textColor
                                            : AppColors.textColor,

                                        fontSize: 14,

                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (message.isMe) ...[
                          const SizedBox(width: 8),

                          const CircleImage(
                            imagePath:
                                "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
                            radius: 11,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          /// الحقل العائم
          Align(
            alignment: Alignment.bottomCenter,

            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),

              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: _buildMessageInput(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final bool isTyping = _messageController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
      ),

      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            /// معاينة الصورة فوق الحقل
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),

                padding: const EdgeInsets.all(6),

                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),

                      child: Image.memory(
                        _selectedImage!,

                        height: 120,

                        width: 120,

                        fit: BoxFit.cover,
                      ),
                    ),

                    PositionedDirectional(
                      top: 4,

                      end: 4,

                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.all(4),

                          decoration:  BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),

                          child:  Icon(
                            Icons.close,
                            color: AppColors.iconColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,

                          borderRadius: BorderRadius.circular(24),

                          border: Border.all(
                            color: AppColors.textColor.withOpacity(0.05),
                            width: 1,
                          ),
                        ),

                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.photo_library,
                                color: AppColors.textColor.withOpacity(0.5),
                                size: 20,
                              ),

                              onPressed: _handleAttachmentPressed,
                            ),

                            Expanded(
                              child: TextField(
                                controller: _messageController,

                                maxLines: null,

                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 14,
                                ),

                                decoration: InputDecoration(
                                  hintText: "اكتب رسالتك هنا...",

                                  hintStyle: TextStyle(
                                    color: AppColors.textColor.withOpacity(
                                      0.35,
                                    ),
                                    fontSize: 13,
                                  ),

                                  border: InputBorder.none,

                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      PositionedDirectional(
                        top: 7,

                        end: 10,

                        child: GestureDetector(
                          onTap: isTyping || _selectedImage != null
                              ? _sendMessage
                              : () => AiRippleManager.toggleRipple(context),

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),

                            curve: Curves.easeIn,

                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: const LinearGradient(
                                colors: [Color(0xD703C383), Color(0xE025F5FC)],

                                begin: Alignment.topLeft,

                                end: Alignment.bottomRight,
                              ),

                              boxShadow: isTyping || _selectedImage != null
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),

                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),

                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return ScaleTransition(
                                      scale: animation,

                                      child: RotationTransition(
                                        turns: animation,
                                        child: child,
                                      ),
                                    );
                                  },

                              child: isTyping || _selectedImage != null
                                  ? SvgPicture.asset(
                                      "assets/images/paper-plane-tilt.svg",

                                      width: 17,

                                      key: const ValueKey('send_active'),

                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Icon(
                                      Icons.smart_toy_outlined,

                                      key: const ValueKey('mic_inactive'),

                                      color: Colors.white.withOpacity(0.9),

                                      size: 17,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
