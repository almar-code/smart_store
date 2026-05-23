import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'app_button.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  const RefreshButton({super.key,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppButton(onTap: onPressed, label: tr('refresh'),icon: Icons.refresh,);
  }
}
