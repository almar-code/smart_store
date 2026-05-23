import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/views/screens/cart/cart_screen.dart';
import 'package:smart_store/views/screens/favorites/favorites_screen.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/cancel_button.dart';
import '../../screens/address/user_addresses_screen.dart';
import '../../screens/help center screen/help_center_screen.dart';
import '../../screens/orders/orders_screen.dart';
import 'custom_tile.dart';

class ProfileList extends StatelessWidget {
  const ProfileList({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return ListView(
      padding:  EdgeInsets.symmetric(vertical: isDesktop ? 15 : 6 ,horizontal: isDesktop ? 200 : 0 ),
      children: [
        CustomTile(icon: CupertinoIcons.list_bullet_below_rectangle, title: "order management".tr(), onTap:  ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => OrdersScreen()))),
        CustomTile(icon: CupertinoIcons.cart, title: "shopping cart".tr(), onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => CartScreen(screenOnly: true,)))),
        CustomTile(icon: CupertinoIcons.heart, title: "favorites".tr(), onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen()))),
        CustomTile(icon: CupertinoIcons.chat_bubble_2, title: "messages".tr(), onTap: () {}),
        CustomTile(icon: CupertinoIcons.person_crop_circle, title: "my size".tr(), onTap: () {}),
        CustomTile(
          icon: CupertinoIcons.globe,
          title: "language".tr(),
          onTap: () => _showProfessionalLanguagePicker(context),
        ),
        CustomTile(icon: CupertinoIcons.location_solid, title: "${tr('my')} ${tr('myAddresses')}", onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => UsrAddress()))),
        CustomTile(icon: CupertinoIcons.money_dollar_circle, title: "currency".tr(),onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent, // لجعل الحواف دائرية خلف الشيت
            isScrollControlled: true,
            builder: (context) => const CurrencyPickerSheet(),
          );
        },),
        CustomTile(icon: CupertinoIcons.question_circle, title: "help center".tr(), onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => HelpCenterScreen()))),
      ],
    );
  }

  void _showProfessionalLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // ضروري للحواف الدائرية
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.background, // يدعم الوضع الليلي تلقائياً
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب (Handle)
              Container(
                width: 45, height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              // العنوان
              Text(
                "application language".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
              const SizedBox(height: 8),
              Text(
                "choose language".tr(),
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 25),

              // خيار اللغة العربية
              _buildLanguageTile(
                context,
                label: 'العربية',
                langCode: 'ar',
                flag: '🇾🇪', // أو أيقونة لغة
                isSelected: context.locale.languageCode == 'ar',
                onTap: () {
                  context.setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),

              // خيار اللغة الإنجليزية
              _buildLanguageTile(
                context,
                label: 'English',
                langCode: 'en',
                flag: '🇺🇸',
                isSelected: context.locale.languageCode == 'en',
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 25),

              // زر الإلغاء الأنيق
              CancelButton(onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

// ويدجت داخلي لبناء خيار اللغة بتصميم "Smart Store"
  Widget _buildLanguageTile(BuildContext context, {
    required String label,
    required String langCode,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24)
            else
              Icon(Icons.circle_outlined, color: AppColors.textSecondary.withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }
}
class CurrencyPickerSheet extends StatelessWidget {
  const CurrencyPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة العملات
    final List<Map<String, String>> currencies = [
      {'name': 'Yemeni Rial', 'code': 'YER', 'flag': '🇾🇪'},
      {'name': 'Saudi Riyal', 'code': 'SAR', 'flag': '🇸🇦'},
      {'name': 'US Dollar', 'code': 'USD', 'flag': '🇺🇸'},
    ];

    // هنا افترضت وجود متغير مخزن للعملة الحالية، يمكنك استبداله بمنطق الـ State الخاص بك
    String currentCurrencyCode = 'YER';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب (Handle)
          Container(
            width: 45, height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 25),

          Text(
            tr("Select Currency"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
          const SizedBox(height: 8),
          Text(
            tr("choose preferred currency"), // مفتاح ترجمة جديد
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 25),

          // عرض العملات باستخدام الـ Tile الموحد
          ...currencies.map((currency) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCurrencyTile(
              context,
              name: currency['name']!,
              code: currency['code']!,
              flag: currency['flag']!,
              isSelected: currentCurrencyCode == currency['code'],
              onTap: () {
                // منطق تغيير العملة (مثلاً باستخدام Provider أو GetX)
                Navigator.pop(context);
              },
            ),
          )).toList(),

          const SizedBox(height: 20),

          // زر الإلغاء الموحد
          CancelButton(onPressed: () => Navigator.pop(context)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ويدجت داخلي لبناء خيار العملة بنفس تصميم مختار اللغة
  Widget _buildCurrencyTile(BuildContext context, {
    required String name,
    required String code,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // العلم
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            // نصوص العملة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(name),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textColor,
                  ),
                ),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? AppColors.primary.withOpacity(0.7) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // مؤشر الاختيار
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24)
            else
              Icon(Icons.circle_outlined, color: AppColors.textSecondary.withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }
}

