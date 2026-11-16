import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/reels_cache_helper.dart';
import '../../../data/models/video_model.dart';
import 'reel_item.dart';

class ReelsFeed extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;
  final bool isActive;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final double bottomInset;

  const ReelsFeed({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.isActive = true,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.bottomInset = 16,
  });

  @override
  State<ReelsFeed> createState() => _ReelsFeedState();
}

class _ReelsFeedState extends State<ReelsFeed> with WidgetsBindingObserver {
  late final PageController _pageController;
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _preparing = {};
  late int _current;
  bool _appActive = true;
  bool _routeActive = true;
  final Set<int> _failed = {};
  bool get _canPlay => widget.isActive && _appActive && _routeActive;

  @override
  void initState() {
    super.initState();
    _current = widget.videos.isEmpty ? 0 : widget.initialIndex.clamp(0, widget.videos.length - 1);
    _pageController = PageController(initialPage: _current);
    WidgetsBinding.instance.addObserver(this);
    _warmUp();
  }

  // ايقاف عند فتح صفحة فوق الريلز
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = ModalRoute.of(context)?.isCurrent ?? true;
    if (active != _routeActive) {
      _routeActive = active;
      _syncPlayback();
    }
  }

  @override
  void didUpdateWidget(covariant ReelsFeed old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) _syncPlayback();
    if (old.videos.length != widget.videos.length) _warmUp();
  }

  // ايقاف عند الخروج من التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    _syncPlayback();
    if (mounted) setState(() {});
  }

  void _onPageChanged(int index) {
    _current = index;
    _warmUp();
    _syncPlayback(resetOthers: true);
    if (index >= widget.videos.length - 3) widget.onLoadMore?.call();
    setState(() {});
  }

  // تجهيز المجاور وتنزيل التالي
  void _warmUp() {
    for (final i in [_current, _current + 1, _current - 1]) {
      _prepare(i);
    }
    for (var i = _current + 2; i <= _current + 4 && i < widget.videos.length; i++) {
      ReelsCacheHelper.preload(widget.videos[i].videoUrl);
    }
    _disposeFar();
  }

  bool _inWindow(int id) {
    for (var i = _current - 1; i <= _current + 1; i++) {
      if (i >= 0 && i < widget.videos.length && widget.videos[i].videoId == id) return true;
    }
    return false;
  }

  Future<void> _prepare(int index) async {

    if (index < 0 || index >= widget.videos.length) return;
    final video = widget.videos[index];
    final id = video.videoId;
    if (_controllers.containsKey(id) || _failed.contains(id) || !_preparing.add(id)) return;
    final controller = await ReelsCacheHelper.controllerFor(video.videoUrl);
    var ok = true;
    try {
      await controller.initialize().timeout(const Duration(seconds: 20));
      await controller.setLooping(true);
    } catch (_) {
      ok = false;
    }
    _preparing.remove(id);

    // فشل او خرج من النطاق
    if (!mounted || !ok || !_inWindow(id)) {
      controller.dispose();
      if (mounted && !ok) setState(() => _failed.add(id));
      return;
    }
    setState(() => _controllers[id] = controller);
    _syncPlayback();
  }

  // اعادة المحاولة
  void _retry(int index) {
    setState(() => _failed.remove(widget.videos[index].videoId));
    _prepare(index);
  }

  // حذف المشغلات البعيدة لتوفير الذاكرة
  void _disposeFar() {
    final far = _controllers.keys.where((id) => !_inWindow(id)).toList();
    for (final id in far) {
      final c = _controllers.remove(id);
      WidgetsBinding.instance.addPostFrameCallback((_) => c?.dispose());
    }
  }

  void _syncPlayback({bool resetOthers = false}) {
    if (!mounted || widget.videos.isEmpty) return;
    final currentId = widget.videos[_current].videoId;

    _controllers.forEach((id, c) {
      if (!c.value.isInitialized) return;
      if (id == currentId) {
        _canPlay ? c.play() : c.pause();
      } else {
        c.pause();
        if (resetOthers) {
          c.seekTo(Duration.zero);
          c.setPlaybackSpeed(1);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemCount: widget.videos.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {

            final video = widget.videos[index];
            return ReelItem(
              key: ValueKey(video.videoId),
              video: video,
              controller: _controllers[video.videoId],
              isCurrent: index == _current && _canPlay,
              bottomInset: widget.bottomInset,
              hasError: _failed.contains(video.videoId),
              onRetry: () => _retry(index),
            );
          },
        ),

        // تحميل الدفعة التالية
        if (widget.isLoadingMore && _current >= widget.videos.length - 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: widget.bottomInset,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primary,
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }
}