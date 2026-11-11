import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../data/models/notification_model.dart';
import '../../../logic/notifications/notification_cubit.dart';
import '../../../logic/notifications/notification_state.dart';
import '../../widgets/flash/flash_screen.dart';
import '../../widgets/notifications/notification_card.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final bool screenOnly; // false عند العرض داخل القائمة
  const NotificationsScreen({super.key, this.screenOnly = true});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetch();
  }

  // الضغط: تعليم كمقروء وفتح السلة
  // الضغط: تعليم كمقروء وفتح الشاشة المناسبة
  void _onTap(NotificationModel item) {
    context.read<NotificationCubit>().markRead(item.id);

    final Widget? screen = switch (item.type) {
      'abandoned_cart' => const CartScreen(screenOnly: true),
      'order_status' => OrdersScreen(openOrderId: item.orderId),
      _ => null,
    };

    if (screen != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;
    final isIpad = width > 450 && width <= 800;
    final isAr = context.locale.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: Icon(CupertinoIcons.bell, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('first notifications'),
            secondPart: tr('second notifications'),
            fontSize: isDesktop ? 18 : 15,
            spacing: isAr ? '' : ' ',
          ),
          actions: [
            AppIcon(
              icon: Icons.done_all_rounded,
              color: AppColors.primary,
              onPressed: () => context.read<NotificationCubit>().markAllRead(),
            ),
            if (widget.screenOnly) const ArrowBack(),
            const SizedBox(width: 10),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientTop, AppColors.gradientBottom],
            ),
          ),
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.ContainerColor,
                onRefresh: () => context.read<NotificationCubit>().fetch(silent: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? width * 0.2 : (isIpad ? width * 0.1 : 20),
                    vertical: isDesktop ? 20 : 10,
                  ),
                  children: [
                    UnderlinedTitle(
                      firstPart: isAr ? tr('list') : tr('Notifications'),
                      secondPart: isAr ? tr('Notifications') : tr('list'),
                      fontSize: isDesktop ? 22 : 18,
                      isCenter: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('notifications_subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 25),
                    if (state.isLoading)
                      AddressShimmer()
                    else if (state.items.isEmpty)
                      _EmptyNotifications(hasError: state.hasError)
                    else
                      ...state.items.map(
                        (item) => NotificationCard(
                          item: item,
                          onTap: () => _onTap(item),
                          onDelete: () => context.read<NotificationCubit>().delete(item.id),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// حالة عدم وجود إشعارات
class _EmptyNotifications extends StatelessWidget {
  final bool hasError;
  const _EmptyNotifications({required this.hasError});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 12),
            ),
            child: Icon(
              hasError ? CupertinoIcons.wifi_exclamationmark : CupertinoIcons.bell_slash,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr(hasError ? 'notifications_error' : 'no_notifications'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor),
          ),
          const SizedBox(height: 6),
          Text(
            tr('pull_to_refresh'),
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
