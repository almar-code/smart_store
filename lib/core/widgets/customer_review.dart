import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/titleBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_comment_model.dart';
import '../../logic/login/login_cubit.dart';
import '../../logic/productcomment/product_comment_cubit.dart';
import '../../logic/productcomment/product_comment_state.dart';
import '../../views/widgets/flash/flash_screen.dart';
import '../../views/widgets/login/login.dart';
import '../../views/widgets/product/product_reviews_sheet.dart';
import '../di/injection_container.dart' as di;
import 'app_messages.dart';
import 'circleImage/circle_image.dart';
import 'customer_photo.dart';
import 'image_helper.dart';
import 'review_input_field.dart';

class ProductReviewsSection extends StatelessWidget {
  final int productId;
  const ProductReviewsSection({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductCommentCubit>()..loadComments(productId),
      child: _ProductReviewsView(
        productId: productId,
      ),
    );
  }
}

class _ProductReviewsView extends StatefulWidget {
  final int productId;

  const _ProductReviewsView({
    required this.productId,
  });

  @override
  State<_ProductReviewsView> createState() => _ProductReviewsViewState();
}

class _ProductReviewsViewState extends State<_ProductReviewsView> {
  bool _isSubmitting = false;
  int _stars = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // فتح كل التعليقات مع جعل المختار أولا
  void _openSheet({int? firstCommentId}) {
    ProductReviewsSheet.show(
      context,
      productId: widget.productId,
      cubit: context.read<ProductCommentCubit>(),
      firstCommentId: firstCommentId,
    );
  }

  Future<void> _submitReview(BuildContext context) async {
    if (_isSubmitting) return;
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    final box = Hive.box('user_info_box');
    final String userName = (box.isEmpty) ? '' : box.get('name');
    setState(() => _isSubmitting = true);

    // إفراغ الحقل مؤقتا مع الاحتفاظ بالنص
    _commentController.clear();
    FocusScope.of(context).unfocus();

    final result = await context.read<ProductCommentCubit>().sendComment(
      customerName: userName,
      productId: widget.productId,
      commentText: commentText,
      stars: _stars.toDouble(),
    );

    if (!mounted) return;

    // اعادة النص عند الرفض او الفشل
    if (result != CommentSubmitResult.accepted) {
      _commentController.text = commentText;
      AppToasts.showErrorToast(
        context,
        tr(result == CommentSubmitResult.rejected ? 'review_rejected' : 'review_failed'),
      );
    } else {
      setState(() => _stars = 5);
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        TitleBar(
          title: tr('customer_reviews'),
          viewMoreShow: InkWell(
            onTap: _openSheet,
            child: Text(
              tr('view_more'),
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withOpacity(0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Text(
                  tr("productReviewQuestion"),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              SizedBox(
                height: 100,
                child: BlocBuilder<ProductCommentCubit, ProductCommentState>(
                  builder: (context, state) {
                    if (state is ProductCommentLoading) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (_, __) => const ProductCommentFlash(),
                      );
                    }

                    if (state is ProductCommentLoaded) {
                      if (state.comments.isEmpty) {
                        return Center(child: Text(tr("noCommentsYet")));
                      }

                      final myId = int.tryParse('${Hive.box('user_info_box').get('customer_id') ?? ''}');
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final review = state.comments[index];
                          return _ReviewCard(
                            review: review,
                            isMine: myId != null && review.customerId == myId,
                            onTap: review.isSending ? null : () => _openSheet(firstCommentId: review.commentId),
                            onDelete: () => context.read<ProductCommentCubit>().removeComment(review.commentId),
                          );
                        },
                      );
                    }

                    if (state is ProductCommentError) {
                      return Center(
                        child: Text(
                          tr('unexpected_error'),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),

              _buildMessageInput(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final isStateLoggedIn = context.read<LoginCubit>().state;
    final isFullyLoggedIn = session != null && isStateLoggedIn;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: ReviewInputField(
        controller: _commentController,
        stars: _stars,
        sending: _isSubmitting,
        onStarsChanged: (v) => setState(() => _stars = v),
        onSend: () {
          // طلب تسجيل الدخول قبل الإرسال
          if (!isFullyLoggedIn) {
            Login().loginDialog(context);
          } else if (_commentController.text.trim().isNotEmpty) {
            _submitReview(context);
          }
        },
      ),
    );
  }
}

// بطاقة تعليق مختصرة بسطرين
class _ReviewCard extends StatelessWidget {
  final ProductCommentModel review;
  final bool isMine;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.isMine,
    required this.onTap,
    required this.onDelete,
  });

  // صورة التعليق، ولتعليقي بدون صورة سيرفر تؤخذ صورة الجهاز
  Widget _avatar(String name) {
    final url = review.customerImage ?? '';
    return CustomerPhoto(radius: 16, name: name, image: (url.isEmpty && isMine) ? null : url);
  }
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isEn = context.locale.languageCode == 'en';
    final text = (isEn && review.commentEn.isNotEmpty) ? review.commentEn : review.commentAr;
    final name = review.customerName.isEmpty ? tr('guest') : review.customerName;

    return Opacity(
      opacity: review.isSending ? 0.5 : 1.0,
      child: Container(
        width: MediaQuery.of(context).size.width * (isDesktop ? 0.30 : 0.75),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textColor.withOpacity(0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avatar(name),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الاسم والنجوم في سطر واحد
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textColor),
                            ),
                            if (review.isSending)
                              const Padding(
                                padding: EdgeInsetsDirectional.only(start: 6),
                                child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            else if (isMine)
                              InkWell(
                                onTap: onDelete,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 6),
                                  child: Icon(Icons.delete_outline, size: 16, color: AppColors.redColor),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [

                            ...List.generate(
                              5,
                                  (i) => Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: i < review.stars.floor() ? Colors.amber : Colors.grey.withOpacity(0.3),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 8),
                        // التعليق بسطرين فقط
                        Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.textColor.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}