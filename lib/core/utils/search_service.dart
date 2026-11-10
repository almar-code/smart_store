class SearchService {
  static int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.generate(b.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost
        ].reduce((min, val) => val < min ? val : min);
      }
      for (int j = 0; j <= b.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  // فحص مطابقة ذكي وصارم لمنع الكلمات العشوائية الوهمية
  static bool isFuzzyMatch(String target, String query) {
    final cleanTarget = target.toLowerCase().trim();
    final cleanQuery = query.toLowerCase().trim();

    if (cleanQuery.isEmpty) return false;

    // 1. التطابق المباشر (الاحتواء)
    if (cleanTarget.contains(cleanQuery)) {
      return true;
    }

    // إذا كانت الكلمة العشوائية طويلة جداً ولا توجد مطابقة جزئية، نرفضها فوراً لمنع النتائج الوهمية
    if (cleanQuery.length > 10 && !cleanTarget.contains(cleanQuery.substring(0, 5))) {
      return false;
    }

    final queryWords = cleanQuery.split(' ');
    final targetWords = cleanTarget.split(' ');

    for (var qWord in queryWords) {
      if (qWord.length < 3) continue; // الكلمات القصيرة جداً تتطلب تطابقاً مباشراً

      for (var tWord in targetWords) {
        if (tWord.length < 3) continue;

        int distance = _levenshteinDistance(qWord, tWord);

        // منع الأخطاء الكبيرة في الكلمات القصيرة
        int maxAllowedErrors = qWord.length <= 4 ? 1 : (qWord.length > 7 ? 2 : 1);

        // شرط إضافي صارم: يجب ألا يتجاوز عدد الأخطاء نسبة معينة من طول الكلمة
        if (distance <= maxAllowedErrors && (distance / qWord.length) < 0.4) {
          return true;
        }
      }
    }
    return false;
  }
}