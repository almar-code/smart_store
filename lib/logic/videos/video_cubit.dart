import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/video_model.dart';
import 'video_state.dart';
import '../../data/repos/video_repo.dart';

class VideoCubit extends Cubit<VideoState> {
  final VideoRepo repo;

  VideoCubit(this.repo) : super(VideoInitial());

  // جلب كافة الفيديوهات وتحديث حالة الشاشة
  Future<void> getAllVideos() async {
    emit(VideoLoading());
    try {
      final videos = await repo.getVideos();
      if (videos.isEmpty) {
        emit(VideoEmpty());
      } else {
        emit(VideoLoaded(videos));
      }
    } catch (e) {
      emit(VideoError('فشل في تحميل الفيديوهات'));
    }
  }

  // إرسال الإعجاب
  Future<void> toggleLikeOnServer(int videoId, bool isLikedNow) async {
    try {
      await repo.toggleLike(videoId, isLikedNow);
      print("تم تحديث الإعجاب بنجاح في قاعدة البيانات");
    } catch (e) {
      print("خطأ أثناء تحديث الإعجاب: $e");
    }
  }

  // إرسال المشاركة
  Future<void> incrementShareOnServer(int videoId) async {
    try {
      await repo.incrementShare(videoId);
      print("تم زيادة عداد المشاركة في قاعدة البيانات");
    } catch (e) {
      print("خطأ في عداد المشاركة: $e");
    }
  }

  // إرسال الحفظ
  Future<void> toggleSaveOnServer(int videoId) async {
    try {
      await repo.toggleSave(videoId);
      print("تم زيادة عداد الحفظ في قاعدة البيانات");
    } catch (e) {
      print("خطأ في عداد الحفظ: $e");
    }
  }
  // داخل كلاس VideoCubit في ملف video_cubit.dart

  void reorderVideosToMakeTargetFirst(int targetVideoId) {
    // التحقق أولاً من أن الحالة الحالية loaded وبها بيانات
    if (state is VideoLoaded) {
      final currentVideos = (state as VideoLoaded).videos;

      // 1. إنشاء نسخة جديدة تماماً من القائمة لتجنب مشاكل المراجع بالذاكرة
      List<VideoModel> reorderedList = List<VideoModel>.from(currentVideos);

      // 2. العثور على مؤشر (index) الفيديو الذي ضغط عليه المستخدم
      int targetIndex = reorderedList.indexWhere((v) => v.videoId == targetVideoId);

      // 3. إذا تم العثور على الفيديو وليس هو الأول بالفعل
      if (targetIndex != -1 && targetIndex != 0) {
        // سحب كائن الفيديو من مكانه القديم
        final targetVideo = reorderedList.removeAt(targetIndex);

        // إدراجه في مقدمة المصفوفة (الـ Index رقم 0)
        reorderedList.insert(0, targetVideo);

        // 4. بث القائمة المرتبة الجديدة فوراً لشاشة الـ Reels
        emit(VideoLoaded(reorderedList));
      }
    }
  }

}