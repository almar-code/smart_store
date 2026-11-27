import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../logic/new_in/new_in_cubit.dart';

// شريط الاسبوع والايام السبعة
class NewDaysBar extends StatelessWidget {
  final List<NewInDay> days;
  final ValueChanged<int> onSelect;

  const NewDaysBar({super.key, required this.days, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final wide = width > 800;

    return BlocBuilder<NewInCubit, int>(
      builder: (context, selected) {
        final chips = [
          for (var i = 0; i < days.length; i++)
            _DayChip(
              day: days[i],
              index: i,
              selected: selected == i,
              onTap: () => onSelect(i),
            ),
        ];

        // الشاشات الكبيرة: كل الازرار بعرض متساو
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < chips.length; i++) ...[
                Expanded(flex: i == 0 ? 2 : 1, child: chips[i]),
                if (i != chips.length - 1) const SizedBox(width: 8),
              ],
            ],
          );
        }

        // الجوال والايباد: تمرير افقي
        return SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => SizedBox(width: i == 0 ? 112 : 62, child: chips[i]),
          ),
        );
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  final NewInDay day;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({required this.day, required this.index, required this.selected, required this.onTap});

  // اسم اليوم او اليوم وامس
  String _title() {
    if (index == 1) return tr('new_today');
    if (index == 2) return tr('new_yesterday');
    return tr('weekday_${day.date.weekday}');
  }

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textColor;
    final sub = selected ? Colors.white.withOpacity(0.85) : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.transparent : AppColors.borderColor),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))]
              : AppShadow.commonShadow,
        ),
        child: day.isWeek ? _week(fg, sub) : _day(fg, sub),
      ),
    );
  }

  // زر الاسبوع
  Widget _week(Color fg, Color sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.calendar, size: 20, color: fg),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('new_week'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fg),
              ),
              Text(
                tr('new_week_sub'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: sub),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // زر يوم واحد
  Widget _day(Color fg, Color sub) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _title(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.5, color: sub, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          '${day.date.day}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fg, height: 1.1),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(top: 3),
          width: selected ? 16 : 4,
          height: 3,
          decoration: BoxDecoration(
            color: selected ? Colors.white : AppColors.primary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
