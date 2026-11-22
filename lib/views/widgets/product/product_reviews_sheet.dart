import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/utils/avatar_provider.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/customer_photo.dart';
import '../../../core/widgets/review_input_field.dart';
import '../../../data/local/user_local.dart';
import '../../../data/models/product_comment_model.dart';
import '../../../logic/productcomment/product_comment_cubit.dart';
import '../../../logic/productcomment/product_comment_state.dart';

class ProductReviewsSheet {
  // cubit اختياري لاستخدام نفس تعليقات صفحة التفاصيل
  // firstCommentId لعرض التعليق المضغوط عليه أولا
  static Future<void> show(
      BuildContext context, {
        required int productId,
        ProductCommentCubit? cubit,
        int? firstCommentId,
      }) {
    final owned = cubit == null;
    final c = cubit ?? (di.sl<ProductCommentCubit>()..loadComments(productId));

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => BlocProvider.value(
        value: c,
        child: _ReviewsSheet(productId: productId, firstCommentId: firstCommentId),
      ),
    ).whenComplete(() {
      if (owned) c.close();
    });
  }
}

class _ReviewsSheet extends StatefulWidget {
  final int productId;
  final int? firstCommentId;
  const _ReviewsSheet({required this.productId, this.firstCommentId});

  @override
  State<_ReviewsSheet> createState() => _ReviewsSheetState();
}

class _ReviewsSheetState extends State<_ReviewsSheet> {
  final _controller = TextEditingController();
  int _stars = 5;
  bool _sending = false;
  int? _myId;

  @override
  void initState() {
    super.initState();
    UserLocal().getCustomerId().then((id) {
      if (mounted) setState(() => _myId = id);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    if (_myId == null) {
      AppToasts.showWarningToast(context, tr('login_to_comment'));
      return;
    }

    final user = await UserLocal().getUser();
    setState(() => _sending = true);
    _controller.clear();
    if (mounted) FocusScope.of(context).unfocus();

    final result = await context.read<ProductCommentCubit>().sendComment(
      productId: widget.productId,
      commentText: text,
      stars: _stars.toDouble(),
      customerName: user?.name ?? '',
      customerImage: user?.image,
    );

    if (!mounted) return;

    // اعادة النص عند الرفض او الفشل
    if (result != CommentSubmitResult.accepted) {
      _controller.text = text;
      AppToasts.showErrorToast(
        context,
        tr(result == CommentSubmitResult.rejected ? 'review_rejected' : 'review_failed'),
      );
    }
    setState(() => _sending = false);
  }

  Future<void> _delete(ProductCommentModel review) async {
    final ok = await AppToasts.showConfirmDialog(
      context: context,
      title: tr('confirm_delete_title'),
      message: tr('confirm_delete_review_msg'),
    );
    if (ok == true && mounted) {
      context.read<ProductCommentCubit>().removeComment(review.commentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.75,
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
              child: BlocBuilder<ProductCommentCubit, ProductCommentState>(
                builder: (context, state) {
                  final count = state is ProductCommentLoaded ? state.comments.length : 0;
                  return Text(
                    '${tr('customer_reviews')} ($count)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
                  );
                },
              ),
            ),
            Divider(height: 1, color: AppColors.borderColor.withOpacity(0.5)),

            // القائمة
            Expanded(
              child: BlocBuilder<ProductCommentCubit, ProductCommentState>(
                builder: (context, state) {
                  if (state is ProductCommentLoading || state is ProductCommentInitial) {
                    return const Center(child: CircularProgress());
                  }
                  if (state is ProductCommentError) {
                    return Center(child: Text(tr('reviews_error'), style: TextStyle(color: AppColors.textSecondary)));
                  }

                  // نقل التعليق المختار لأول القائمة
                  final all = (state as ProductCommentLoaded).comments;
                  final comments = [
                    ...all.where((c) => c.commentId == widget.firstCommentId),
                    ...all.where((c) => c.commentId != widget.firstCommentId),
                  ];
                  if (comments.isEmpty) return const _EmptyReviews();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (_, i) {
                      final review = comments[i];
                      final selected = review.commentId == widget.firstCommentId;

                      // تمييز التعليق المختار بخلفية خفيفة
                      return Container(
                        padding: selected ? const EdgeInsets.all(10) : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withOpacity(0.06) : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _ReviewTile(
                          review: review,
                          isMine: _myId != null && review.customerId == _myId,
                          onDelete: () => _delete(review),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // التقييم وحقل الكتابة
            Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + media.padding.bottom),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.borderColor.withOpacity(0.5))),
              ),
              child: ReviewInputField(
                controller: _controller,
                stars: _stars,
                onStarsChanged: (v) => setState(() => _stars = v),
                onSend: _send,
                sending: _sending,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductCommentModel review;
  final bool isMine;
  final VoidCallback onDelete;

  const _ReviewTile({required this.review, required this.isMine, required this.onDelete});

  // وقت مختصر
  String _timeAgo(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return tr('ago_now');
    if (diff.inHours < 1) return tr('ago_minutes', namedArgs: {'n': '${diff.inMinutes}'});
    if (diff.inDays < 1) return tr('ago_hours', namedArgs: {'n': '${diff.inHours}'});
    return tr('ago_days', namedArgs: {'n': '${diff.inDays}'});
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';
    final text = (isEn && review.commentEn.isNotEmpty) ? review.commentEn : review.commentAr;
    final name = review.customerName.isEmpty ? tr('guest') : review.customerName;

    return Opacity(
      opacity: review.isSending ? 0.5 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerPhoto(radius: 18, image: review.customerImage ?? '', name: name),
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
                      _timeAgo(review.createdAt),
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: i < review.stars.floor() ? Colors.amber : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(color: AppColors.textColor, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
          if (isMine && !review.isSending)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.redColor, size: 18),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

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
            child: Icon(CupertinoIcons.star, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(tr('no_reviews'), style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(tr('be_first_review'), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}