import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../core/widgets/app_button.dart';
import '../../../logic/map/address_cubit.dart';
import '../../widgets/map/map_picker_dialog.dart';


// --- 2. الصفحة الأساسية بنفس تصميمك الأصلي ---
class AddAddress extends StatelessWidget {
  const AddAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressCubit(),
      child: const AddAddressView(),
    );
  }
}

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Icon(Icons.add_location_alt_outlined,
            size: isDesktop ? 25 : 21, color: AppColors.iconColor),
        titleSpacing: 0,
        title: AppTitle(
          firstPart: tr('add'),
          secondPart: tr('address'),
          fontSize: isDesktop ? 18 : 15,
          spacing: ' ',
        ),
        actions: const [ArrowBack()],
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressLoaded) {
            _formKey.currentState?.patchValue(state.addressData);
          } else if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
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
                  isCenter: true,
                ),
                const SizedBox(height: 25),

                // زر استخدام الخريطة بنفس التصميم السابق
                InkWell(
                  onTap: () async {
                    final LatLng? picked = await showDialog<LatLng>(
                      context: context,
                      builder: (context) => const MapPickerDialog(),
                    );
                    if (picked != null) {
                      // تمرير اللغة الحالية للكيوبيت
                      context.read<AddressCubit>().fetchAddressFromLocation(
                          picked,
                          context.locale.languageCode
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state is AddressLoading)
                          const SizedBox(width: 20, height: 20,
                              child: CircularProgress(size: 25,))
                        else
                          Icon(Icons.map_rounded, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          state is AddressLoading ? tr('loading') : tr('use_map_to_fill'),
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // نموذج البيانات بنفس الـ BoxShadow والـ Border
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.boxShadow.withOpacity(0.03),
                        blurRadius: 15, offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      spacing: 15,
                      children: [
                        CustomFormField(
                          name: 'country',
                          label: tr('country'),
                          icon: Icons.public,
                          validators: [FormBuilderValidators.required()],
                        ),
                        CustomFormField(
                          name: 'city',
                          label: tr('city'),
                          icon: Icons.location_city,
                          validators: [FormBuilderValidators.required()],
                        ),
                        CustomFormField(
                          name: 'street',
                          label: tr('street'),
                          icon: Icons.add_road,
                          validators: [FormBuilderValidators.required()],
                        ),
                        CustomFormField(
                          name: 'building',
                          label: tr('building'),
                          icon: Icons.apartment,
                        ),
                        CustomFormField(
                          name: 'postal_code',
                          label: tr('postal_code'),
                          icon: Icons.mark_as_unread_sharp,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 1),
                        SizedBox(
                          width: double.infinity,
                          height: isDesktop ? 40: 30,
                          child: AppButton(
                            label: tr('save'),
                            icon: Icons.save,
                            onTap: () {
                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                debugPrint(_formKey.currentState!.value.toString());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- 3. نافذة الخريطة بنفس التصميم السابق ---

