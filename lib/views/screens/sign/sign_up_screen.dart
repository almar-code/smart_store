import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_store/logic/signup/sign_up_logics.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../logic/signup/sign_up_cubit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';



class SignUpScreen extends StatelessWidget {
  final VoidCallback? onSuccess;

   SignUpScreen({super.key,this.onSuccess});

  final _formKey = GlobalKey<FormBuilderState>();


  String? savedEmail;
  void _nextStep(BuildContext context ,int currentIndex) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (currentIndex == 1) {

         await SignUpLogics.handleSignUp(_formKey.currentState!.value,context);

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
    ),
    AvatarStep(onSuccess: onSuccess ,),
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,

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
                                      child: Text(state == 0 ? tr("next") : tr("sign_up"), style: const TextStyle(color: Colors.white)),
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
      validators: [FormBuilderValidators.required(), FormBuilderValidators.email()],
    ),
    CustomFormField(
      name: 'password',
      label: tr('password'),
      icon: Icons.lock_outline,
      validators: [FormBuilderValidators.required(), FormBuilderValidators.minLength(6)],
    ),
  ]);
}

class UserDataStep extends StatelessWidget {
  const UserDataStep({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
    CustomFormField(
        name: 'user_name',
        label: tr('full_name'),
        icon: Icons.person_outline,
        validators: [FormBuilderValidators.required()]),
    CustomFormField(name: 'phone_number',
        label: tr('phone_number'),
        icon: Icons.phone,
        validators: [FormBuilderValidators.required()]),
  ]);
}


class OtpStep extends StatefulWidget {
  final String email;
  const OtpStep({super.key, required this.email});
  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  Timer? _timer;
  int _start = 60;
  bool _isResendDisabled = true;
  final TextEditingController _pinController = TextEditingController();

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel(); // إلغاء أي مؤقت سابق لتجنب تداخل المهام
    setState(() {
      _start = 60; // إعادة ضبط الوقت (مثلاً دقيقتان)
      _isResendDisabled = true; // تعطيل الزر عند بدء العد
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        if (mounted) {
          setState(() {
            _isResendDisabled = false; // 👈 التعديل المهم: تفعيل الزر هنا عند انتهاء الوقت
            timer.cancel(); // إيقاف المؤقت
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _start--; // إنقاص الوقت ثانية بثانية
          });
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 20),
         Text(
             tr("verification"),
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
            "${"enter_code_sent_to".tr()}\n${widget.email}",
            textAlign: TextAlign.center),
        const SizedBox(height: 30),
        Pinput(
          length: 6,
          controller: _pinController,
          onCompleted: (pin) async {
            try {
              await SignUpLogics.handleVerifyAndSave(pin,context);
            } catch (e) {
              _pinController.clear();
              FocusScope.of(context).unfocus();
              setState (() {});

            }
          },
          defaultPinTheme: PinTheme(
            width: 45,
            height: 55,
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.borderColor,
              ),
            ),
          ),

          focusedPinTheme: PinTheme(
            width: 45,
            height: 55,
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.borderColor,
                width: 2,
              ),
            ),
          ),

          submittedPinTheme: PinTheme(
            width: 45,
            height: 55,
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _isResendDisabled
                  ? null
                  : () async{
                await SignUpLogics.handleResendCode(context);
                startTimer();
              },
              child: Text(
                tr("resend_code"),
                style: TextStyle(
                  color: _isResendDisabled ? Colors.grey : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              formatTime(_start),
              style: TextStyle(
                color: _start <= 10 ? Colors.red : Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

          ],
        )

      ],
    );
  }

}


class AvatarStep extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AvatarStep({super.key,this.onSuccess});

  @override
  State<AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<AvatarStep> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(  tr("add_user_image"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 100,),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              backgroundColor: AppColors.borderColor,
              radius: 70,
              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null ? const Icon(Icons.add_a_photo, size: 40) : null,
            ),
          ),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await SignUpLogics.completeRegistration(context, widget.onSuccess);
                },
                child:  Text(tr("later")),
              ),

              ElevatedButton(
                onPressed: _imageFile == null ? null : () async {
                  await SignUpLogics.handleAvatarUpload(context,_imageFile, widget.onSuccess);
                },
                child:  Text(tr("save")),
              ),
            ],
          )

        ],
      ),
    );
  }
}