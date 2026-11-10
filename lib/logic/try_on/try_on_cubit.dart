import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/try_on_model.dart';
import '../../data/repos/try_on_repo.dart';
import 'try_on_state.dart';

class TryOnCubit extends Cubit<TryOnState> {
  final TryOnRepo repo;

  TryOnCubit(this.repo) : super(const TryOnState());

  /// 1️⃣ تنزيل صورة العباية في الخلفية فور فتح الشاشة
  Future<void> loadGarment(String imageUrl) async {
    emit(state.copyWith(isGarmentLoading: true));
    try {
      final bytes = await repo.downloadGarment(imageUrl);
      emit(state.copyWith(garmentImage: bytes, isGarmentLoading: false));
    } on TryOnException catch (e) {
      print('الخطاffffffffff  e.translationKey');
      emit(state.copyWith(isGarmentLoading: false, status: TryOnStatus.error, errorKey: e.translationKey));
    }
  }

  /// 2️⃣ اختيار صورة العميلة من الكاميرا أو المعرض
  Future<void> pickPersonImage(ImageSource source) async {
    final XFile? file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024, // تصغير الصورة لتسريع الرفع والمعالجة
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    emit(state.copyWith(personImage: bytes, status: TryOnStatus.initial, clearResult: true));
  }

  /// تغيير نوع القطعة
  void changeClothType(String type) {
    if (state.isLoading) return;
    emit(state.copyWith(clothType: type, status: TryOnStatus.initial));
  }

  /// 3️⃣ بدء التجربة: إرسال صورة العميلة + صورة العباية إلى Hugging Face
  Future<void> startTryOn(String garmentUrl) async {
    if (state.personImage == null) {
      emit(state.copyWith(status: TryOnStatus.error, errorKey: 'try_on_pick_photo_first'));
      return;
    }

    emit(state.copyWith(status: TryOnStatus.loading, clearResult: true));

    try {
      // لو لم تكتمل عملية التنزيل في الخلفية (أو فشلت) نعيد المحاولة الآن
      final garment = state.garmentImage ?? await repo.downloadGarment(garmentUrl);

      final result = await repo.tryOn(
        personImage: state.personImage!,
        garmentImage: garment,
        clothType: state.clothType,
      );
      emit(state.copyWith(status: TryOnStatus.success, garmentImage: garment, resultImage: result));
    } on TryOnException catch (e) {
      print('الخطاffffffjjjjjjjjjjjffff  e.translationKey');
      emit(state.copyWith(status: TryOnStatus.error, errorKey: e.translationKey));
    } catch (_) {
      emit(state.copyWith(status: TryOnStatus.error, errorKey: 'try_on_error_server'));
    }
  }

  /// مشاركة الصورة الناتجة
  Future<void> shareResult(String text) async {
    final result = state.resultImage;
    if (result == null) return;
    await Share.shareXFiles(
      [XFile.fromData(result, mimeType: 'image/png', name: 'try_on.png')],
      text: text,
    );
  }
}
