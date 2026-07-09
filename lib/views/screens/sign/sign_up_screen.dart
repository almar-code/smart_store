import 'dart:async';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_store/core/widgets/phone_number_field.dart';
import 'package:smart_store/data/repos/country_repo.dart';
import 'package:smart_store/logic/signup/sign_up_logics.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../logic/countries_cubit/countries_cubit.dart';
import '../../../logic/signup/sign_up_cubit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../widgets/login/otp_step.dart';



class SignUpScreen extends StatelessWidget {
  final VoidCallback? onSuccess;

   SignUpScreen({super.key,this.onSuccess});

  final _formKey = GlobalKey<FormBuilderState>();


  String? savedEmail;
  void _nextStep(BuildContext context ,int currentIndex) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      if (currentIndex == 1) {
        final countriesCubit = context.read<CountriesCubit>();
        final phone = (formData['phone_number'] ?? '').toString().trim();

        if (countriesCubit.selectedCountry != null && phone.isNotEmpty) {
          formData['phone_number'] =
          '${countriesCubit.selectedCountry!.dialCode}$phone';
        }

        await SignUpLogics.handleSignUp(formData, context);

      } else if (currentIndex <2 ){
        context.read<SignUpCubit>().next();

      }
    }
  }

  List<Widget> get _steps => [
    const AccountStep(),
    const UserDataStep(),
    OtpStep(
      email: savedEmail ?? "",
      onVerifyOtp: (context, pin) async {
      await SignUpLogics.handleVerifyAndSave(pin,context);
      },
    ),
    AvatarStep(onSuccess: onSuccess ,),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return  BlocProvider(
      create: (_) => CountriesCubit(di.sl<CountryRepo>())..loadCountries(context),
      child: BlocBuilder<SignUpCubit,int>(
          builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.background,
              elevation: 0,
              title: AppTitle(firstPart: tr('create'), secondPart: tr('account')),
              actions: const [ArrowBack()],
            ),
            body: Container(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    StepProgressIndicator(
                      totalSteps: 4,
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
                            Text(state == 0 || state == 1? (state == 0 ? tr("sign_up") : tr("your_information")):"",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            if (state == 2)
                              Container(
                                width: 290,
                                height: 180,
                                child: Image.asset("assets/images/sign_3.png",fit: BoxFit.fill,),
                              ),
                            const SizedBox(height: 25),

                            _steps[state],
                            const SizedBox(height: 30),
                            if (state < 2)
                              Row(
                                children: [
                                  if (state > 0)
                                    Expanded(
                                      child: SizedBox(
                                        height: isDesktop ? 50: 40,
                                        child: AppButton(
                                          onTap: context.read<SignUpCubit>().previous,
                                          label:  tr("back") ,
                                          textColor: AppColors.textColor,
                                          color: AppColors.background,
                                          icon: Icons.exit_to_app,
                                          borderColor: AppColors.borderColor,

                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                        // child: OutlinedButton(
                                        //     onPressed: context.read<SignUpCubit>().previous,
                                        //     child:  Text(tr("back")))),
                                  if (state > 0) const SizedBox(width: 10),
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: isDesktop ? 50: 40,
                                      child: AppButton(
                                        iconAfter: true,
                                        label: state == 0 ? tr("next") : tr("sign_up"),
                                        icon: Icons.save,
                                        onTap: () {
                                          _nextStep(context ,state);

                                        },
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
      ),
    );
  }
}

class AccountStep extends StatelessWidget {
  const AccountStep({super.key});
  @override
  Widget build(BuildContext context) => Column(
    spacing: 15,
      children: [
    CustomFormField(
      name: 'email',
      label: tr('email_address'),
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validators: [FormBuilderValidators.required(errorText: tr("enter_email")),
        FormBuilderValidators.email(checkNullOrEmpty: true,errorText:tr("email_invalid_error"))
      ],
    ),
    CustomFormField(
      name: 'password',
      label: tr('password'),
      icon: Icons.lock_outline,
      isPasswordField: true,
      validators: [FormBuilderValidators.required(errorText:tr("password_required_error")),
        FormBuilderValidators.minLength(6, errorText: tr('min_length_6')),

      ],
    ),
  ]);
}

class UserDataStep extends StatelessWidget {
  const UserDataStep({super.key});
  @override
  Widget build(BuildContext context) => Column(
      spacing:15,
      children: [
    CustomFormField(
        name: 'user_name',
        label: tr('full_name'),
        icon: Icons.person_outline,
        validators: [FormBuilderValidators.required(
          errorText: tr("name_required_error"),
        ),
          FormBuilderValidators.minLength(
            5,
            errorText: tr("name_min_length_error"),
          ),
        ]),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: PhoneNumberField(),
            ),
            Expanded(
              flex: 2,
              child: CustomFormField(
                name: 'phone_number',
                keyboardType: TextInputType.phone,
                label: tr('phone_number'),
                color: Colors.white.withOpacity(0.1),
                labelColor: Colors.white38,
                icon: Icons.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validators: [
                  FormBuilderValidators.required(
                    errorText: tr("phone_required_error"),
                  ),
                ],
              ),
            ),
          ],
        ),


  ]);
}



class AvatarStep extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AvatarStep({super.key, this.onSuccess});

  @override
  State<AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<AvatarStep> {

  Uint8List? _imageBytes;

  Future<void> _pickImage() async {

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {

      final bytes = await pickedFile.readAsBytes();

      setState(() {_imageBytes = bytes;});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 70,
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(tr("add_user_image"), style: const TextStyle(
            fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 100),

          GestureDetector(
            onTap: _pickImage,

            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 70,

              backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,

              child: _imageBytes == null ? const Icon(Icons.add_a_photo, size: 40,) : null,
            ),
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              ElevatedButton(
                onPressed: () async {
                  await SignUpLogics.completeRegistration(context, widget.onSuccess,);
                },
                child: Text(tr("later")),
              ),

              const SizedBox(width: 40),

              ElevatedButton(
                onPressed: _imageBytes == null ? null : () async {
                  await SignUpLogics.handleAvatarUpload(context, _imageBytes, widget.onSuccess,);
                },

                child: Text(tr("save")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}