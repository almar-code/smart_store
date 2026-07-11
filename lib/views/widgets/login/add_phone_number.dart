import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../views/widgets/login/phone_number.dart';

class AddPhoneNumber extends StatelessWidget {
  const AddPhoneNumber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.card,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -40,
            bottom: -45,
            child: Container(
              width: 220,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1.2,
                ),
              ),
            ),
          ),

          Positioned(
            left: 10,
            bottom: -35,
            child: Container(
              width: 170,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 150,
                  child: Center(
                    child: Image.asset(
                      "assets/images/phonenumber.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              /// Right Content
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('please_add_phone'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColor,
                      ),
                    ),


                    const SizedBox(height: 5),

                    /// Description
                     Text(
                      tr('phone_description'),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: 150,
                      height: 45,
                      child: AppButton(
                        borderRadius: 17,
                        label: tr('add'),
                        icon: Icons.add_call,
                        onTap: () {
                          PhoneNumber.show(context);
                        },
                      ),
                    ),



                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}