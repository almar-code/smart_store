enum SearchField { any, size, color, price }

// نتيجة فهم جملة البحث
class ParsedSearch {
  final String text;
  final SearchField field;
  final double? minPrice;
  final double? maxPrice;

  const ParsedSearch(this.text, {this.field = SearchField.any, this.minPrice, this.maxPrice});

  bool get hasPriceRange => minPrice != null || maxPrice != null;
}

class SearchQueryParser {
  static const _sizeWords = ['مقاسات', 'المقاس', 'مقاس', 'القياس', 'قياس', 'سايز', 'sizes', 'size'];
  static const _colorWords = ['الالوان', 'الألوان', 'الوان', 'ألوان', 'اللون', 'لون', 'colors', 'colour', 'color'];
  static const _priceWords = ['بسعر', 'السعر', 'سعر', 'ريال', 'ر.س', 'رس', 'دولار', r'$', 'sar', 'usd', 'price'];
  static const _lessWords = ['أقل من', 'اقل من', 'تحت', 'حتى', 'less than', 'under', 'below'];
  static const _moreWords = ['أكثر من', 'اكثر من', 'فوق', 'more than', 'above', 'over'];

  // كلمات لا تفيد البحث
  static const _stopWords = [
    'ابحث عن', 'ابي', 'أبي', 'ابغى', 'أبغى', 'اريد', 'أريد', 'ابغي',
    'العباية', 'عبايات', 'عباية', 'عبايه', 'abayas', 'abaya',
    'بين', 'عن', 'في', 'من', 'مع', 'لي', 'الى', 'إلى', 'و', 'between', 'and', 'to',
  ];

  // صفة اللون المؤنثة الى اسم اللون
  static const _feminineColors = {
    'سوداء': 'أسود', 'سودا': 'أسود',
    'بيضاء': 'أبيض', 'بيضا': 'أبيض',
    'حمراء': 'أحمر', 'خضراء': 'أخضر',
    'زرقاء': 'أزرق', 'صفراء': 'أصفر',
  };

  static ParsedSearch parse(String raw) {
    var q = ' ${_normalizeDigits(raw.trim().toLowerCase())} ';
    q = q.replaceAll(r'$', r' $ ');

    // فلتر السعر
    double? min;
    double? max;
    final numbers = RegExp(r'\d+(\.\d+)?').allMatches(q).map((m) => double.parse(m.group(0)!)).toList();
    final range = RegExp(r'(بين|من|between)\s*(\d+(?:\.\d+)?)\s*(و|الى|إلى|-|to|and)\s*(\d+(?:\.\d+)?)').firstMatch(q);

    if (range != null) {
      min = double.parse(range.group(2)!);
      max = double.parse(range.group(4)!);
    } else if (numbers.isNotEmpty && _hasAny(q, _lessWords)) {
      max = numbers.first;
    } else if (numbers.isNotEmpty && _hasAny(q, _moreWords)) {
      min = numbers.first;
    }

    // نوع البحث
    var field = SearchField.any;
    if (min != null || max != null) {
      field = SearchField.price;
    } else if (_hasAny(q, _sizeWords)) {
      field = SearchField.size;
    } else if (_hasAny(q, _colorWords)) {
      field = SearchField.color;
    } else if (numbers.isNotEmpty && _hasAny(q, _priceWords)) {
      field = SearchField.price;
    }

    // حذف الكلمات المساعدة
    for (final w in [..._lessWords, ..._moreWords, ..._sizeWords, ..._colorWords, ..._priceWords, ..._stopWords]) {
      q = q.replaceAll(' $w ', ' ');
    }

    // مع فلتر السعر لا نحتاج الارقام في النص
    if (min != null || max != null) q = q.replaceAll(RegExp(r'\d+(\.\d+)?'), ' ');

    // تحويل صفة اللون
    final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).map((w) => _feminineColors[w] ?? w);
    var text = words.join(' ').trim();

    // اذا لم يبق شيء نبحث بالكلمة الاصلية
    if (text.isEmpty && min == null && max == null) {
      text = _normalizeDigits(raw.trim().toLowerCase());
    }

    // فلتر السعر بدون نص يعرض كل المنتجات ضمن السعر
    if (field == SearchField.price && (min != null || max != null) && text.isNotEmpty) {
      field = SearchField.any;
    }

    return ParsedSearch(text, field: field, minPrice: min, maxPrice: max);
  }

  static bool _hasAny(String q, List<String> words) => words.any((w) => q.contains(' $w '));

  // الارقام العربية الى انجليزية
  static String _normalizeDigits(String s) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final i = ar.indexOf(ch);
      final j = fa.indexOf(ch);
      b.write(i != -1 ? '$i' : (j != -1 ? '$j' : ch));
    }
    return b.toString();
  }
}