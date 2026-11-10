import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/live_try_on/live_try_on_cubit.dart';
import '../../../logic/live_try_on/live_try_on_state.dart';
import '../../constants/app_colors.dart';
import 'app_icon.dart';

/// أيقونة التجربة الحية في AppBar الصفحة الرئيسية (تفتح/تغلق النافذة العائمة)
class LiveTryOnIcon extends StatelessWidget {
  const LiveTryOnIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveTryOnCubit, LiveTryOnState>(
      buildWhen: (prev, curr) => prev.isOpen != curr.isOpen,
      builder: (context, state) {
        final cubit = context.read<LiveTryOnCubit>();
        return AppIcon(
          icon: Icons.checkroom_outlined,
          color: state.isOpen ? AppColors.primary : null,
          onPressed: state.isOpen ? cubit.closePanel : cubit.open,
        );
      },
    );
  }
}
