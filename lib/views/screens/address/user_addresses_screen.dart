import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../widgets/address/address_header_section.dart';
import '../../widgets/address/address_list.dart';
import 'add_address_screen.dart';

class UsrAddress extends StatelessWidget {
  const UsrAddress({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    // قائمة تجريبية للعناوين (يمكنك استبدالها ببيانات من الـ API لاحقاً)
    final List<Map<String, dynamic>> addresses = [
      {'title': 'Home', 'details': 'Street 10, Building 5, Riyadh, KSA', 'isDefault': true},
      {'title': 'Office', 'details': 'Business Bay, Tower 2, Floor 15, Dubai, UAE', 'isDefault': false},
    ];

    return Scaffold(
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
          firstPart: tr('my'),
          secondPart: tr('myAddresses'),
          fontSize: isDesktop ? 18 : 15,
          spacing: ' ',
        ),
        actions: const [ArrowBack()],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 7,
          vertical: 20,
        ),
        child: Column(
          children: [
            AddressHeaderSection(onAddPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => AddAddress())),),

            // استدعاء الكلاس الجديد هنا
            Expanded(
              child: AddressListView(isIconsShow: true,),
            ),
          ],
        ),
      ),
    );
  }
}




