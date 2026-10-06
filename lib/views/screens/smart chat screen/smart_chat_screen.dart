import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/AiRippleManager.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/smart_robot_icon.dart';
import '../../../data/models/chat_message.dart';
import '../../../logic/chat/chat_cubit.dart';
import '../../../logic/chat/chat_state.dart';

class SmartChatScreen extends StatelessWidget {
  const SmartChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => ChatCubit(),
      child: Scaffold(
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
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            final cubit = context.read<ChatCubit>();

            // الحالات الافتراضية في حال البداية
            List<ChatMessage> messages = [];
            Uint8List? selectedImage;
            bool isLoading = false;
            bool isTyping = false;

            if (state is ChatMessagesUpdated) {
              messages = state.messages;
              selectedImage = state.selectedImage;
              isLoading = state.isLoading;
              isTyping = state.isTyping;
            }

            return Stack(
              children: [
                /// قائمة رسائل المحادثة
                ListView.builder(
                  controller: cubit.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return Column(
                      children: [
                        if (index == 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                spacing: 15,
                                children: [
                                  const SizedBox(height: 150),
                                  const AiRobotAvatar(padding: 15, iconSize: 40),
                                  Text(
                                    'WELCOME OMAR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
                                      if (message.imagePath != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(
                                            message.imagePath!,
                                            fit: BoxFit.cover,
                                            width: 220,
                                          ),
                                        ),
                                      if (message.text != null &&
                                          message.text!.trim().isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: message.imagePath != null ? 10 : 0,
                                          ),
                                          child: Text(
                                            message.text!,
                                            style: TextStyle(
                                              color: AppColors.textColor,
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

                /// مؤشر اللودينج أثناء معالجة الطلب
                if (isLoading)
                  Positioned(
                    bottom: 120,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "يقرأ من متجر السحاب...",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
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
                      child: _buildMessageInput(context, cubit, selectedImage, isTyping),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatCubit cubit, Uint8List? selectedImage, bool isTyping) {
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
            if (selectedImage != null)
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
                        selectedImage as Uint8List,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    PositionedDirectional(
                      top: 4,
                      end: 4,
                      child: GestureDetector(
                        onTap: cubit.removeSelectedImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
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
                              onPressed: cubit.pickAttachmentImage,
                            ),
                            Expanded(
                              child: TextField(
                                controller: cubit.messageController,
                                maxLines: null,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: "اكتب رسالتك هنا...",
                                  hintStyle: TextStyle(
                                    color: AppColors.textColor.withOpacity(0.35),
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
                          onTap: isTyping || selectedImage != null
                              ? cubit.sendMessage
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
                              boxShadow: isTyping || selectedImage != null
                                  ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                                  : null,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: RotationTransition(
                                    turns: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: isTyping || selectedImage != null
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