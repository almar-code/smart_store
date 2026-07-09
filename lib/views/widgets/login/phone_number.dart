import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
      create: (_) => CountriesCubit(CountryRepo())..loadCountries(context),
      child: Builder(
        builder: (context) {
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
                        // color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 250,
                          child: FormBuilder(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              children: [
                                Text(tr("welcome_back"), style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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

                                          final phone =
                                              '${cubit.selectedCountry?.dialCode ?? ''}${values['phone_number']}';
                                          await SignUpLogics.updateUserPhone(
                                            context,
                                            phone,
                                          );
                                        }
                                      }
                                  )

                                ),

                              ],
                            ),
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








