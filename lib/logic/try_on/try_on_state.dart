import 'dart:typed_data';

/// حالة واحدة تحمل كل بيانات الشاشة (أسهل من عدة كلاسات لأن البيانات تبقى بين المراحل)
enum TryOnStatus { initial, loading, success, error }

class TryOnState {
  final TryOnStatus status;

  /// صورة العميلة المختارة
  final Uint8List? personImage;

  /// صورة العباية بعد تنزيلها في الخلفية
  final Uint8List? garmentImage;
  final bool isGarmentLoading;

  /// نوع القطعة (العباية = overall)
  final String clothType;

  /// الصورة الناتجة
  final Uint8List? resultImage;

  /// مفتاح الترجمة للخطأ مثل try_on_error_quota_exceeded
  final String? errorKey;

  const TryOnState({
    this.status = TryOnStatus.initial,
    this.personImage,
    this.garmentImage,
    this.isGarmentLoading = false,
    this.clothType = 'overall',
    this.resultImage,
    this.errorKey,
  });

  bool get isLoading => status == TryOnStatus.loading;

  TryOnState copyWith({
    TryOnStatus? status,
    Uint8List? personImage,
    Uint8List? garmentImage,
    bool? isGarmentLoading,
    String? clothType,
    Uint8List? resultImage,
    bool clearResult = false,
    String? errorKey,
  }) {
    return TryOnState(
      status: status ?? this.status,
      personImage: personImage ?? this.personImage,
      garmentImage: garmentImage ?? this.garmentImage,
      isGarmentLoading: isGarmentLoading ?? this.isGarmentLoading,
      clothType: clothType ?? this.clothType,
      resultImage: clearResult ? null : (resultImage ?? this.resultImage),
      errorKey: errorKey,
    );
  }
}
