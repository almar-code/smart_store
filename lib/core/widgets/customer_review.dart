import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/titleBar.dart';// مسار الـ State
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../logic/login/login_cubit.dart';
import '../../logic/productcomment/product_comment_cubit.dart';
import '../../logic/productcomment/product_comment_state.dart';
import '../../views/widgets/flash/flash_screen.dart';
import '../../views/widgets/login/login.dart';
import '../di/injection_container.dart' as di;
import 'circleImage/circle_image.dart';
import 'image_helper.dart';

class ProductReviewsSection extends StatelessWidget {
  final int productId;
  final String currentCustomerId;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    required this.currentCustomerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductCommentCubit>()..loadComments(productId),
      child: _ProductReviewsView(
        productId: productId,
        currentCustomerId: currentCustomerId,
      ),
    );
  }
}

class _ProductReviewsView extends StatefulWidget {
  final int productId;
  final String currentCustomerId;

  const _ProductReviewsView({
    required this.productId,
    required this.currentCustomerId,
  });

  @override
  State<_ProductReviewsView> createState() => _ProductReviewsViewState();
}

class _ProductReviewsViewState extends State<_ProductReviewsView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview(BuildContext context) {

    var box = Hive.box('user_info_box');
    String userName = (box.isEmpty) ? '' :  box.get('name');
    if (_commentController.text.trim().isEmpty) return;

    context.read<ProductCommentCubit>().sendComment(
      customerName: userName,
      customerId: widget.currentCustomerId,
      productId: widget.productId,
      commentText: _commentController.text.trim(),
      stars: 5.0,
    );
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    bool isDesktop = MediaQuery.of(context).size.width > 800;


    return Column(
      children: [
        const TitleBar(title: "Customer Review"),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withOpacity(0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  tr("productReviewQuestion"),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 140,
                child: BlocBuilder<ProductCommentCubit, ProductCommentState>(
                  builder: (context, state) {
                    if (state is ProductCommentLoading) {
                      return SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            return ProductCommentFlash();
                          },
                        ),
                      );
                    } else if (state is ProductCommentLoaded) {
                      if (state.comments.isEmpty) {
                        return  Center(
                          child: Text(tr("noCommentsYet")),
                        );
                      }

                       return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final review = state.comments[index];
                          final customerName = review.customerName ?? "مستخدم";
                          final avatarUrl = review.customerImage ?? "";
                          final isMyComment = review.customerId == widget.currentCustomerId;
                          var box = Hive.box('user_info_box');
                          String imag = (box.isEmpty) ? '' :  box.get('image');


                          return Opacity(
                            opacity: review.isSending ? 0.5 : 1.0,
                            child: Container(
                              width: MediaQuery.of(context).size.width *(isDesktop ? 0.30 : 0.75),
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.05),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      (avatarUrl.isNotEmpty)?
                                      CircleImage(
                                        imagePath: avatarUrl.isNotEmpty
                                            ? avatarUrl
                                            : imag,
                                        icon: Icons.person_2_outlined,
                                        radius: 15,
                                      ):CircleAvatar(
                                          radius: 15,
                                          backgroundColor: AppColors.background,
                                          backgroundImage: (imag.isNotEmpty && imag.isNotEmpty)
                                              ? MemoryImage(ImageHelper.decodeBase64(imag))
                                              : null,
                                          child: (imag.isEmpty || imag.isEmpty)
                                              ?  Icon(Icons.person, size: 100, color: AppColors.iconColor)
                                              : null,
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customerName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(
                                                5,
                                                    (i) => Icon(
                                                  Icons.star_rounded,
                                                  color: i < review.stars.floor()
                                                      ? Colors.amber
                                                      : Colors.grey.withOpacity(0.3),
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (review.isSending)
                                        SizedBox(
                                          width: 32,
                                          height: 45,
                                          child: Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        )
                                      else if (isMyComment && review.commentId != null)
                                        SizedBox(
                                          width: 32,
                                          height: 45,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              context.read<ProductCommentCubit>().removeComment(
                                                review.commentId,
                                                widget.currentCustomerId,
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(

                                    child: Text(
                                      review.commentAr,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is ProductCommentError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),
              ),

              const SizedBox(height: 12),
              _buildMessageInput(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final bool isTyping = _commentController.text.trim().isNotEmpty;
    final session = Supabase.instance.client.auth.currentSession;

    final isStateLoggedIn = context.read<LoginCubit>().state;
    final isFullyLoggedIn = session != null && isStateLoggedIn;
    Login login = Login();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          maxLines: null,
                          style: TextStyle(color: AppColors.textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText:tr("writeCommentHint"),
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
                  end: 7,
                  child: GestureDetector(
                    onTap: () {
                      if (isFullyLoggedIn) {
                        if (isTyping) {
                          _submitReview(context);
                        }
                      } else {
                        if (context.mounted) {
                          login.loginDialog(context);
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xD703C383), Color(0xE025F5FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        isTyping ? Icons.send_rounded : Icons.add_circle_outline_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}