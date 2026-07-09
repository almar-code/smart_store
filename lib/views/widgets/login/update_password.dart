import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../logic/login/password_logic.dart';
import '../../../logic/signup/sign_up_cubit.dart';
import 'otp_step.dart';

class UpdatePassword extends StatelessWidget {

  final VoidCallback? onSuccess;
  UpdatePassword({super.key,this.onSuccess});

  final _formKey = GlobalKey<FormBuilderState>();


  String? savedEmail;

  void _nextStep(BuildContext context ,int currentIndex) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (currentIndex == 0) {
       await PasswordLogic.sendResetPasswordCode(context,_formKey.currentState!.value);

      } else if (currentIndex == 2){
       await PasswordLogic.updateNewPassword(context,_formKey.currentState!.value,onSuccess);
      }
    else if (currentIndex < 1 ){
        context.read<SignUpCubit>().next();

      }
    }
  }

  List<Widget> get _steps => [
    const AccountStep(),
    OtpStep(
      email: savedEmail ?? "",
      onVerifyOtp: (context, pin) async {
        await PasswordLogic.verifyOtpCode(context, pin);
      },
    ),
    const UserDataStep(),

  ];

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<SignUpCubit,int>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.background,
              elevation: 0,
              title: AppTitle(spacing:' ' ,firstPart: tr('edit'), secondPart: tr('password')),
              actions: const [ArrowBack()],
            ),
            body: Container(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    StepProgressIndicator(
                      totalSteps: 3,
                      currentStep: state + 1,
                      selectedColor: AppColors.primary,
                      unselectedColor: Colors.grey.withOpacity(0.2),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: AppColors.ContainerColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.boxShadow.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: FormBuilder(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.disabled,

                        child: Column(
                          children: [
                            Text(state == 0 || state == 2 ? (state == 0 ? tr("enter_email") : tr("enter_new_password")):"",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            if (state == 1)
                              Container(
                                width: 290,
                                height: 180,
                                child: Image.asset("assets/images/sign_3.png",fit: BoxFit.fill,),
                              ),
                            const SizedBox(height: 25),

                            _steps[state],
                            const SizedBox(height: 30),

                            if (state == 0 || state == 2)
                              Row(
                                children: [
                                  if (state > 0)
                                    Expanded(
                                        child: OutlinedButton(
                                            onPressed: context.read<SignUpCubit>().previous,
                                            child:  Text(tr("back")))),
                                  if (state > 0) const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [AppColors.primary, Colors.tealAccent]),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: (){
                                           _nextStep(context ,state);

                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor:
                                        Colors.transparent, shadowColor: Colors.transparent),
                                        child: Text(state == 0 ? tr("next") : tr("change"), style: const TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}

class AccountStep extends StatelessWidget {
  const AccountStep({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
    CustomFormField(
      name: 'email',
      label: tr('email_address'),
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validators: [FormBuilderValidators.required(errorText: tr("enter_email")),
        FormBuilderValidators.email(checkNullOrEmpty: true,errorText:tr("email_invalid_error"))
      ],
    ),

  ]);
}

class UserDataStep extends StatelessWidget {
  const UserDataStep({super.key});
  @override
  Widget build(BuildContext context) => Column(
    spacing: 15,
      children: [
    CustomFormField(
      name: 'password',
      label: tr('password'),
      icon: Icons.lock_outline,
      isPasswordField: true,
      validators: [
        FormBuilderValidators.required(errorText: tr('field_required')),
        FormBuilderValidators.minLength(6, errorText: tr('min_length_6')),
      ],
    ),
    SizedBox(height: 15,),
    FormBuilderField(
      name: 'confirm_password',
      builder: (FormFieldState<dynamic> field) {
        return CustomFormField(
          name: 'confirm_password',
          label: tr('confirm_password'),
          icon: Icons.lock_reset,
          isPasswordField: true,
          validators: [
            FormBuilderValidators.required(errorText: tr('confirm_password_required')),
                (value) {
              final password = (context.findAncestorWidgetOfExactType<FormBuilder>()?.key as GlobalKey<FormBuilderState>?)
                  ?.currentState?.fields['password']?.value;

              if (value != password) {
                return tr('password_not_match');
              }
              return null;
            }
          ],
        );
      },
    ),
  ]);
}


