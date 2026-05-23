import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/logic/signup/sign_up_logics.dart';
import '../../../logic/navigation/navigation_cubit.dart';

class PhoneNumber extends StatelessWidget {
  final _phoneController = TextEditingController();
  final VoidCallback? onSuccess;

   PhoneNumber({super.key,this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child:  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tr("welcome_back"), style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(tr("please_add_valid_number"), style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 30),

                      _buildTextField(tr("phone_number"), _phoneController, false),

                      SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.primary, Colors.tealAccent]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: () async{
                           await SignUpLogics.updateUserPhone(context,_phoneController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 15)
                          ),
                          child: Text(tr("add"), style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  static void show(BuildContext mainContext){
    showDialog(
      context: mainContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PhoneNumber(
          onSuccess:(){
            mainContext.read<NavigationCubit>().updateIndex(4);
          }),
    );
  }
}








