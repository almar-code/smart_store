import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/logic/products/product_cubit.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../logic/products/product_state.dart';
import '../flash/flash_screen.dart';
import '../sliderEds/sliderEds.dart';
import 'img_new.dart';

class NewInState {
  final int selectedDayIndex;
  NewInState({this.selectedDayIndex = 0});
}
abstract class NewInEvent {}

class SelectDayEvent extends NewInEvent {
  final int index;
  SelectDayEvent(this.index);
}

class NewInBloc extends Bloc<NewInEvent, NewInState> {
  NewInBloc() : super(NewInState()) {
    on<SelectDayEvent>((event, emit) {
      emit(NewInState(selectedDayIndex: event.index));
    });
  }
}

class SheinNewInDates extends StatelessWidget {
  const SheinNewInDates({super.key});

  // 🌟 دالة توليد الأيام السبعة ديناميكياً بناءً على تاريخ اليوم اللحظي
  List<Map<String, dynamic>> _generateDynamicDays() {
    final List<Map<String, dynamic>> daysList = [];
    final DateTime now = DateTime.now();
    DateTime.now().subtract(Duration(days: 0));
    // 🔄 حلقة التكرار تبدأ من 6 (قبل أسبوع) وتتناقص حتى تصل إلى 0 (اليوم)
    // هذا يجعل الأيام تترتب في الـ ListView من الأقدم إلى الأحدث بشكل منظم
    for (int i = 0; i <= 7; i++) {
      final DateTime targetDate = now.subtract(Duration(days: i));
      String formattedYesterday = DateFormat('yyyy-MM-dd', 'en').format(
        DateTime.now().subtract( Duration(days: i)),
      );
// 🌟 هذا سيعطيك نصاً صافياً مثل: "2026-06-24" بدون أي ساعات
      String label = "";

      // فحص البعد عن تاريخ اليوم الحالي (now)
      if (i == 0) {
        label = "اليوم";
      } else if (i == 1) {
        label = "الأمس";
      }else {
        // تنسيق التاريخ الرقمي للأيام السابقة (Month/Day) مثل 06/24
        final String month = targetDate.month.toString().padLeft(2, '0');
        final String day = targetDate.day.toString().padLeft(2, '0');
        label = "$month/$day";
      }

      daysList.add({
        "label": label,
        "date": "الوصول الجديد",
        "rawDate": formattedYesterday, // الكائن الفعلي DateTime لإرساله لارافيل عند الضغط
      });
    }

    return daysList;
  }
  @override
  Widget build(BuildContext context) {
    // 🌟 استدعاء المصفوفة الديناميكية لتقرأ التواريخ فوراً في لحظة فتح الشاشة
    final List<Map<String, dynamic>> dynamicDays = _generateDynamicDays();

    return BlocBuilder<NewInBloc, NewInState>(
      builder: (context, state) {
        bool isDesktop = MediaQuery.of(context).size.width > 800;
        return SizedBox(
          height: isDesktop ? 400 : 90,
          child: isDesktop
              ? Row(
            spacing: 10,
            children: [
              Expanded(
                child: Column(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(child: cardImage(imagePath: "new_phon_ar_3.png")),
                          Expanded(child: cardImage(imagePath: "new_phon_ar_6.png")),
                        ],
                      ),
                    ),
                    dateButton(dynamicDays, state, context),
                  ],
                ),
              ),
              Expanded(
                child: SliderEds(images: [
                  'assets/images/new_phon_ar_9.png',
                  'assets/images/new_ar.png',
                  'assets/images/new_phon_ar_10.png',
                ]),
              ),
            ],
          )
              : dateButton(dynamicDays, state, context),
        );
      },
    );
  }
}

Widget dateButton(List<Map<String, dynamic>> days, var state, BuildContext context) {
  return Container(
    height: 70,
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: AppColors.ContainerColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 13,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      itemBuilder: (context, index) {
        bool isSelected = state.selectedDayIndex == index;
        return GestureDetector(
          onTap:  () { // 2. إذا كان يحمل، نلغي التفاعل تماماً لمنع السباق
            context.read<NewInBloc>().add(SelectDayEvent(index));
            context.read<ProductCubit>().fetchProducts(
              isRefresh: true,
              date: days[index]['rawDate'],
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 75, // زيادة العرض قليلاً ليناسب كتابة "قبل يومين" بأناقة
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderColor,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: AppShadow.commonShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Text(
                  days[index]["label"],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSelected ? 12 : 11,
                  ),
                ),
                Text(
                  days[index]["date"],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.textColor,
                    fontSize: 9,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 2,
                    width: 17,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    ),
  );
}