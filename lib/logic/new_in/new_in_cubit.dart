import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// يوم قابل للاختيار في واجهة الجديد
class NewInDay {
  final DateTime date;
  final bool isWeek; // زر الاسبوع كامل
  const NewInDay(this.date, {this.isWeek = false});

  String get raw => DateFormat('yyyy-MM-dd', 'en').format(date);
}

// اختيار اليوم: الرقم 0 هو الاسبوع وهو الافتراضي
class NewInCubit extends Cubit<int> {
  NewInCubit() : super(0);

  // الاسبوع ثم سبعة ايام من اليوم للخلف
  static List<NewInDay> buildDays() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return [
      NewInDay(start.subtract(const Duration(days: 6)), isWeek: true),
      for (var i = 0; i < 7; i++) NewInDay(start.subtract(Duration(days: i))),
    ];
  }

  // بداية الاسبوع لجلب الخصومات الجديدة
  static String weekStart() => buildDays().first.raw;

  void select(int index) => emit(index);
}
