import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddressDropCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double iconSize;
  final Color color;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;
  final Widget? expandedContent;

  const AddressDropCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.isSelected,
    required this.isDefault,
    required this.onTap,
    this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    // تحديد لون البردر بناءً على حالة "الافتراضي"
    final Color borderColor = isDefault
        ? AppColors.primary
        : (isSelected ? AppColors.redColor.withOpacity(0.4) : AppColors.borderSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12), // الحجم الأصلي السلس
          border: Border.all(
            color: borderColor,
            width: isDefault ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.boxShadow,
              blurRadius: 11,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 1. أيقونة العنوان (حمراء للعناوين غير الافتراضية وخضراء للافتراضي)
                Container(
                  width: isDesktop ? 45 : 40,
                  height: isDesktop ? 45 : 40,
                  decoration: BoxDecoration(
                    color: (isDefault ? AppColors.primary : AppColors.redColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isDefault ? AppColors.primary : AppColors.redColor,
                    size: iconSize,
                  ),
                ),
                const SizedBox(width: 15),

                // 2. المسمى والتفاصيل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 17 : 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                "Default",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isDesktop ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 3. دائرة الاختيار (محددة دائماً إذا كان العنوان افتراضياً بغض النظر عن فتح البطاقة)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDefault ? AppColors.primary : AppColors.textSecondary.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: isDefault
                      ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
              ],
            ),

            if (isSelected && expandedContent != null) expandedContent!,
          ],
        ),
      ),
    );
  }
}