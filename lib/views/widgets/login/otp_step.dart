import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_colors.dart';
import '../../../logic/signup/sign_up_logics.dart';
class OtpStep extends StatefulWidget {
  final String email;
  final Future<void> Function(BuildContext context, String pin) onVerifyOtp;

  const OtpStep({
    super.key,
    required this.email,
    required this.onVerifyOtp,
  });
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
    _timer?.cancel();
    setState(() {
      _start = 60;
      _isResendDisabled = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        if (mounted) {
          setState(() {
            _isResendDisabled = false;
            timer.cancel();
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
              await widget.onVerifyOtp(context, pin);
              // await PasswordLogic.verifyOtpCode(context,pin);
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
