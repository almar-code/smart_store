import 'package:flutter_bloc/flutter_bloc.dart';
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
}