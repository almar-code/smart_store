// ==================== 📏 موديلات التنبؤ بمقاس العباية ====================

/// بيانات العميلة المرسلة إلى n8n (كل الحقول اختيارية عدا الطول بإحدى صيغه)
class SizeRequestModel {
  final double? heightCm;
  final int? heightFt;
  final int? heightIn;
  final String? heightRange; // u150, 150, 155, 160, 165, 170, 175, 180
  final double? weightKg;
  final double? bustCm;
  final String? clothing; // XS, S, M, L, XL, XXL, 3XL
  final String? build; // slim, average, curvy, full, plus
  final String pref; // normal, heels, ankle
  final String? storeId;

  const SizeRequestModel({
    this.heightCm,
    this.heightFt,
    this.heightIn,
    this.heightRange,
    this.weightKg,
    this.bustCm,
    this.clothing,
    this.build,
    this.pref = 'normal',
    this.storeId,
  });

  Map<String, dynamic> toJson() => {
        if (heightCm != null) 'height_cm': heightCm,
        if (heightFt != null) 'height_ft': heightFt,
        if (heightIn != null) 'height_in': heightIn,
        if (heightRange != null) 'height_range': heightRange,
        if (weightKg != null) 'weight_kg': weightKg,
        if (bustCm != null) 'bust_cm': bustCm,
        if (clothing != null) 'clothing': clothing,
        if (build != null) 'build': build,
        'pref': pref,
        if (storeId != null) 'store_id': storeId,
      };

  // لحفظ آخر قياسات العميلة محلياً وإعادة تعبئة النموذج
  factory SizeRequestModel.fromJson(Map<dynamic, dynamic> json) {
    double? d(dynamic v) => v == null ? null : double.tryParse(v.toString());
    int? i(dynamic v) => v == null ? null : int.tryParse(v.toString());
    return SizeRequestModel(
      heightCm: d(json['height_cm']),
      heightFt: i(json['height_ft']),
      heightIn: i(json['height_in']),
      heightRange: json['height_range'],
      weightKg: d(json['weight_kg']),
      bustCm: d(json['bust_cm']),
      clothing: json['clothing'],
      build: json['build'],
      pref: json['pref'] ?? 'normal',
      storeId: json['store_id'],
    );
  }
}

/// مواصفات المقاس المقترح (بالإنش)
class SizeSpecsModel {
  final double width;
  final double sleeve;
  final double armhole;

  SizeSpecsModel({required this.width, required this.sleeve, required this.armhole});

  factory SizeSpecsModel.fromJson(Map<String, dynamic> json) {
    return SizeSpecsModel(
      width: (json['width'] ?? 0).toDouble(),
      sleeve: (json['sleeve'] ?? 0).toDouble(),
      armhole: (json['armhole'] ?? 0).toDouble(),
    );
  }
}

/// نتيجة التنبؤ القادمة من n8n
class SizeResultModel {
  final String status; // ok, need_more, invalid
  final int? abayaSize;
  final int? cutLengthTo; // التقصير المطلوب (null = لا يحتاج)
  final int? altSize; // بديل بقصة واسعة إذا المتجر لا يقصّر
  final int? lengthSize;
  final int? widthSize;
  final String confidence; // high, medium, low
  final bool needsHuman;
  final int? finalLengthCm;
  final SizeSpecsModel? specs;
  final String messageKey;
  final List<String> notes;
  final List<String> fields; // الحقول الخاطئة أو الناقصة

  SizeResultModel({
    required this.status,
    this.abayaSize,
    this.cutLengthTo,
    this.altSize,
    this.lengthSize,
    this.widthSize,
    this.confidence = 'low',
    this.needsHuman = false,
    this.finalLengthCm,
    this.specs,
    required this.messageKey,
    this.notes = const [],
    this.fields = const [],
  });

  bool get isOk => status == 'ok' && abayaSize != null;
  bool get needsAlteration => cutLengthTo != null;

  factory SizeResultModel.fromJson(Map<String, dynamic> json) {
    int? i(dynamic v) => v == null ? null : int.tryParse(v.toString());
    return SizeResultModel(
      status: json['status'] ?? 'invalid',
      abayaSize: i(json['abaya_size']),
      cutLengthTo: i(json['cut_length_to']),
      altSize: i(json['alt_size']),
      lengthSize: i(json['length_size']),
      widthSize: i(json['width_size']),
      confidence: json['confidence'] ?? 'low',
      needsHuman: json['needs_human'] ?? false,
      finalLengthCm: i(json['final_length_cm']),
      specs: json['specs'] != null ? SizeSpecsModel.fromJson(Map<String, dynamic>.from(json['specs'])) : null,
      messageKey: json['message_key'] ?? 'size_err_connection',
      notes: List<String>.from(json['notes'] ?? []),
      fields: List<String>.from(json['fields'] ?? []),
    );
  }
}
