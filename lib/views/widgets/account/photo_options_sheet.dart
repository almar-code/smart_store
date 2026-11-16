import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/cancel_button.dart';
import 'account_widgets.dart';

enum PhotoOption { change, delete }

// شيت خيارات الصورة: تغيير او حذف
class PhotoOptionsSheet extends StatelessWidget {
  const PhotoOptionsSheet({super.key});

  // يرجع الخيار المختار او null
  static Future<PhotoOption?> show(BuildContext context) {
    return showModalBottomSheet<PhotoOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhotoOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 520 : double.infinity),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  tr('account_photo_options'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 20 : 18,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 22),
                _OptionTile(
                  icon: CupertinoIcons.photo_on_rectangle,
                  label: tr('account_change_photo'),
                  onTap: () => Navigator.pop(context, PhotoOption.change),
                ),
                _OptionTile(
                  icon: CupertinoIcons.delete,
                  label: tr('account_delete_photo'),
                  color: AppColors.redColor,
                  onTap: () => Navigator.pop(context, PhotoOption.delete),
                ),
                const SizedBox(height: 8),
                CancelButton(onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final c = color ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: c.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: isDesktop ? 14 : 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.withValues(alpha: .2)),
            ),
            child: Row(
              children: [
                AccountIconBox(icon, color: c),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isDesktop ? 15.5 : 14.5,
                      fontWeight: FontWeight.w600,
                      color: color ?? AppColors.textColor,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
