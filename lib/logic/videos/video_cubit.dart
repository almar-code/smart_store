import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../core/utils/reels_cache_helper.dart';
import '../../data/local/reels_local.dart';
import '../../data/models/video_model.dart';
import '../../data/repos/video_repo.dart';
import 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  final VideoRepo repo;

  VideoCubit(this.repo) : super(VideoInitial());

  final List<VideoModel> _videos = [];
  int _page = 1;
  int _seed = 1;
  int _version = 0;

  // نفس الخلطة الاخيرة لقراءة الريلز المحفوظة بدون نت
  static const String _seedKey = 'last_reels_seed';
  Box get _box => Hive.box('reels_box');

  // الدفعة الأولى، silent للتحديث بالسحب
  Future<void> getAllVideos({bool silent = false}) async {
    if (!silent || state is! VideoLoaded) emit(VideoLoading());
    _page = 1;
    _seed = Random().nextInt(100000);

    try {
      final page = await repo.getVideos(page: 1, seed: _seed);
      // حفظ الخلطة لاستخدامها بدون نت
      _box.put(_seedKey, _seed);
      _emitPage(page, offline: false);
      // تنزيل اول الفيديوهات مسبقا ليشاهدها بدون نت
      for (final v in _videos.take(4)) {
        ReelsCacheHelper.preload(v.videoUrl);
      }
    } catch (_) {
      // بدون نت: نقرأ اخر ريلز محفوظة بنفس الخلطة السابقة
      final int? lastSeed = _box.get(_seedKey);
      if (lastSeed != null) {
        try {
          _seed = lastSeed;
          final page = await repo.getVideos(page: 1, seed: lastSeed);
          await _emitPage(page, offline: true);
          return;
        } catch (_) {}
      }
      if (state is! VideoLoaded) emit(VideoError(tr('reels_load_error')));
    }
  }

  // عرض الدفعة وفي حالة عدم الاتصال نعرض فقط الفيديوهات المنزلة على الجهاز
  Future<void> _emitPage(VideoPage page, {required bool offline}) async {
    List<VideoModel> list = List<VideoModel>.of(page.videos);
    if (offline) {
      final available = <VideoModel>[];
      for (final v in list) {
        if (await ReelsCacheHelper.isCached(v.videoUrl)) available.add(v);
      }
      list = available;
    }

    _videos
      ..clear()
      ..addAll(list);
    _version++;

    if (_videos.isEmpty) return emit(VideoEmpty());

    emit(VideoLoaded(
      videos: List.of(_videos),
      // بدون نت لا نطلب دفعات اضافية
      hasMore: offline ? false : page.hasMore,
      total: page.total,
      totalViews: page.totalViews,
      totalLikes: page.totalLikes,
      version: _version,
    ));
  }

  // الدفعة التالية
  Future<void> loadMore() async {
    final s = state;
    if (s is! VideoLoaded || !s.hasMore || s.isLoadingMore) return;

    emit(s.copyWith(isLoadingMore: true));
    try {
      final page = await repo.getVideos(page: _page + 1, seed: _seed);
      _page++;
      final ids = _videos.map((v) => v.videoId).toSet();
      _videos.addAll(page.videos.where((v) => !ids.contains(v.videoId)));
      emit(s.copyWith(videos: List.of(_videos), hasMore: page.hasMore, isLoadingMore: false));
    } catch (_) {
      emit(s.copyWith(isLoadingMore: false));
    }
  }

  // قائمة تبدأ بريل محدد
  Future<List<VideoModel>> videosStartingWith(int videoId) async {
    final list = List.of(_videos);
    final index = list.indexWhere((v) => v.videoId == videoId);

    if (index != -1) {
      list.insert(0, list.removeAt(index));
      return list;
    }
    try {
      return [await repo.getVideo(videoId), ...list];
    } catch (_) {
      return list;
    }
  }

  // ===== التفاعل =====
  Future<void> toggleLike(VideoModel video) async {
    video.isLiked = !video.isLiked;
    video.likesCount += video.isLiked ? 1 : -1;
    await ReelsLocal.setLiked(video.videoId, video.isLiked);
    repo.toggleLike(video.videoId, video.isLiked).catchError((_) {});
  }

  // يرجع true اذا تم الحفظ
  Future<bool> toggleSave(VideoModel video) async {
    final saved = await ReelsLocal.toggleSave(video);
    _syncSaved(video.videoId, saved);
    video.isSaved = saved;
    repo.toggleSave(video.videoId, saved).catchError((_) {});
    return saved;
  }

  Future<void> clearSaved() async {
    for (final v in ReelsLocal.savedVideos()) {
      repo.toggleSave(v.videoId, false).catchError((_) {});
      _syncSaved(v.videoId, false);
    }
    await ReelsLocal.clearSaved();
  }

  void share(VideoModel video) {
    video.sharesCount++;
    repo.incrementShare(video.videoId).catchError((_) {});
  }

  void addView(VideoModel video) {
    video.viewsCount++;
    repo.addView(video.videoId).catchError((_) {});
  }

  // تحديث نسخة الريل في القائمة
  void _syncSaved(int id, bool saved) {
    for (final v in _videos.where((v) => v.videoId == id)) {
      if (v.isSaved != saved) v.savesCount += saved ? 1 : -1;
      v.isSaved = saved;
    }
  }
}