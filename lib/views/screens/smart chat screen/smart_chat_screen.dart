import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/utils/AiRippleManager.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/smart_robot_icon.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/chat_message.dart';
import '../../../logic/chat/chat_cubit.dart';
import '../../../logic/chat/chat_state.dart';
import '../product/products_screen.dart';

class SmartChatScreen extends StatelessWidget {
  final bool screenOnly;
  const SmartChatScreen({super.key, this.screenOnly = true});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().scrollToBottom();
    });
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    bool isIpad = MediaQuery.of(context).size.width < 900 && MediaQuery.of(context).size.width > 450;
    int itemCount = isDesktop ? 4 : isIpad ? 3 : 2;
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
          actions: [if (screenOnly) const ArrowBack(), const SizedBox(width: 6)],
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
                          child: Directionality(
                            textDirection: ui.TextDirection.ltr,

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
                                      crossAxisAlignment:Directionality.of(context) == ui.TextDirection.rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: message.imagePath != null ? 220 : 904,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: Directionality.of(context) == ui.TextDirection.rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    message.text!,
                                                    textDirection: Directionality.of(context),
                                                    textAlign: TextAlign.start,

                                                    softWrap: true,
                                                    style: TextStyle(
                                                      color: AppColors.textColor,
                                                      fontSize: 14,
                                                      height: 2,
                                                    ),
                                                  ),
                                                  // أضف هذا الويدجت تحت عرض النص داخل محتوى فقاعة البوت (Receiver Bubble)
                                                  if (message.similarProducts != null && message.similarProducts!.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 10),
                                                      child: SizedBox(
                                                         width:904,
                                                        child: MasonryGridView.count(
                                                          scrollDirection: Axis.vertical,
                                                          crossAxisCount: itemCount,
                                                          mainAxisSpacing: 8, // مسافة بين العنصر والذي تحته كودك الأصلي
                                                          crossAxisSpacing: 8, // مسافة بين العنصر والذي جنبه كودك الأصلي
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          // منع التمرير الداخلي لكي تتمرر القائمة الرئيسية بسلاسة
                                                          itemCount: message.similarProducts!.length,
                                                          itemBuilder: (context, pIndex) {
                                                            final product = message.similarProducts![pIndex];
                                                            final int productId = int.parse(product['p_id'].toString());
                                                            final String imageName = product['p_image'].toString();
                                                            final String productName = product['p_name']?.toString() ?? ''; // قراءة اسم المنتج الجديد
                                                            final String productNameEn = product['p_name_en']?.toString() ?? ''; // قراءة اسم المنتج الجديد

                                                            return InkWell(
                                                              onTap: (){
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ProductScreens(
                                                                      productID: productId,
                                                                      subCategoryID:null,
                                                                      categoryID: null,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  border: Border.all(color: Colors.grey.shade300),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:   (context.locale.languageCode == 'en') ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                                  children: [
                                                                    // استخدام ClipRRect مع Image.network بدون قيد ارتفاع صارم لكي يأخذ الحجم الحقيقي للصورة
                                                                    ClipRRect(
                                                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                                                      child: Image.network(
                                                                        ApiEndpoints.productImageUrl(imageName),
                                                                        fit: BoxFit.cover,
                                                                        width: 220, // عرض البطاقة الثابت
                                                                        loadingBuilder: (context, child, loadingProgress) {
                                                                          if (loadingProgress == null) {
                                                                            return child;
                                                                          }
                                                                          return Container(
                                                                            color: AppColors.background,
                                                                            width:220,
                                                                            height: 250, // ارتفاع مؤقت أثناء التحميل فقط
                                                                            child: Center(child: ThreeDotsLoader()),
                                                                          );
                                                                        },
                                                                        errorBuilder: (context, error, stackTrace) {
                                                                          return Image.asset(
                                                                            'assets/images/app icon/icon.png',
                                                                            fit: BoxFit.contain,
                                                                            width: 220,
                                                                            height: 250,
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.all(6.0),
                                                                      child: Text(
                                                                        (context.locale.languageCode == 'en')? productNameEn ?? '' : productName ?? '',
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          fontSize: 13,
                                                                          color: AppColors.textColor,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),

                                                ],
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
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Row(
                        spacing: 8,
                        children: [
                          AiRobotAvatar(padding: 4, iconSize: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ThreeDotsLoader(isSmall: true,),
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
                                  hintText: "اسال Almar...",
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