import 'size_prediction_model.dart';

// ==================== مقاس محفوظ للعميلة (Hive) ====================
class SavedSizeModel {
  final String id;
  final String name; // اسم يختاره العميل: مقاسي، أمي، ...
  final int abayaSize;
  final int? cutLengthTo;
  final int? lengthSize;
  final int? widthSize;
  final String confidence; // high, medium, low
  final int? finalLengthCm;
  final double? specWidth;
  final double? specSleeve;
  final double? specArmhole;
  final String method; // photo, manual
  final double? heightCm;
  final double? weightKg;
  final DateTime savedAt;

  const SavedSizeModel({
    required this.id,
    required this.name,
    required this.abayaSize,
    this.cutLengthTo,
    this.lengthSize,
    this.widthSize,
    this.confidence = 'low',
    this.finalLengthCm,
    this.specWidth,
    this.specSleeve,
    this.specArmhole,
    this.method = 'manual',
    this.heightCm,
    this.weightKg,
    required this.savedAt,
  });

  // بناء المقاس المحفوظ من نتيجة الحساب وبيانات الطلب
  factory SavedSizeModel.fromResult({
    required String name,
    required SizeResultModel result,
    SizeRequestModel? request,
  }) {
    return SavedSizeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      abayaSize: result.abayaSize!,
      cutLengthTo: result.cutLengthTo,
      lengthSize: result.lengthSize,
      widthSize: result.widthSize,
      confidence: result.confidence,
      finalLengthCm: result.finalLengthCm,
      specWidth: result.specs?.width,
      specSleeve: result.specs?.sleeve,
      specArmhole: result.specs?.armhole,
      method: request?.imageFront != null ? 'photo' : 'manual',
      heightCm: request?.heightCm,
      weightKg: request?.weightKg,
      savedAt: DateTime.now(),
    );
  }

  SavedSizeModel copyWith({String? name}) => SavedSizeModel(
    id: id,
    name: name ?? this.name,
    abayaSize: abayaSize,
    cutLengthTo: cutLengthTo,
    lengthSize: lengthSize,
    widthSize: widthSize,
    confidence: confidence,
    finalLengthCm: finalLengthCm,
    specWidth: specWidth,
    specSleeve: specSleeve,
    specArmhole: specArmhole,
    method: method,
    heightCm: heightCm,
    weightKg: weightKg,
    savedAt: savedAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'abaya_size': abayaSize,
    'cut_length_to': cutLengthTo,
    'length_size': lengthSize,
    'width_size': widthSize,
    'confidence': confidence,
    'final_length_cm': finalLengthCm,
    'spec_width': specWidth,
    'spec_sleeve': specSleeve,
    'spec_armhole': specArmhole,
    'method': method,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'saved_at': savedAt.toIso8601String(),
  };

  factory SavedSizeModel.fromMap(Map<dynamic, dynamic> m) {
    int? i(dynamic v) => v == null ? null : int.tryParse(v.toString());
    double? d(dynamic v) => v == null ? null : double.tryParse(v.toString());
    return SavedSizeModel(
      id: m['id'].toString(),
      name: m['name'] ?? '',
      abayaSize: i(m['abaya_size']) ?? 0,
      cutLengthTo: i(m['cut_length_to']),
      lengthSize: i(m['length_size']),
      widthSize: i(m['width_size']),
      confidence: m['confidence'] ?? 'low',
      finalLengthCm: i(m['final_length_cm']),
      specWidth: d(m['spec_width']),
      specSleeve: d(m['spec_sleeve']),
      specArmhole: d(m['spec_armhole']),
      method: m['method'] ?? 'manual',
      heightCm: d(m['height_cm']),
      weightKg: d(m['weight_kg']),
      savedAt: DateTime.tryParse(m['saved_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
