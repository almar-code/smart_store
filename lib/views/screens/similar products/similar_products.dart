import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/widgets/circularProgress.dart';
import '../../../core/widgets/scroll_wrapper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../data/repos/product_repo.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/product/all_products.dart';
import 'package:flutter/foundation.dart'; // للتحقق من kIsWeb
class _ScanningEffectWidget extends StatefulWidget {
  const _ScanningEffectWidget();

  @override
  State<_ScanningEffectWidget> createState() => _ScanningEffectWidgetState();
}

class _ScanningEffectWidgetState extends State<_ScanningEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // حركة ذهاب وإياب مستمرة فوق الصورة
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * 160, // يتحرك صعوداً وهبوطاً داخل حدود الصورة
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.cyanAccent.withOpacity(0.8),
                  Colors.white,
                  Colors.cyanAccent.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class SimilarProducts extends StatelessWidget {
  final String imagePath; // الصورة المرسلة (سواء من المعرض أو رابط المنتج)
  final Uint8List? imageBytes; // الصورة بعد التحويل للارسال

  const SimilarProducts({super.key, required this.imagePath, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocProvider(
      create: (context) => ProductCubit(repository: di.sl<ProductRepo>())
        ..fetchProducts(
          isRefresh: true,
          visualImageBytes: imageBytes,
          visualImagePath: imagePath, // 🌟 تمرير الصورة هنا للبحث البصري
        ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Icon(
              Icons.center_focus_strong_outlined,
              size: isDesktop ? 25 : 21,
              color: AppColors.iconColor,
            ),
            titleSpacing: 0,
            title: AppTitle(
              firstPart: tr('similar'),
              secondPart: tr('products'),
              fontSize: isDesktop ? 18 : 15,
              spacing: ' ',
            ),
            actions: const [ArrowBack(), SizedBox(width: 6)],
          ),
          body: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              bool isAnalyzing = state is ProductLoading;

              return Stack(
                children: [
                  // المحتوى الأساسي (صورة الولد والمنتجات)
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.gradientTop, AppColors.gradientBottom],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SimilarProductsHeader(uploadedImagePath: imagePath),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, -6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 45,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                                        child: ScrollWrapper(
                                          bottom: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                            child: AllProducts(),
                                          ),
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
                  ),

                  // 🌟 الطبقة الزجاجية الشفافة وتأثير التحليل أثناء جلب البيانات (محدثة بشكل آمن للويب)
                  if (isAnalyzing)
                    Container(
                      color: Colors.black.withOpacity(0.5), // تعتيم خلفية الشاشة بالكامل
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 🌟 التصحيح هنا باستخدام blur
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1), // شَفافية زجاجية ناعمة
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 🌟 الحاوية الكبيرة للصورة مع تأثير المسح الضوئي المتحرك
                                  Container(
                                    width: 180, // تكبير عرض الصورة قليلاً
                                    height: 190, // تكبير ارتفاع الصورة قليلاً
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // عرض الصورة الأساسية (سواء ويب، رابط، أو ملف محلي)
                                          (kIsWeb || imagePath.startsWith('http') || imagePath.startsWith('blob:'))
                                              ? Image.network(
                                            imagePath, // إذا كان رابط كامل أو مسار شبكي
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                color: AppColors.background,
                                                width: 180,
                                                height: 190, // الارتفاع المخصص لحجم الحاوية في الهيدر لديك
                                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)), // أو ThreeDotsLoader()
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return _buildFakeImage();
                                            },
                                          )
                                              : Image.file(
                                            File(imagePath),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return _buildFakeImage();
                                            },
                                          ),

                                          // 🌟 تأثير التموج الضوئي أو الخط المتحرك للمسح فوق الصورة مباشرة
                                          const _ScanningEffectWidget(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // نص توضيحي تفاعلي بخط أنيق
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgress()
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        tr('analyzing_image_similar'), // جاري تحليل الصورة وإيجاد المنتجات المشابهة...
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [SmartFloatingButton(), CartFloatingButton()],
          ),
        ),
      ),
    );
  }

}

class SimilarProductsHeader extends StatelessWidget {
  final String? uploadedImagePath;

  const SimilarProductsHeader({super.key, required this.uploadedImagePath});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Center(
      child: SizedBox(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/delivery_boy.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 94,
                  left: 43,
                  child: Container(
                    width: 95,
                    height: 102,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImageWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (uploadedImagePath == null || uploadedImagePath!.isEmpty) {
      return _buildFakeImage();
    }

    // إذا كانت الصورة على الويب أو عبارة عن رابط شبكي (URL)
    if (kIsWeb || uploadedImagePath!.startsWith('http')) {
      return Image.network(
        uploadedImagePath!, // إذا كان رابط كامل أو مسار شبكي
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: AppColors.background,
            width: double.infinity,
            height: 102, // الارتفاع المخصص لحجم الحاوية في الهيدر لديك
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)), // أو ThreeDotsLoader()
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFakeImage();
        },
      );
    } else {
      // إذا كانت ملفاً محلياً على الموبايل (من الكاميرا أو المعرض)
      return Image.file(
        File(uploadedImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFakeImage();
        },
      );
    }
  }

// دالة الصورة الوهمية الاحتياطية

}
Widget _buildFakeImage() {
  return Image.asset(
    'assets/images/image_placeholder.png', // تأكد من توفر مسار الصورة أو تعديله حسب مشروعك
    fit: BoxFit.cover,
  );
}