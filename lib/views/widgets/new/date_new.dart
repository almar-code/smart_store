import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../flash/flash_screen.dart';
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
      // تحديث الـ State بالـ Index الجديد
      emit(NewInState(selectedDayIndex: event.index));

      // ملاحظة: هنا يمكنك أيضاً استدعاء API لجلب منتجات هذا اليوم
    });
  }
}


class SheinNewInDates extends StatelessWidget {
   SheinNewInDates({super.key});

  final List<Map<String, String>> _days = [
    {"label": "Today", "date": "الوصول الجديد"},
    {"label": "Yesterday", "date": "الوصول الجديد"},
    {"label": "04/16", "date": "الوصول الجديد"},
    {"label": "04/22", "date": "الوصول الجديد"},
    {"label": "04/23", "date": "الوصول الجديد"},
    {"label": "04/23", "date": "الوصول الجديد"},
    {"label": "04/23", "date": "الوصول الجديد"},
  ];

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<NewInBloc, NewInState>(
        builder: (context, state) {
          bool isDesktop = MediaQuery.of(context).size.width > 800;
         return SizedBox(
           height: isDesktop ?400:90,
           child: isDesktop?Row(
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
                     dateButton(_days, state, context),
                   ],
                 ),
               ),
               Expanded(child: cardImage(imagePath: "new_phon_ar_4.png")),
             ],
           ): dateButton(_days, state, context),
         );

        }
    );
  }
}




Widget dateButton(List _days,var state,BuildContext context){
  return FutureBuilder<bool>(
  future: Future.delayed(const Duration(seconds: 5), () => true),
  builder: (context, snapshot) {

  if (snapshot.connectionState == ConnectionState.waiting) {
   return NewInShimmer();
  }
 return Container(
   height: 70,
     padding: EdgeInsets.symmetric(vertical: 12),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(5),
       color: AppColors.ContainerColor,
       boxShadow: [
         BoxShadow(color: Colors.black.withOpacity(0.07),
             blurRadius: 13,
             offset: Offset(0, 8)),
       ],
     ),
  child:  ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _days.length,
    itemBuilder: (context, index) {
      bool isSelected = state.selectedDayIndex == index;
      return GestureDetector(
        onTap: () {
          context.read<NewInBloc>().add(SelectDayEvent(index));
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 70,
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            // color: AppColors.highlightColor, // شفافية خفيفة
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: AppColors.borderColor,
            ),
            boxShadow: AppShadow.commonShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2,
            children: [
              Text(
                _days[index]["label"]!,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textColor,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: isSelected ?12:11,
                ),
              ),
              Text(
                _days[index]["date"]!,
                style: TextStyle(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.5):  AppColors.textColor,
                  fontSize: 10,
                ),
              ),
              if (isSelected)
                Container(
                  margin: EdgeInsets.only(top: 2),
                  height: 2,
                  width: 17,
                  decoration: BoxDecoration(color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2)),
                  )
                ],
              ),
            ),
          );
        },
       )
     );
    }
  );
}