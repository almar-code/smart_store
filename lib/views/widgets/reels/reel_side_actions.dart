import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/compact_count.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../data/models/video_model.dart';
import '../../../logic/videos/video_cubit.dart';
import 'reel_comments_sheet.dart';

class ReelSideActions extends StatefulWidget {
  final VideoModel video;
  const ReelSideActions({super.key, required this.video});

  @override
  State<ReelSideActions> createState() => _ReelSideActionsState();
}

class _ReelSideActionsState extends State<ReelSideActions> {
  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    final cubit = context.read<VideoCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: v.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: v.isLiked ? const Color(0xFFFF3B5C) : Colors.white,
          active: v.isLiked,
          label: compactCount(v.likesCount),
          onTap: () async {
            await cubit.toggleLike(v);
            if (mounted) setState(() {});
          },
        ),
        _ActionButton(
          icon: CupertinoIcons.chat_bubble,
          label: compactCount(v.commentsCount),
          onTap: () async {
            await showReelComments(context, v);
            if (mounted) setState(() {});
          },
        ),
        _ActionButton(
          icon: v.isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
          color: v.isSaved ? AppColors.primary : Colors.white,
          active: v.isSaved,
          label: compactCount(v.savesCount),
          onTap: () async {
            final saved = await cubit.toggleSave(v);
            if (!mounted) return;
            setState(() {});
            AppToasts.showSuccessToast(context, tr(saved ? 'reel_saved' : 'reel_unsaved'));
          },
        ),
        _ActionButton(
          icon: CupertinoIcons.paperplane,
          label: compactCount(v.sharesCount),
          onTap: () {
            cubit.share(v);
            setState(() {});
            Share.share('${tr('share_reel_text')}\n${v.videoUrl}');
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.active = false,
  });

  static const _shadow = [Shadow(color: Colors.black45, blurRadius: 8)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        child: Column(
          children: [
            AnimatedScale(
              scale: active ? 1.12 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(icon, color: color, size: 30, shadows: _shadow),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, shadows: _shadow),
            ),
          ],
        ),
      ),
    );
  }
}