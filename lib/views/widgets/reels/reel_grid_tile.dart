import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/compact_count.dart';
import '../../../core/utils/reels_cache_helper.dart';
import '../../../data/models/video_model.dart';

class ReelGridTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ReelGridTile({super.key, required this.video, required this.onTap, this.onRemove});

  static const _shadow = [Shadow(color: Colors.black54, blurRadius: 6)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            video.productImage != null
                ? CachedNetworkImage(
              imageUrl: video.productImage!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.baseColor,
                highlightColor: AppColors.highlightColor,
                child: Container(color: Colors.white),
              ),
              // عند فشل الصورة نعرض لقطة من الفيديو
              errorWidget: (_, __, ___) => _VideoFrame(url: video.videoUrl),
            )
                : _VideoFrame(url: video.videoUrl),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),

            const PositionedDirectional(
              top: 8,
              end: 8,
              child: Icon(CupertinoIcons.play_fill, color: Colors.white, size: 16, shadows: _shadow),
            ),

            // عدد المشاهدات
            PositionedDirectional(
              bottom: 8,
              start: 8,
              child: Row(
                children: [
                  const Icon(CupertinoIcons.eye_fill, color: Colors.white, size: 14, shadows: _shadow),
                  const SizedBox(width: 4),
                  Text(
                    compactCount(video.viewsCount),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, shadows: _shadow),
                  ),
                ],
              ),
            ),

            if (onRemove != null)
              PositionedDirectional(
                top: 6,
                start: 6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.delete_simple, color: Colors.white, size: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// أول لقطة من الفيديو
class _VideoFrame extends StatefulWidget {
  final String url;
  const _VideoFrame({required this.url});

  @override
  State<_VideoFrame> createState() => _VideoFrameState();
}

class _VideoFrameState extends State<_VideoFrame> {
  VideoPlayerController? _c;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await ReelsCacheHelper.controllerFor(widget.url);
    try {
      await c.initialize();
      await c.setVolume(0);
    } catch (_) {}
    if (_disposed) {
      c.dispose();
      return;
    }
    setState(() => _c = c);
  }

  @override
  void dispose() {
    _disposed = true;
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null || !c.value.isInitialized) {
      return ColoredBox(
        color: AppColors.backgroundSecondary,
        child: Center(child: Icon(CupertinoIcons.film, color: AppColors.textSecondary)),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
    );
  }
}