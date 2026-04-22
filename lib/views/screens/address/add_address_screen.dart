import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../core/widgets/app_button.dart'; // تأكد من استيراد كلاس الزر الخاص بك

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: Icon(
          Icons.add_location_alt_outlined,
          size: isDesktop ? 25 : 21,
          color: AppColors.iconColor,
        ),
        titleSpacing: 0,
        title: AppTitle(
          firstPart: tr('add'),
          secondPart: tr('address'),
          fontSize: isDesktop ? 18 : 15,
          spacing: ' ',
        ),
        actions: const [ArrowBack()],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            UnderlinedTitle(
              firstPart: tr('add'),
              secondPart: tr('address'),
              fontSize: isDesktop ? 22 : 18,
              underlineHeight: isDesktop ? 3.5 : 3,
              underlineWidth: isDesktop ? 100 : 80,
              isCenter: true, // تأكد أن كلاسك يدعم هذه الخاصية أو غلفه بـ Center
            ),
            const SizedBox(height: 30),

            // بداية الفورم
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.background,
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
                    // حقل الدولة (Title حسب المايجريشن)
                    CustomFormField(
                      name: 'country',
                      label: tr('country'), // "الدولة"
                      icon: Icons.public,
                      validators: [FormBuilderValidators.required(errorText: tr('country_required'))],
                    ),

                    // حقل المدينة
                    // حقل المدينة
                    CustomFormField(
                      name: 'city',
                      label: tr('city'),
                      icon: Icons.location_city,
                      validators: [
                        FormBuilderValidators.required(errorText: tr('city_required'))
                      ],
                    ),

// حقل الشارع
                    CustomFormField(
                      name: 'street',
                      label: tr('street'),
                      icon: Icons.add_road,
                      validators: [
                        FormBuilderValidators.required(errorText: tr('street_required'))
                      ],
                    ),

// حقل البناية (اختياري)
                    CustomFormField(
                      name: 'building',
                      label: tr('building'),
                      icon: Icons.apartment,
                    ),

// الرمز البريدي (اختياري)
                    CustomFormField(
                      name: 'postal_code',
                      label: tr('postal_code'),
                      icon: Icons.mark_as_unread_sharp,
                      keyboardType: TextInputType.number, // لجعل الكيبورد يظهر أرقام فقط
                      validators: [
                        FormBuilderValidators.numeric(errorText: tr('invalid_number'))
                      ],
                    ),

// حقل الملاحظات
                    CustomFormField(
                      name: 'notes',
                      label: tr('notes'),
                      icon: Icons.note_add_outlined,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 30, // تم زيادة الارتفاع ليكون مريحاً للضغط (أفضل من 30)
                      child: AppButton(
                        label: tr('add'),
                        icon: Icons.save,
                        onTap: () {
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            // البيانات الآن جاهزة للإرسال بصيغة Map
                            Map<String, dynamic> formData = _formKey.currentState!.value;
                            print(formData);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}