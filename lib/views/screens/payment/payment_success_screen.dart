import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          // التدرج اللوني من الأعلى للأسفل كما في الصورة
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,    // سيأخذ 0xFF1C1C1E في الليل و 0xFFFFFFFF في النهار
              AppColors.gradientBottom, // سيأخذ 0xFF000000 في الليل و 0xFFE8EAF0 في النهار
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding:  EdgeInsets.symmetric(
                horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // --- مكان الصورة (قم بتغيير المسار هنا) ---
                  Padding(
                    padding: const EdgeInsets.only(left: 7.0),
                    child: SizedBox(
                      height:isDesktop ? 240: 200,
                      width:isDesktop ? 240: 200,
                      child: Image.asset(
                        'assets/images/payment_successful.png', // ضع مسار صورتك هنا
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return  Icon(Icons.check_circle, size: 100, color: AppColors.primary);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // نص التهنئة
                  Text(
                    tr("Hooray!"),
                    style:  TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // نص الحالة
                  Text(
                    tr("Your reservation is now complete."),
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // زر العودة للرئيسية (Back Home)
                  SizedBox(
                    width: isDesktop ? MediaQuery.of(context).size.width * 0.2 :240, // الزر يأخذ عرض الكارت
                    height: 45,
                    child:  AppButton(
                      label: tr("Back Home"),
                      color: AppColors.primary,
                      textColor: Colors.white,
                      icon: CupertinoIcons.home,
                      borderRadius: 17,
                      onTap: () {
                        // العودة للشاشة الرئيسية وإغلاق كل الصفحات
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}