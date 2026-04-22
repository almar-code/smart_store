import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddressListView extends StatelessWidget {
  final bool isIconsShow;
  const AddressListView({super.key, this.isIconsShow = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    // المصفوفة أصبحت الآن داخل الكلاس، ويمكنك مستقبلاً تمريرها عبر الـ Constructor
    final List<Map<String, dynamic>> addresses = [
      {
        'title': 'Home',
        'details': 'Street 10, Building 5, Riyadh, KSA',
        'isDefault': true
      },
      {
        'title': 'Office',
        'details': 'Business Bay, Tower 2, Floor 15, Dubai, UAE',
        'isDefault': false
      },
      {
        'title': 'Work',
        'details': 'Industrial Area, Phase 3, Jeddah, KSA',
        'isDefault': false
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 16 : 8),
      itemCount: addresses.length,
      shrinkWrap: true, // مهم إذا تم وضعه داخل Column
      physics: const BouncingScrollPhysics(), // يعطي حركة ناعمة عند السحب
      itemBuilder: (context, index) {
        final address = addresses[index];
        return _buildAddressCard(address, isDesktop,isIconsShow);
      },
    );
  }

  // ميثود بناء البطاقة تم نقلها هنا لتكون جزءاً من الكلاس
  Widget _buildAddressCard(Map<String, dynamic> address, bool isDesktop , bool isIconsShow  ) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: address['isDefault'] ? AppColors.primary : AppColors.borderColor,
          width: address['isDefault'] ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الموقع
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              address['title'] == 'Home' ? Icons.home_outlined : Icons.work_outline,
              color: AppColors.primary,
              size: isDesktop ? 24 :17,
            ),
          ),
          const SizedBox(width: 15),

          // تفاصيل العنوان
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address['title'],
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (address['isDefault'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          "Default",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  address['details'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isDesktop ? 15 : 13,
                  ),
                ),
              ],
            ),
          ),

          // أزرار التحكم
          isIconsShow ?
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {},
                child: Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {},
                child: Icon(Icons.delete_outline, color: AppColors.redColor, size: 18),
              ),
            ],
          ) : SizedBox(),
        ],
      ),
    );
  }
}