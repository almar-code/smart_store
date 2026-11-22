import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/circularProgress.dart';

// حقل كتابة التعليق مع النجوم داخله
class ReviewInputField extends StatelessWidget {
  final TextEditingController controller;
  final int stars;
  final ValueChanged<int> onStarsChanged;
  final VoidCallback onSend;
  final bool sending;

  const ReviewInputField({
    super.key,
    required this.controller,
    required this.stars,
    required this.onStarsChanged,
    required this.onSend,
    this.sending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textColor.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // النجوم
          Row(
            children: List.generate(
              5,
                  (i) => GestureDetector(
                onTap: () => onStarsChanged(i + 1),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 2),
                  child: Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          // الكتابة وزر الإرسال
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(color: AppColors.textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: tr('writeCommentHint'),
                    hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.35), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  final isTyping = value.text.trim().isNotEmpty;
                  return GestureDetector(
                    onTap: sending ? null : onSend,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xD703C383), Color(0xE025F5FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: sending
                          ? const SizedBox(width: 16, height: 16, child: CircularProgress(size: 16, color: Colors.white))
                          : Icon(
                        isTyping ? Icons.send_rounded : Icons.add_circle_outline_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}