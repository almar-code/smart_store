import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'custom_tile.dart';
import 'language_button.dart';

class ProfileList extends StatelessWidget {
  const ProfileList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
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

        CustomTile(icon: CupertinoIcons.location_solid, title: "country".tr(), onTap: () {}),
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
              LanguageButton(title: 'اللغة العربية', icon: CupertinoIcons.flag_fill, langCode: 'ar'),
              const SizedBox(height: 12),
              LanguageButton(title: 'English Language', icon: CupertinoIcons.flag, langCode: 'en'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child:  Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
  }
}
