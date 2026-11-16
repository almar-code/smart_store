import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/image_helper.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/video_model.dart';
import '../../../logic/videos/comments_cubit.dart';

Future<void> showReelComments(BuildContext context, VideoModel video) {
  final cubit = context.read<CommentsCubit>()..loadComments(video.videoId);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (_) => BlocProvider.value(value: cubit, child: _CommentsSheet(video: video)),
  );
}

class _CommentsSheet extends StatefulWidget {
  final VideoModel video;
  const _CommentsSheet({required this.video});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final ok = await context.read<CommentsCubit>().sendComment(widget.video, text);
    if (!ok && mounted) {
      _controller.text = text;
      AppToasts.showWarningToast(context, tr('login_to_comment'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(4)),
            ),

            // العنوان مع العدد
            Padding(
              padding: const EdgeInsets.all(14),
              child: BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, _) => Text(
                  '${tr('comments')} (${widget.video.commentsCount})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.borderColor.withOpacity(0.5)),

            // القائمة
            Expanded(
              child: BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, state) {
                  if (state is CommentsLoading) return const Center(child: CircularProgress());
                  if (state is CommentsError) {
                    return Center(
                      child: Text(tr('comments_error'), style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  if (state is CommentsLoaded) {
                    if (state.comments.isEmpty) return const _EmptyComments();
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      itemCount: state.comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (_, i) => _CommentTile(comment: state.comments[i]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            // حقل الكتابة
            Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + media.padding.bottom),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.borderColor.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: TextStyle(color: AppColors.textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: tr('add_comment'),
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _send,
                      child: const Padding(
                        padding: EdgeInsets.all(11),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  // وقت مختصر: الآن، 5 د، 3 س
  String _timeAgo(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return tr('ago_now');
    if (diff.inHours < 1) return tr('ago_minutes', namedArgs: {'n': '${diff.inMinutes}'});
    if (diff.inDays < 1) return tr('ago_hours', namedArgs: {'n': '${diff.inHours}'});
    return tr('ago_days', namedArgs: {'n': '${diff.inDays}'});
  }
  // رابط من السيرفر او Base64 من Hive
  ImageProvider? _avatarProvider(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http')) return CachedNetworkImageProvider(image);
    try {
      return MemoryImage(ImageHelper.decodeBase64(image));
    } catch (_) {
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    final name = comment.customerName.isEmpty ? tr('guest') : comment.customerName;
    final avatar = _avatarProvider(comment.customerImage);

    return Opacity(
      opacity: comment.isSending ? 0.5 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            backgroundImage: avatar,
            child: avatar == null
                ? Text(name.characters.first, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.isSending ? tr('sending') : _timeAgo(comment.createdAt),
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  comment.commentText,
                  style: TextStyle(color: AppColors.textColor, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.08)),
            child: Icon(CupertinoIcons.chat_bubble_2, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(tr('no_comments'), style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(tr('be_first_comment'), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}