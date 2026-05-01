import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../widgets/address/address_header_section.dart';
import '../../widgets/address/address_list.dart';
import '../payment/payment_screen.dart';
import 'add_address_screen.dart';

class SelectUsrAddress extends StatelessWidget {
  const SelectUsrAddress({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    // قائمة تجريبية للعناوين (يمكنك استبدالها ببيانات من الـ API لاحقاً)
    final List<Map<String, dynamic>> addresses = [
      {'title': 'Home', 'details': 'Street 10, Building 5, Riyadh, KSA', 'isDefault': true},
      {'title': 'Office', 'details': 'Business Bay, Tower 2, Floor 15, Dubai, UAE', 'isDefault': false},
    ];

    return Scaffold(
      extendBody : true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // لمنع ظهور زر الرجوع التلقائي كما طلبت سابقاً
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Icon(
          Icons.location_on_outlined,
          size: isDesktop ? 25 : 21,
          color: AppColors.iconColor,
        ),
        titleSpacing: 0,
        title: AppTitle(
          firstPart:(context.locale.languageCode == 'en') ? tr('user') : tr('address'),
          secondPart: (context.locale.languageCode == 'en') ? tr('address') : tr('user'),
          fontSize: isDesktop ? 18 : 15,
          spacing: ' ',
        ),
        actions: const [ArrowBack()],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          // التدرج اللوني من الأعلى للأسفل كما في الصورة
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,    // سيأخذ 0xFF1C1C1E في الليل و 0xFFFFFFFF في النهار
              AppColors.gradientBottom, // سيأخذ 0xFF000000 في الليل و 0xFFE8EAF0 في النهار
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 7,
            vertical: 20,
          ),
          child: Column(
            children: [
               AddressHeaderSection(onAddPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => AddAddress())),),

              // استدعاء الكلاس الجديد هنا
              Expanded(
                child: AddressListView(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        // إضافة padding بسيط ليعطي مظهراً أفضل للأزرار في الأسفل
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
          vertical: 10,
        ),
        child: Row(
          children: [
            // الزر الأول: السابق
            Expanded(
              child: SizedBox(
                height: 40,
                child: AppButton(
                  label: 'next'.tr(),
                  icon: Icons.arrow_back_ios,
                  borderRadius: 17,
                  onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => SelectPaymentMethodPage())),
                ),
              ),
            ),

            const SizedBox(width: 12), // مسافة فاصلة بين الزرين

            // الزر الثاني: التالي
            Expanded(
              child: SizedBox(
                height: 40,
                child: AppButton(
                  iconAfter: true,
                  label: 'previous'.tr(),
                  color: AppColors.backgroundSecondary,
                  icon: Icons.arrow_forward_ios,
                  textColor: AppColors.textColor,
                  borderColor: AppColors.textSecondary,
                  borderRadius: 17,
                  onTap: ()=>  Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}