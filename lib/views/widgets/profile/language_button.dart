import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';

class LanguageButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final String langCode;

  const LanguageButton({super.key, required this.title, required this.icon, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = context.locale.languageCode == langCode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary :CupertinoColors.systemGrey3,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.primary, blurRadius: 8, offset: const Offset(0, 4))]
            : [],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        onPressed: () async {
          await context.setLocale(Locale(langCode));
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(icon, color: isSelected ? AppColors.surface : AppColors.iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                // color: isSelected ? AppColors.surface : AppColors.iconColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
