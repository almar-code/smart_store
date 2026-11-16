import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/ScrollToTopButton.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../data/repos/product_repo.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/product/all_products.dart';

class SimilarProducts extends StatefulWidget {
  final String imagePath; // رابط المنتج او مسار الصورة
  final Uint8List? imageBytes; // الصورة بعد التحويل

  const SimilarProducts({super.key, required this.imagePath, this.imageBytes});

  @override
  State<SimilarProducts> createState() => _SimilarProductsState();
}

class _SimilarProductsState extends State<SimilarProducts> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isAr = context.locale.languageCode == 'ar';

    return BlocProvider(
      create: (_) => ProductCubit(repository: di.sl<ProductRepo>())
        ..fetchProducts(
          isRefresh: true,
          visualImageBytes: widget.imageBytes,
          visualImagePath: widget.imagePath,
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
              firstPart: tr('first similar'),
              secondPart: tr('second similar'),
              fontSize: isDesktop ? 18 : 15,
              spacing: isAr ? ' ' : ' ',
            ),
            actions: const [ArrowBack(), SizedBox(width: 6)],
          ),
          body: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              return Stack(
                children: [
                  // المحتوى
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.gradientTop, AppColors.gradientBottom],
                      ),
                    ),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // صورة الولد تختفي مع التمرير
                        SliverPersistentHeader(
                          delegate: _HeaderDelegate(
                            imagePath: widget.imagePath,
                            imageBytes: widget.imageBytes,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TitleBar(title: tr('similar_products')),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                          sliver: SliverToBoxAdapter(child: AllProducts()),
                        ),
                      ],
                    ),
                  ),

                  PositionedDirectional(
                    bottom: 5,
                    start: 10,
                    child: ScrollToTopButton(scrollController: _scrollController),
                  ),

                  // طبقة التحليل أثناء البحث
                  if (state is ProductLoading)
                    _AnalyzingOverlay(imagePath: widget.imagePath, imageBytes: widget.imageBytes),
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

// ===================== رأس الصفحة المتقلص =====================
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final String imagePath;
  final Uint8List? imageBytes;

  _HeaderDelegate({required this.imagePath, this.imageBytes});

  @override
  double get maxExtent => 260;

  @override
  double get minExtent => 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // نسبة التقلص من 0 الى 1
    final t = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: maxExtent,
        maxHeight: maxExtent,
        child: Opacity(
          opacity: 1 - t,
          child: Transform.scale(
            scale: 1 - 0.25 * t,
            alignment: Alignment.bottomCenter,
            child: SimilarProductsHeader(uploadedImagePath: imagePath, imageBytes: imageBytes),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate old) =>
      old.imagePath != imagePath || old.imageBytes != imageBytes;
}

class SimilarProductsHeader extends StatelessWidget {
  final String? uploadedImagePath;
  final Uint8List? imageBytes;

  const SimilarProductsHeader({super.key, required this.uploadedImagePath, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/delivery_boy.png', height: 250, fit: BoxFit.contain),
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
                child: SearchImage(path: uploadedImagePath, bytes: imageBytes),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== صورة البحث =====================
class SearchImage extends StatelessWidget {
  final String? path;
  final Uint8List? bytes;

  const SearchImage({super.key, this.path, this.bytes});

  @override
  Widget build(BuildContext context) {
    // الصورة المحولة تعمل في الويب والجوال
    if (bytes != null) {
      return Image.memory(bytes!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fakeImage());
    }

    final p = path;
    if (p == null || p.isEmpty) return _fakeImage();

    if (kIsWeb || p.startsWith('http') || p.startsWith('blob:')) {
      return Image.network(
        p,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : ColoredBox(
          color: AppColors.background,
          child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgress())),
        ),
        errorBuilder: (_, __, ___) => _fakeImage(),
      );
    }

    return Image.file(File(p), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fakeImage());
  }

  Widget _fakeImage() => Image.asset('assets/images/image_placeholder.png', fit: BoxFit.cover);
}

// ===================== طبقة التحليل =====================
class _AnalyzingOverlay extends StatelessWidget {
  final String imagePath;
  final Uint8List? imageBytes;

  const _AnalyzingOverlay({required this.imagePath, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الصورة مع خط المسح
                  Container(
                    width: 180,
                    height: 190,
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
                          SearchImage(path: imagePath, bytes: imageBytes),
                          const _ScanningEffect(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgress()),
                      const SizedBox(width: 12),
                      Text(
                        tr('analyzing_image_similar'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

// خط المسح المتحرك فوق الصورة
class _ScanningEffect extends StatefulWidget {
  const _ScanningEffect();

  @override
  State<_ScanningEffect> createState() => _ScanningEffectState();
}

class _ScanningEffectState extends State<_ScanningEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
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
      builder: (context, child) => Positioned(
        top: _controller.value * 180,
        left: 0,
        right: 0,
        child: child!,
      ),
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
            BoxShadow(color: AppColors.primary.withOpacity(0.8), blurRadius: 8, spreadRadius: 2),
          ],
        ),
      ),
    );
  }
}