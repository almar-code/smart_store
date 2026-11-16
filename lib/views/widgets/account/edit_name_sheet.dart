import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/cancel_button.dart';
import '../../../logic/account/account_cubit.dart';
import '../../../logic/account/account_state.dart';

// شيت تعديل اسم المستخدم
class EditNameSheet extends StatefulWidget {
  final String currentName;
  const EditNameSheet({super.key, required this.currentName});

  // فتح الشيت مع تمرير نفس الكيوبت
  static void show(BuildContext context, String currentName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AccountCubit>(),
        child: EditNameSheet(currentName: currentName),
      ),
    );
  }

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _save() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final name = _formKey.currentState!.value['user_name'] as String;
    context.read<AccountCubit>().updateName(name);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocConsumer<AccountCubit, AccountState>(
      // اغلاق الشيت بعد الحفظ
      listenWhen: (_, state) => state is AccountNameUpdated,
      listener: (context, _) => Navigator.pop(context),
      builder: (context, state) {
        final saving = state is AccountNameUpdating;

        return Padding(
          // رفع الشيت فوق الكيبورد
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SafeArea(
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 520 : double.infinity),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 20)],
                  ),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // مقبض السحب
                        Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: .3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          tr('account_edit_name'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 20 : 18,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr('account_edit_name_hint'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: isDesktop ? 14 : 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 22),
                        CustomFormField(
                          name: 'user_name',
                          label: tr('full_name'),
                          icon: CupertinoIcons.person,
                          initialValue: widget.currentName,
                          readOnly: saving,
                          validators: [
                            FormBuilderValidators.required(errorText: tr('name_required_error')),
                            FormBuilderValidators.minLength(5, errorText: tr('name_min_length_error')),
                            FormBuilderValidators.maxLength(40, errorText: tr('account_name_max_error')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: AppButton(
                            borderRadius: 15,
                            label: tr('save'),
                            icon: Icons.check_rounded,
                            iconSize: 18,
                            fontSize: 15,
                            onTap: saving ? null : _save,
                            child: saving
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CancelButton(onPressed: saving ? null : () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
