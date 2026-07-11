import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/views/screens/sign/sign_up_screen.dart';
import 'package:smart_store/views/widgets/login/update_password.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/internet_check.dart';
import '../../../core/widgets/network_service.dart';
import '../../../logic/login/login_logic.dart';
import '../../../logic/signup/sign_up_cubit.dart';
import '../../../logic/navigation/navigation_cubit.dart';


class Login extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final VoidCallback? onSuccess;
  final _formKey = GlobalKey<FormBuilderState>();
   Login({super.key,this.onSuccess});

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
                      Text(tr("sign_in_to_account"), style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 30),

                 FormBuilder(
                   key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,

                   child:  Column(
                     spacing: 10,
                     children: [
                       CustomFormField(

                          name: 'email',
                          label: tr('email_address'),
                          icon: Icons.email_outlined,
                         labelColor: Colors.white38,
                         color:  Colors.white.withOpacity(0.1),
                          keyboardType: TextInputType.emailAddress,
                          validators: [FormBuilderValidators.required(errorText: tr("enter_email")),
                            FormBuilderValidators.email(checkNullOrEmpty: true,errorText:tr("email_invalid_error"))
                          ],
                        ),
                       SizedBox(height: 20),
                       CustomFormField(
                         name: 'password',
                         label: tr('password'),
                         icon: Icons.lock_outline,
                         color: Colors.white.withOpacity(0.1),
                         labelColor: Colors.white38,
                         isPasswordField: true,
                         validators: [
                           FormBuilderValidators.required(errorText: tr('password_required_error')),
                         ],
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           InkWell(
                               onTap:(){
                                 context.read<SignUpCubit>().remove();
                                 Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePassword()));
                               },
                               child: Text(tr("forgot_password"),
                                   style: TextStyle(
                                       color:  Colors.tealAccent,
                                       fontSize: 12))),
                           SizedBox()
                         ],
                       ),
                       SizedBox(height: 20),
                       Container(
                         width: double.infinity,
                         decoration: BoxDecoration(
                           gradient: LinearGradient(colors: [AppColors.primary, Colors.tealAccent]),
                           borderRadius: BorderRadius.circular(15),
                         ),
                         child: ElevatedButton(
                           onPressed: () async{
                             if (_formKey.currentState?.saveAndValidate() ?? false) {

                               final email = _formKey.currentState?.fields['email']?.value?.toString().trim() ?? '';
                               final password = _formKey.currentState?.fields['password']?.value?.toString().trim() ?? '';
                               await LoginLogic.signIn(context, email, password, onSuccess);

                             }
                           },
                           style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                               shadowColor: Colors.transparent,
                               padding: const EdgeInsets.symmetric(vertical: 15)
                           ),
                           child:  Text(tr("sign_in"), style: TextStyle(fontSize: 18, color: Colors.white)),
                         ),
                       ),
                     ],
                   ),

                  ),
          

                      SizedBox(height: 25),
                      Row(
                          children:
                          [
                            Expanded(
                                child: Divider(color: Colors.white24)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(tr("or_continue_with"), style: TextStyle(color: Colors.white54, fontSize: 12))),
                            Expanded(child: Divider(color: Colors.white24))]),
                      SizedBox(height: 25),
          
                      Row(
                        children: [
                          Expanded(child: _socialButton(FontAwesomeIcons.google, tr("google"),() async{
                            bool connected = await NetworkService.hasInternet();
                            if (!connected) {
                              InternetCheck.internetCheck(context);

                            }else {
                              await LoginLogic.googleSignIn(context, onSuccess);
                            }
                          }
                          )),
                          SizedBox(width: 10),
                          Expanded(child: _socialButton(FontAwesomeIcons.facebook, tr("facebook"), () async{
          
                          })),
                        ],
                      ),
          
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          context.read<SignUpCubit>().remove();
          
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen(onSuccess: onSuccess,)));
                        },
                        child: RichText(
                          text: TextSpan(text: tr("dont_have_account"), style: TextStyle(color: Colors.white70), children: [
                            TextSpan(text: tr("sign_up"), style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold))]),
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

  Widget _socialButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius:BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
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
        suffixIcon: isPassword ? Icon(Icons.visibility_off, color: Colors.white38) : null,
      ),
    );
  }

  void loginDialog(BuildContext mainContext){
    showDialog(
      context: mainContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Login(
        onSuccess:(){
          mainContext.read<NavigationCubit>().updateIndex(4);
        }),
    );
  }
}


