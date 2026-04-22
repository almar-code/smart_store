import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../screens/address/user_addresses_screen.dart';
import 'custom_tile.dart';

class ProfileList extends StatelessWidget {
  const ProfileList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 5),
      children: [
        CustomTile(icon: CupertinoIcons.doc_text_search, title: "order management".tr(), onTap: () {}),
        CustomTile(icon: CupertinoIcons.cart, title: "shopping cart".tr(), onTap: () {}),
        CustomTile(icon: CupertinoIcons.heart, title: "favorites".tr(), onTap: () {}),
        CustomTile(icon: CupertinoIcons.chat_bubble_2, title: "messages".tr(), onTap: () {}),
        CustomTile(icon: CupertinoIcons.person_crop_circle, title: "my size".tr(), onTap: () {}),
        CustomTile(icon: CupertinoIcons.question_circle, title: "help center".tr(), onTap: () {}),

        CustomTile(
          icon: CupertinoIcons.globe,
          title: "language".tr(),
          onTap: () => _showProfessionalLanguagePicker(context),
        ),
        CustomTile(icon: CupertinoIcons.location_solid, title: "${tr('my')} ${tr('myAddresses')}", onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => UsrAddress()))),
        CustomTile(icon: CupertinoIcons.money_dollar_circle, title: "currency".tr(), onTap: () {}),
      ],
    );
  }

  void _showProfessionalLanguagePicker(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,

      builder: (BuildContext context) {
        return CupertinoAlertDialog(

          title:  Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "application language".tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Arial'),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                "choose language".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
              ),
              const SizedBox(height: 25),
              AppButton(textColor :(context.locale.languageCode == 'ar') ?Colors.white :AppColors.textColor ,borderColor:AppColors.borderColor,label: 'العربية' ,color: (context.locale.languageCode == 'ar') ? AppColors.primary : AppColors.background,icon: Icons.translate_outlined,onTap:  ()  {
                 context.setLocale(Locale('ar'));
                Navigator.pop(context);
              },),
              const SizedBox(height: 12),
              AppButton(textColor :(context.locale.languageCode == 'en') ?Colors.white :AppColors.textColor ,borderColor:AppColors.borderColor,label: 'English' ,color: (context.locale.languageCode == 'en') ? AppColors.primary : AppColors.background,icon: Icons.translate_outlined,onTap:  ()  {
                 context.setLocale(Locale('en'));
                Navigator.pop(context);
              },),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
              child: AppButton(borderColor : Colors.transparent,onTap: () => Navigator.pop(context) , label:'cancel'.tr() , color: AppColors.redColor,),
            )

          ],
        );
      },
    );
  }
}
