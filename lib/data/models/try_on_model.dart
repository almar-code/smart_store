/// خطأ التجربة الافتراضية: يحمل كود الخطأ حتى نترجمه في الواجهة
/// الأكواد: garment_not_found | quota_exceeded | timeout | network | server
class TryOnException implements Exception {
  final String code;
  TryOnException(this.code);

  /// مفتاح الترجمة في ملفات ar.json / en.json
  String get translationKey => 'try_on_error_$code';

  @override
  String toString() => 'TryOnException($code)';
}
