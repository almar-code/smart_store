import 'dart:async';
import 'dart:ui';
// نخفي TextDirection حقها حتى ما يتعارض مع حق فلاتر
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/core/widgets/buttons/app_button.dart';
import 'package:smart_store/logic/signup/sign_up_logics.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/phone_number_field.dart';
import '../../../data/repos/country_repo.dart';
import '../../../logic/countries_cubit/countries_cubit.dart';
import '../../../logic/navigation/navigation_cubit.dart';

class PhoneNumber extends StatelessWidget {
  final VoidCallback? onSuccess;

  PhoneNumber({super.key,this.onSuccess});

  final _formKey = GlobalKey<FormBuilderState>();
  // فاضي = خطوة إدخال الرقم، غير فاضي = خطوة الرمز
  final _sentPhone = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
      create: (_) => CountriesCubit(CountryRepo())..loadCountries(context),
      child: Builder(
          builder: (context) {
            return Center(
              // يسمح بالتمرير عند ظهور الكيبورد
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ValueListenableBuilder<String>(
                            valueListenable: _sentPhone,
                            builder: (context, sentPhone, _) => AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              child: sentPhone.isNotEmpty
                                  ? _PhoneOtpView(
                                phone: sentPhone,
                                onChangeNumber: () => _sentPhone.value = '',
                              )
                                  : _buildPhoneForm(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  // خطوة إدخال الرقم
  Widget _buildPhoneForm(BuildContext context) {
    var box = Hive.box('user_info_box');
    String userName = (box.isEmpty) ? '' :  box.get('name') ?? "";
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        // الحاوية على قد المحتوى
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${tr("welcome")} $userName", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(tr("please_add_valid_number"), style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 30),

          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PhoneNumberField(),
              ),
              Expanded(
                flex: 2,
                // يتحدث عند تغيير الدولة
                child: BlocBuilder<CountriesCubit, int>(
                  builder: (context, _) {
                    final country = context.read<CountriesCubit>().selectedCountry;
                    return CustomFormField(
                      // مفتاح لكل دولة حتى يتفرغ الحقل ويتغير عدد الأرقام
                      key: ValueKey(country?.countryCode),
                      name: 'phone_number',
                      keyboardType: TextInputType.phone,
                      label: tr('phone_number'),
                      hint: country?.example,
                      color: Colors.white.withOpacity(0.1),
                      labelColor: Colors.white38,
                      icon: Icons.phone,
                      inputFormatters: [
                        country?.phoneFormatter ?? FilteringTextInputFormatter.digitsOnly,
                      ],
                      validators: [
                        FormBuilderValidators.required(
                          errorText: tr("phone_required_error"),
                        ),
                        // عدد الأرقام حسب الدولة
                            (value) => (country?.isValidPhone(value) ?? true)
                            ? null
                            : tr("phone_length_for_country", args: ['${country!.maxDigits}']),
                        // رقم جوال صحيح حسب بدايات شركات الدولة
                            (value) => (country?.isValidMobile(value) ?? true)
                            ? null
                            : tr("phone_invalid_for_country"),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, Colors.tealAccent]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: AppButton(
                  borderRadius: 17,
                  label: tr("add"),
                  icon: Icons.add_call,
                  onTap: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = _formKey.currentState!.value;
                      final cubit = context.read<CountriesCubit>();

                      if (cubit.selectedCountry == null) return;
                      final phone = cubit.selectedCountry!.fullPhone(values['phone_number']);

                      // ننتقل لخطوة الرمز بعد نجاح الإرسال
                      final sent = await SignUpLogics.sendPhoneCode(context, phone);
                      if (sent) _sentPhone.value = phone;
                    }
                  }
              )
          ),
        ],
      ),
    );
  }

  static void show(BuildContext mainContext, VoidCallback? onSuccess){
    showDialog(
      context: mainContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PhoneNumber(
          onSuccess:onSuccess
      ),
    );
  }
}

// خطوة إدخال رمز الهاتف بنفس التصميم الزجاجي
class _PhoneOtpView extends StatefulWidget {
  final String phone;
  final VoidCallback onChangeNumber;

  const _PhoneOtpView({required this.phone, required this.onChangeNumber});

  @override
  State<_PhoneOtpView> createState() => _PhoneOtpViewState();
}

class _PhoneOtpViewState extends State<_PhoneOtpView> {
  final _pinController = TextEditingController();
  Timer? _timer;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  // عداد إعادة الإرسال
  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify(String pin) async {
    try {
      await SignUpLogics.verifyPhoneCode(context, pin);
    } catch (_) {
      // رمز غلط: نفرغ الحقل
      _pinController.clear();
    }
  }

  Future<void> _resend() async {
    await SignUpLogics.handleResendPhoneCode(context);
    if (mounted) _startTimer();
  }

  PinTheme _pinTheme(Color border, {double width = 1}) => PinTheme(
    width: 44,
    height: 52,
    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border, width: width),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final canResend = _seconds == 0;
    final time = '0:${_seconds.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(tr("verify_phone_title"), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(tr("enter_code_sent_to"), style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        // الرقم دائما من اليسار لليمين
        Text(
          '\u200E${widget.phone}',
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 25),

        // خانات الرمز من اليسار لليمين
        Pinput(
              length: 6,
              controller: _pinController,
              autofocus: true,
              keyboardType: TextInputType.number,
              onCompleted: _verify,
              defaultPinTheme: _pinTheme(Colors.white.withOpacity(0.25)),
              focusedPinTheme: _pinTheme(Colors.tealAccent, width: 2),
              submittedPinTheme: _pinTheme(AppColors.primary),
          ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: canResend ? _resend : null,
              child: Text(
                tr("resend_code"),
                style: TextStyle(
                  color: canResend ? Colors.tealAccent : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: _seconds <= 10 ? Colors.redAccent : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // الرجوع لتعديل الرقم
        TextButton.icon(
          onPressed: widget.onChangeNumber,
          icon: const Icon(Icons.edit, size: 16, color: Colors.white70),
          label: Text(tr("change_number"), style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}