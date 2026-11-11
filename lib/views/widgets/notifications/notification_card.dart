import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  // أيقونة حسب نوع الإشعار
  // أيقونة حسب نوع الإشعار
  IconData get _icon {
    switch (item.type) {
      case 'abandoned_cart':
        return CupertinoIcons.cart;
      case 'order_status':
        return CupertinoIcons.cube_box;
      default:
        return CupertinoIcons.bell;
    }
  }
  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final unread = !item.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.redColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(CupertinoIcons.delete, color: Colors.white),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unread ? AppColors.primary.withOpacity(0.06) : AppColors.ContainerColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unread
                    ? AppColors.primary.withOpacity(0.35)
                    : AppColors.borderSecondary.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title(lang),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body(lang),
                        style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateHelper.formatDateTime(item.createdAt),
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
