import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/notifications/notification_cubit.dart';
import '../../../logic/notifications/notification_state.dart';
import '../../../views/screens/notifications/notifications_screen.dart';
import '../../constants/app_colors.dart';
import 'app_icon.dart';

// جرس الإشعارات مع عدد غير المقروء
class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetch(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (a, b) => a.unreadCount != b.unreadCount,
      builder: (context, state) {
        final count = state.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AppIcon(
              icon: CupertinoIcons.bell,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            if (count > 0)
              PositionedDirectional(
                top: -3,
                end: 0,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.redColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
