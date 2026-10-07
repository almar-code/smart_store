import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/cancel_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../data/models/user_address_model.dart';
import '../../../logic/map/map_cubit.dart';
import '../../../logic/user_address/UserAddressCubit.dart';
import '../../../logic/user_address/user_address_state.dart';
import '../../widgets/map/map_picker_dialog.dart';

class AddAddress extends StatelessWidget {
  final UserAddressModel? addressToEdit;

  const AddAddress({super.key, this.addressToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(),
      child: AddAddressView(addressToEdit: addressToEdit),
    );
  }
}

class AddAddressView extends StatefulWidget {
  final UserAddressModel? addressToEdit;

  const AddAddressView({super.key, this.addressToEdit});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _formKey = GlobalKey<FormBuilderState>();

  // التحكم في نمط التحقق لمنع الأخطاء الحمراء عند التصفير

  // متغيرات حالة التعديل
  bool _isEditing = false;
  int? _editingAddressId;

  @override
  void initState() {
    super.initState();
    // إعداد البيانات إذا تم فتح الصفحة لوضع التعديل
    if (widget.addressToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enableEditMode(widget.addressToEdit!);
      });
    }
  }

  // تفعيل وضع التعديل وتعبئة الحقول بالبيانات
  void _enableEditMode(UserAddressModel address) {
    setState(() {
      _isEditing = true;
      _editingAddressId = address.addressId;
    });

    _formKey.currentState?.patchValue({
      'title': address.title,
      'country': address.country,
      'city': address.city,
      'street': address.street,
      'building': address.building ?? '',
      'postal_code': address.postalCode ?? '',
      'is_default': address.isDefault,
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Icon(
            Icons.add_location_alt_outlined,
            size: isDesktop ? 25 : 21,
            color: AppColors.iconColor,
          ),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: _isEditing ? tr('edit') : tr('add'),
            secondPart: tr('address'),
            fontSize: isDesktop ? 18 : 15,
            spacing: ' ',
          ),
          actions: const [ArrowBack()],
        ),
        body: MultiBlocListener(
          listeners: [
            // الاستماع لحالات الخريطة
            BlocListener<MapCubit, MapState>(
              listener: (context, state) {
                if (state is AddressLoaded) {
                  _formKey.currentState?.patchValue(state.addressData);
                } else if (state is AddressError) {
                  AppToasts.showErrorToast(context, state.message);
                }
              },
            ),
            // الاستماع لحالات حفظ أو تعديل العنوان
            BlocListener<UserAddressCubit, UserAddressState>(
              listener: (context, state) {
                if (state is UserAddressActionSuccess) {
                  AppToasts.showSuccessToast(context, tr(state.message));
                  if (widget.addressToEdit != null) {
                    Navigator.pop(context);
                  }
                  // إعادة ضبط الحالة والنموذج بدون أخطاء حمراء
                  setState(() {
                    _isEditing = false;
                    _editingAddressId = null;
                  });
                  _formKey.currentState?.reset();
                  FocusManager.instance.primaryFocus?.unfocus();
                } else if (state is UserAddressError) {
                  AppToasts.showErrorToast(context, tr(state.message));
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
              vertical: 20,
            ),
            child: Column(
              children: [
                UnderlinedTitle(
                  firstPart: _isEditing ? tr('edit') : tr('add'),
                  secondPart: tr('address'),
                  fontSize: isDesktop ? 22 : 18,
                  isCenter: true,
                ),
                const SizedBox(height: 25),

                // زر الخريطة
                BlocBuilder<MapCubit, MapState>(
                  builder: (context, state) {
                    return InkWell(
                      onTap: () async {
                        final LatLng? picked = await showDialog<LatLng>(
                          context: context,
                          builder: (context) => const MapPickerDialog(),
                        );
                        if (picked != null) {
                          context.read<MapCubit>().fetchAddressFromLocation(
                            picked,
                            context.locale.languageCode,
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
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgress(size: 20),
                              )
                            else
                              Icon(Icons.map_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              state is AddressLoading ? tr('loading') : tr('use_map_to_fill'),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // نموذج البيانات
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
                    child: Column(
                      spacing: 15,
                      children: [
                        CustomFormField(
                          name: 'title',
                          label: tr('title'),
                          hint: tr('address_title_hint'),
                          icon: Icons.bookmark_outline_rounded,
                          validators: [FormBuilderValidators.required()],
                        ),
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
                        FormBuilderCheckbox(
                          name: 'is_default',
                          initialValue: false,
                          title: Text(
                            tr('set_as_default_address'),
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 14,
                            ),
                          ),
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 1),

                        // أزرار الحفظ والتعديل والإلغاء الديناميكية
                        BlocBuilder<UserAddressCubit, UserAddressState>(
                          builder: (context, state) {
                            final bool isLoading = state is UserAddressLoading;

                            if (_isEditing) {
                              // وضع التعديل: يظهر زران (تعديل + إلغاء)
                              return Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: isDesktop ? 40 : 35,
                                      child: AppButton(
                                        label: isLoading ? '' : tr('edit'),
                                        icon: isLoading ? null : Icons.edit,
                                        child: isLoading
                                            ? const CircularProgress(
                                          size: 20,
                                          color: Colors.white,
                                        )
                                            : null,
                                        onTap: isLoading
                                            ? null
                                            : () {
                                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                                            final formData = _formKey.currentState!.value;
                                            // إرسال طلب التعديل بحسب دالة التعديل لديك
                                            context.read<UserAddressCubit>().updateAddress(_editingAddressId!, formData);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SizedBox(
                                      height: isDesktop ? 40 : 35,
                                      child: CancelButton(
                                        onPressed: () => Navigator.pop(context),
                                        borderRadius: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // الوضع العادي: زر الحفظ
                              return SizedBox(
                                width: double.infinity,
                                height: isDesktop ? 40 : 35,
                                child: AppButton(
                                  label: isLoading ? '' : tr('save'),
                                  icon: isLoading ? null :  Icons.add_location_alt_outlined,
                                  child: isLoading
                                      ? const CircularProgress(
                                    size: 20,
                                    color: Colors.white,
                                  )
                                      : null,
                                  onTap: isLoading
                                      ? null
                                      : () {
                                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                                      final formData = _formKey.currentState!.value;
                                      context.read<UserAddressCubit>().addAddress(formData);
                                    }
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}