import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_store/core/widgets/circularProgress.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/compact_count.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../data/models/video_model.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/videos/video_cubit.dart';
import '../../screens/product/product_details_screen.dart';
import '../../screens/reels/store_profile.dart';
import '../flash/flash_screen.dart';
import 'reel_side_actions.dart';

const String storeLogo = "assets/images/Gemini_Generated_Image_ez61caez61caez61.png";

class ReelItem extends StatefulWidget {
  final VideoModel video;
  final VideoPlayerController? controller;
  final bool isCurrent;
  final double bottomInset;
  final bool hasError;
  final VoidCallback? onRetry;

  const ReelItem({
    super.key,
    required this.video,
    required this.controller,
    required this.isCurrent,
    this.bottomInset = 16,
    this.hasError = false,
    this.onRetry,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  final List<_Heart> _hearts = [];
  bool _viewCounted = false;
  bool _pausedByUser = false;
  bool _holdPause = false;
  bool _fast = false;
  String? _seekLabel;
  bool _seekRight = true;
  Timer? _seekTimer;
  Offset? _doubleTapPos;

  VideoPlayerController? get _c => widget.controller;
  bool get _ready => _c != null && _c!.value.isInitialized;

  @override
  void initState() {
    super.initState();
    _c?.addListener(_watchView);
  }

  @override
  void didUpdateWidget(covariant ReelItem old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_watchView);
      widget.controller?.addListener(_watchView);
    }
    // مشاهدة جديدة عند الرجوع للريل
    if (old.isCurrent && !widget.isCurrent) {
      _viewCounted = false;
      _pausedByUser = false;
      _fast = false;
    }
  }

  @override
  void dispose() {
    _c?.removeListener(_watchView);
    _seekTimer?.cancel();
    super.dispose();
  }

  // احتساب المشاهدة بعد ثانيتين
  void _watchView() {
    if (_viewCounted || !widget.isCurrent || !_ready) return;
    if (_c!.value.position >= const Duration(seconds: 2)) {
      _viewCounted = true;
      context.read<VideoCubit>().addView(widget.video);
    }
  }
  // ايقونة بديلة للصورة
  Widget _productIcon() => Container(
    width: 44,
    height: 44,
    color: Colors.white24,
    child: const Icon(CupertinoIcons.bag, color: Colors.white),
  );

  bool _isEdge(double dx, double width) => dx < width * 0.25 || dx > width * 0.75;

  void _togglePlay() {
    if (!_ready) return;
    setState(() {
      if (_c!.value.isPlaying) {
        _c!.pause();
        _pausedByUser = true;
      } else {
        _c!.play();
        _pausedByUser = false;
      }
    });
  }

  void _onDoubleTap(double width) {
    final pos = _doubleTapPos;
    if (pos == null) return;
    if (pos.dx < width * 0.25) return _seek(-5);
    if (pos.dx > width * 0.75) return _seek(5);
    _likeAt(pos);
  }

  void _seek(int seconds) {
    if (!_ready) return;
    final value = _c!.value;
    var target = value.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > value.duration) target = value.duration;
    _c!.seekTo(target);

    _seekTimer?.cancel();
    setState(() {
      _seekLabel = seconds > 0 ? '+5s' : '-5s';
      _seekRight = seconds > 0;
    });
    _seekTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _seekLabel = null);
    });
  }

  // القلب يظهر مكان الاصبع
  void _likeAt(Offset pos) {
    final id = DateTime.now().microsecondsSinceEpoch;
    if (!widget.video.isLiked) context.read<VideoCubit>().toggleLike(widget.video);
    setState(() => _hearts.add(_Heart(id, pos)));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _hearts.removeWhere((h) => h.id == id));
    });
  }

  void _onHoldStart(double dx, double width) {
    if (!_ready) return;
    if (_isEdge(dx, width)) {
      _c!.setPlaybackSpeed(2);
      setState(() => _fast = true);
    } else if (_c!.value.isPlaying) {
      _c!.pause();
      setState(() => _holdPause = true);
    }
  }

  void _onHoldEnd() {
    if (!_ready) return;
    if (_fast) _c!.setPlaybackSpeed(1);
    if (_holdPause) _c!.play();
    setState(() {
      _fast = false;
      _holdPause = false;
    });
  }

  void _openProduct() {
    final product = context
        .read<ProductCubit>()
        .allProducts
        .where((p) => p.pId == widget.video.productId)
        .firstOrNull;

    if (product == null) {
      AppToasts.showErrorToast(context, tr('product_not_available'));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;

        return Stack(
          fit: StackFit.expand,
          children: [
            // الفيديو
            ColoredBox(
              color: Colors.black,
              child: _ready
                  ? FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _c!.value.size.width,
                  height: _c!.value.size.height,
                  child: VideoPlayer(_c!),
                ),
              )
                  : _placeholder(),
            ),

            // تدرج لوضوح النصوص
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.15, 0.6, 1],
                    colors: [Colors.black38, Colors.transparent, Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),

            // طبقة اللمس
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlay,
              onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
              onDoubleTap: () => _onDoubleTap(width),
              onLongPressStart: (d) => _onHoldStart(d.localPosition.dx, width),
              onLongPressEnd: (_) => _onHoldEnd(),
            ),

            // ايقونة التشغيل
            if (_ready && _pausedByUser)
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 34),
                  ),
                ),
              ),

            // قلوب اللايك
            ..._hearts.map(
                  (h) => Positioned(
                left: h.pos.dx - 50,
                top: h.pos.dy - 50,
                child: const IgnorePointer(child: _HeartBurst()),
              ),
            ),

            // التقديم والرجوع
            if (_seekLabel != null)
              Align(
                alignment: _seekRight ? Alignment.centerRight : Alignment.centerLeft,
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _Bubble(
                      icon: _seekRight ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                      text: _seekLabel!,
                    ),
                  ),
                ),
              ),

            // السرعة
            if (_fast)
              const Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: IgnorePointer(child: Center(child: _Bubble(icon: Icons.speed_rounded, text: '2x'))),
              ),

            // الأزرار والمعلومات تختفي أثناء الضغط المطول
            AnimatedOpacity(
              opacity: _holdPause ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  PositionedDirectional(
                    end: 8,
                    bottom: widget.bottomInset + 60,
                    child: ReelSideActions(video: widget.video),
                  ),
                  PositionedDirectional(
                    start: 14,
                    end: 76,
                    bottom: widget.bottomInset + 20,
                    child: _info(lang),
                  ),
                ],
              ),
            ),

            // شريط التقدم: دائما من اليسار لليمين
            if (_ready)
              Positioned(
                left: 0,
                right: 0,
                bottom: widget.bottomInset,
                child: Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: SizedBox(
                    height: 14,
                    child: VideoProgressIndicator(
                      _c!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.only(top: 11),
                      colors: VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Shimmer اثناء التحميل او زر اعادة المحاولة
  Widget _placeholder() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const VideoLoadingShimmer(),
        Center(
          child: widget.hasError
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.white70, size: 40),
              const SizedBox(height: 10),
              Text(tr('video_load_error'), style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              SizedBox(height: 34, width: 130, child: RefreshButton(onPressed: widget.onRetry ?? () {})),
            ],
          )
              : const CircularProgress(),
        ),
      ],
    );
  }

  Widget _info(String lang) {
    final v = widget.video;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // المتجر وعدد المشاهدات
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StoreProfile(isAppBar: true)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleImage(imagePath: storeLogo, radius: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Nice Store',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(width: 10),
              const Icon(CupertinoIcons.eye, color: Colors.white70, size: 14),
              const SizedBox(width: 3),
              Text(
                compactCount(v.viewsCount),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),

        // بطاقة المنتج
        if (v.productId != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _openProduct,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: v.productImage == null
                            ? _productIcon()
                            : CachedNetworkImage(
                          imageUrl: v.productImage!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppColors.baseColor,
                            highlightColor: AppColors.highlightColor,
                            child: Container(width: 44, height: 44, color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => _productIcon(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              v.productTitle(lang) ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tr('view_product'),
                              style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(CupertinoIcons.bag_fill, color: Colors.white, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Heart {
  final int id;
  final Offset pos;
  _Heart(this.id, this.pos);
}

// حركة القلب: تكبير ثم صعود وتلاشي
class _HeartBurst extends StatelessWidget {
  const _HeartBurst();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      builder: (_, t, child) {
        final scale = t < 0.3 ? Curves.easeOutBack.transform(t / 0.3) * 1.2 : 1.2 - (t - 0.3) * 0.3;
        final opacity = t < 0.6 ? 1.0 : 1 - (t - 0.6) / 0.4;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -30 * t),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: const SizedBox(
        width: 100,
        height: 100,
        child: Icon(
          CupertinoIcons.heart_fill,
          color: Color(0xFFFF3B5C),
          size: 90,
          shadows: [Shadow(color: Colors.black26, blurRadius: 12)],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bubble({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}