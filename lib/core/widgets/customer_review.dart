import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/titleBar.dart';

import 'circleImage/circle_image.dart';

// نموذج بيانات رأي العميل
class CustomerReview {
  final String name;
  final String avatarUrl;
  final String comment;
  final double rating;

  CustomerReview({
    required this.name,
    required this.avatarUrl,
    required this.comment,
    this.rating = 5.0,
  });
}

class ProductReviewsSection extends StatefulWidget {
  const ProductReviewsSection({super.key});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  final TextEditingController _commentController = TextEditingController();

  // قائمة تجريبية لآراء العملاء
  // English mock data for customer reviews
  final List<CustomerReview> _reviews = [
    CustomerReview(
      name: "Omar Abdalfatah",
      avatarUrl: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
      comment: "Excellent product! The premium build quality exceeded my expectations. Highly recommended, and I will definitely buy again.",
      rating: 5.0,
    ),
    CustomerReview(
      name: "Ahmed Ali",
      avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200",
      comment: "The application is very smooth. The user experience is outstanding, responsive, and incredibly fast.",
      rating: 4.5,
    ),
    CustomerReview(
      name: "Sarah Mohammed",
      avatarUrl: "https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200",
      comment: "Professional customer service and fast product delivery. Thank you to the Smart Store team!",
      rating: 5.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // مستمع لإعادة بناء زر الإرسال عند الكتابة
    _commentController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _reviews.insert(
        0,
        CustomerReview(
          name: "أنت",
          avatarUrl: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
          comment: _commentController.text.trim(),
          rating: 5.0,
        ),
      );
      _commentController.clear();
    });

    FocusScope.of(context).unfocus(); // إغلاق الكيبورد بعد الإرسال
  }

  @override
  Widget build(BuildContext context) {
    final bool isTyping = _commentController.text.trim().isNotEmpty;
    final ThemeData theme = Theme.of(context);

    return Column(
      spacing: 10,
      children: [
        TitleBar(title: "Customer Review"),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withOpacity(0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. شريط العنوان الأنيق
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What take about this product ?!",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    // متوسط التقييم الكلي كـ Badge
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 2. شريط التمرير الأفقي للبطاقات (Horizontal Scroll)
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.75,
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
                          // رأس البطاقة: الصورة والاسم والنجوم
                          Row(
                            children: [
                              CircleImage(imagePath:  review.avatarUrl,icon: Icons.person_2_outlined,radius: 15,),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.name,
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
                                          color: i < review.rating.floor() ? Colors.amber : Colors.grey.withOpacity(0.3),
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // نص التعليق المبتور بأناقة إذا طال
                          Expanded(
                            child: Text(
                              review.comment,
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
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 3. حقل إضافة تعليق العائم والمتكامل
              _buildMessageInput(),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildMessageInput() {
    final bool isTyping = _commentController.text.trim().isNotEmpty;
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
                            SizedBox(width: 10,),
                            Expanded(
                              child: TextField(
                                controller: _commentController,

                                maxLines: null,

                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 14,
                                ),

                                decoration: InputDecoration(
                                  hintText: "اكتب تعليقك هنا...",

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

                        end: 7,

                        child: GestureDetector(
                          onTap: isTyping
                              ?  _submitReview
                              : null,

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

                              boxShadow: isTyping
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

                              child: isTyping
                                  ? const Icon(
                              Icons.send_rounded,
                              key: ValueKey('send_review_active'),
                              color: Colors.white,
                              size: 16,
                            )
                                : const Icon(
                            Icons.add_circle_outline_outlined,
                            key: ValueKey('review_inactive'),
                            color: Colors.white,
                            size: 16,
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
