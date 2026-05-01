import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/views/screens/payment/payment_success_screen.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/cancel_button.dart';
import '../../../core/widgets/drop_card.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddCardForm extends StatelessWidget {
  final VoidCallback onCancel;
  const AddCardForm({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 0.5),
        CustomFormField(
          name: 'nameOnCard',
          label: tr('Name'),
          icon: Icons.account_circle_outlined,
          validators: [FormBuilderValidators.required()],
        ),
        CustomFormField(
          name: 'cardNumber',
          label: tr('Card number'),
          hint: "0000 0000 0000 0000",
          icon: Icons.credit_card,
          validators: [FormBuilderValidators.required()],
        ),
        Row(
          children: [
            Expanded(
              child: CustomFormField(
                name: 'expiry',
                label: tr('Expiry'),
                hint: "MM/YYYY",
                icon: Icons.date_range_rounded,
                validators: [FormBuilderValidators.required()],
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: CustomFormField(
                name: 'cvv',
                label: tr('CVV'),
                hint: "***",
                icon: Icons.password_outlined,
                validators: [FormBuilderValidators.required()],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: "Add Card",
                  color: AppColors.primary,
                  borderRadius: 17,
                  icon: Icons.add_card_rounded,
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: CancelButton(onPressed: onCancel)),
          ],
        ),
      ],
    );
  }
}

class AddBankForm extends StatelessWidget {
  final VoidCallback onCancel;
  const AddBankForm({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 0.5),
        FormBuilderDropdown<String>(
          name: 'bankName',
          alignment: AlignmentDirectional.centerStart,
          decoration: InputDecoration(
            labelText: tr('Select Bank'),
            labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.account_balance_rounded, color: Color(0xFF5C2FCF), size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.borderSecondary.withOpacity(0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.borderSecondary.withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF5C2FCF), width: 1.5),
            ),
          ),
          icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
          dropdownColor: AppColors.background,
          borderRadius: BorderRadius.circular(15),
          items: [
            {'name': 'Al Kuraimi Bank', 'icon': Icons.account_balance},
            {'name': 'Yemen Kuwait Bank', 'icon': Icons.account_balance_wallet},
            {'name': 'Tadhamon Bank', 'icon': Icons.account_balance},
            {'name': 'International Bank of Yemen', 'icon': Icons.business},
          ].map((bank) => DropdownMenuItem(
            value: bank['name'] as String,
            child: Row(
              children: [
                Icon(bank['icon'] as IconData, size: 18, color: const Color(0xFF5C2FCF).withOpacity(0.7)),
                const SizedBox(width: 10),
                Text(bank['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )).toList(),
          validator: FormBuilderValidators.required(),
        ),
        CustomFormField(
          name: 'accountHolderName',
          label: tr('Account Holder Name'),
          icon: Icons.person_outline_rounded,
          color: const Color(0xFF5C2FCF),
        ),
        CustomFormField(
          name: 'accountNumber',
          label: tr('Account Number / IBAN'),
          icon: Icons.numbers_rounded,
          color: const Color(0xFF5C2FCF),
        ),
        Row(
          children: [
            Expanded(child: CancelButton(onPressed: onCancel)),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: tr("Add Bank"),
                  color: const Color(0xFF5C2FCF),
                  borderRadius: 17,
                  icon: Icons.add_business_rounded,
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}