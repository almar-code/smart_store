import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/data/models/video_model.dart';
import 'package:smart_store/views/screens/reels/reels_screen.dart';
import 'package:smart_store/views/widgets/flash/flash_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/widgets/buttons/add_to_cart_button.dart';
import '../../../core/widgets/heart_overlay_notifier.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/colors/colors_cubit.dart';
import '../../../logic/image/product_image_cubit.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/size/size_cubit.dart';
import '../../../logic/videos/video_cubit.dart';
import '../../screens/favorites/favorites_screen.dart';


class ProductImageSlider extends StatelessWidget {
  final List<String> images;
  const ProductImageSlider({super.key, required this.images});

  static const double _height = 230;
  static const double _gap = 10;
  static const double _maxItemWidth = 150;

  String _url(String path) =>
      path.startsWith('http') ? path : ApiEndpoints.productImageUrl(path);

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // العرض المتاح من الأب وليس من الشاشة
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // ثلث المساحة بعد طرح 4 مسافات، بحد أقصى للشاشات الكبيرة
        final double itemWidth =
        ((maxWidth - _gap * 4) / 3).clamp(0.0, _maxItemWidth);

        return SizedBox(
          width: maxWidth,
          height: _height,
          child: images.length > 3
              ? _buildScroll(itemWidth,context)
              : _buildFixed(itemWidth),
        );
      },
    );
  }

  // 1 إلى 3 صور: مسافات متساوية قبل وبين وبعد الصور
  Widget _buildFixed(double itemWidth) {
    return Stack(
      children: [
        // خلفية من أول صورة عند صورة أو صورتين
        if (images.length <= 2) Positioned.fill(child: _background()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: images
              .map((path) => _imageCard(path, itemWidth))
              .toList(),
        ),
      ],
    );
  }

  // أكثر من 3 صور: تمرير أفقي مع ظهور جزء من الصورة التالية
  Widget _buildScroll(double itemWidth,BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: context.locale.languageCode == 'ar' ?EdgeInsets.only(left: _gap) : EdgeInsets.only(right: _gap),
      itemCount: images.length,
      separatorBuilder: (_, __) => const SizedBox(width: _gap),
      itemBuilder: (context, index) =>
          _imageCard(images[index], itemWidth * 0.9),
    );
  }

  Widget _background() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _url(images.first),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Colors.transparent),
          ),
          Container(color: Colors.white.withValues(alpha: 0.40)),
        ],
      ),
    );
  }

  Widget _imageCard(String path, double width) {
    return Container(
      width: width,
      height: _height,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _url(path),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
          progress == null ? child : Center(child: ThreeDotsLoader()),
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/image_placeholder.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
class ProductImageGallery extends StatelessWidget {
  final List<String> images;
  final int? videoID;
  const ProductImageGallery({super.key, required this.images,this.videoID});

  @override
  Widget build(BuildContext context) {
    // تأمين القائمة في حال كانت فارغة
    final List<String> galleryImages = images.isNotEmpty ? images : [''];

    return BlocProvider<GalleryIndexCubit>(
      create: (_) => GalleryIndexCubit(),
      child: BlocListener<DialogProductCubit, ColorModel>(
        listener: (context, selectedColor) {
          // بمجرد أن يغير المستخدم اللون، نقوم بتصفير مؤشر المعرض فوراً للعودة للصورة الأولى
          context.read<GalleryIndexCubit>().changeIndex(0);
        },
        child: BlocBuilder<GalleryIndexCubit, int>(
          builder: (context, selectedIndex) {
            // تأمين الـ index لضمان عدم حدوث خطأ أثناء لحظة التحويل العابرة
            final int safeIndex = selectedIndex < galleryImages.length ? selectedIndex : 0;
            final String mainImagePath = galleryImages[safeIndex];

            return Column(
              spacing: 10,
              children: [
                // 1️⃣ الصورة الرئيسية الكبيرة
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: mainImagePath.startsWith('http')
                                ? mainImagePath
                                : ApiEndpoints.productImageUrl(mainImagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            // مؤشر التحميل أثناء جلب الصورة لأول مرة
                            placeholder: (context, url) => ImageProduct(
                              height: double.infinity,
                            ),
                            // في حال فشل التحميل أو عدم توفر إنترنت
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/image_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      videoID != null ? PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: AppIcon(
                          icon: Icons.video_library_outlined,
                          color: AppColors.primary,
                          onPressed: () {
                            int? selectedVideoId = videoID;
                            if(selectedVideoId != null){
                              context.read<VideoCubit>().reorderVideosToMakeTargetFirst(selectedVideoId);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SafeArea(
                                    child: ReelScreen(
                                      pageIndex: 2,
                                      isProductDetails: true,
                                    ),
                                  ),
                                ),
                              );
                            }

                          },
                        ),
                      ) : SizedBox()
                    ],
                  ),
                ),

                // 2️⃣ الشريط السفلي للصور المصغرة (Thumbnails)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: galleryImages.length,
                    itemBuilder: (context, index) {
                      bool isSelected = safeIndex == index;
                      final String thumbPath = galleryImages[index];

                      return InkWell(
                        onTap: () {
                          context.read<GalleryIndexCubit>().changeIndex(index);
                        },
                        child: Container(
                          width: 45,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: isSelected ? 2 : 0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(index < 3 ? 6 : 8), // تناسق الحواف مع الـ Border
                            child: CachedNetworkImage(
                              imageUrl: thumbPath.startsWith('http')
                                  ? thumbPath
                                  : ApiEndpoints.productImageUrl(thumbPath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              // مؤشر التحميل باستخدام الثلاث نقاط الصغيرة
                              placeholder: (context, url) => ImageProduct(
                                width: 40,
                              ),
                              // في حال فشل التحميل أو انقطاع الإنترنت
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/image_placeholder.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
class ProductColorSelector extends StatelessWidget {
  final List<ColorModel> colors;
  const ProductColorSelector({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    // الاستماع للون المختار حالياً من الكوبيت لإظهار حدود التحديد
    final selectedColor = context.watch<DialogProductCubit>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: colors.map((color) {
          final bool isSelected = selectedColor.colorId == color.colorId;
          final parsedColor = AppColors.hexToColor(color.colorCode ?? "#000000");

          // 🌟 التحقق من توفر صور لهذا اللون بالتحديد
          final bool hasImage = color.images.isNotEmpty && color.images.first.imgUrl.isNotEmpty;
          final String? firstImageUrl = hasImage ? color.images.first.imgUrl : null;

          return GestureDetector(
            onTap: () {
              // ضخ اللون المختار بداخل الكوبيت لتحديث الواجهة وصور الـ Slider الرئيسية
              context.read<DialogProductCubit>().selectColor(color);
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // إظهار حدود التحديد حول الدائرة النشطة بناءً على التصميم الأول والأخير
                border: Border.all(
                  color: isSelected ? parsedColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: parsedColor.withOpacity(0.3),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: parsedColor, // اللون الافتراضي في الخلفية إذا لم تتوفر صورة
                child: hasImage
                    ? ClipOval(
                  child: Image.network(
                    // بناء رابط الصورة الكامل المرفوع على سيرفر لارافيل
                    firstImageUrl!.startsWith('http')
                        ? firstImageUrl
                        : ApiEndpoints.productImageUrl(firstImageUrl),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    // 🌟 معامل الأمان: في حال فشل تحميل الصورة من السيرفر لأي سبب، يعود ليعرض لون الدائرة الأصلي
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: parsedColor);
                    },
                  ),
                )
                    : null, // إذا لم تكن هناك صورة أصلاً، سيبقى الـ backgroundColor للـ CircleAvatar ظاهراً
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ProductSizeSelector extends StatelessWidget {
  final List<SizeModel> sizes;
  const ProductSizeSelector({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    // 🌟 مراقبة الكوبيت لمعرفة المقاس المختار حالياً (يمكن أن يكون null)
    final selectedSize = context.watch<DialogSizeCubit>().state;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: sizes.map((size) {
          // 🌟 فحص ما إذا كان هذا المقاس هو المختار حالياً
          // نقارن بالـ sizeId لضمان دقة الاختيار
          final bool isSelected = selectedSize?.sizeId == size.sizeId;

          return InkWell(
            onTap: () {
              // 🚀 عند الضغط، نقوم بضخ كائن المقاس المختار بداخل الكوبيت
              context.read<DialogSizeCubit>().selectSize(size);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), // أنيميشن سلس أثناء الانتقال
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                // يتغير لون الخلفية قليلاً إذا تم الاختيار أو يظل افتراضياً
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: AppShadow.commonShadow,
                // 🌟 تغيير البوردر بشكل كامل بناءً على حالة الاختيار
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderColor.withOpacity(0.2),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Text(
                size.sizeName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  // تغيير لون النص ليصبح متناسقاً مع البوردر النشط
                  color: isSelected ? AppColors.primary : AppColors.textColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}



class ProductActionActions extends StatefulWidget {
  final ProductModel product;
  const ProductActionActions({super.key, required this.product});

  @override
  State<ProductActionActions> createState() => _ProductActionActionsState();
}

class _ProductActionActionsState extends State<ProductActionActions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: AppColors.textSecondary)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onLongPress: () =>Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen(screenOnly: true))),

            onTap: () {
              // 🚀 تحديث حالة الواجهة محلياً فوراً وبشكل لحظي أمام العميل
              setState(() {
                widget.product.isFavorite ? HeartOverlayNotifier.show(context, isLike: false) : HeartOverlayNotifier.show(context, isLike: true);
              });

              // إرسال الأوامر للـ Cubit ليقوم بالمزامنة مع الـ Event Bus والسيرفر
              context.read<ProductCubit>().toggleProductFavorite(
                customerId: 1,
                product: widget.product,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.product.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: widget.product.isFavorite ? Colors.red : AppColors.iconColor,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: AddToCartButton()),
        ],
      ),
    );
  }
}
