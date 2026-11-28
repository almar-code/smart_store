import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/image_convert_helper.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/icons/visual_search_icons.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/size_prediction_model.dart';
import '../../../logic/size_prediction/size_prediction_cubit.dart';
import '../../../logic/size_prediction/size_prediction_state.dart';
import '../../widgets/size_finder/size_finder_widgets.dart';

// معرفة المقاس من صورتين + الطول والوزن
class SizePhotoScreen extends StatelessWidget {
  final List<SizeModel>? productSizes;

  const SizePhotoScreen({super.key, this.productSizes});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SizePredictionCubit>(),
      child: SizePhotoView(productSizes: productSizes),
    );
  }
}

class SizePhotoView extends StatefulWidget {
  final List<SizeModel>? productSizes;
  const SizePhotoView({super.key, this.productSizes});

  @override
  State<SizePhotoView> createState() => _SizePhotoViewState();
}

class _SizePhotoViewState extends State<SizePhotoView> {
  final _formKey = GlobalKey<FormBuilderState>();
  Uint8List? _front;
  Uint8List? _side;

  // خطوات التصوير (مفاتيح الترجمة)
  static const List<String> _guideSteps = [
    'size_photo_step_clothes',
    'size_photo_step_place',
    'size_photo_step_front',
    'size_photo_step_side',
  ];

  // ==================== اختيار صورة ====================
  Future<void> _pick(bool isSide) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (_) => ImageSourceSheet(
        titleKey: isSide ? 'size_photo_side' : 'size_photo_front',
        subtitleKey: 'size_photo_sheet_subtitle',
        icon: isSide ? Icons.switch_account_outlined : Icons.accessibility_new_rounded,
      ),
    );
    if (source == null || !mounted) return;

    try {
      final XFile? file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 90);
      if (file == null) return;
      // تصغير الصورة وتحويلها JPG لتسريع الرفع
      final bytes = await ImageConvertHelper.toJpg(file, maxSize: 1280);
      if (!mounted) return;
      if (bytes == null) {
        AppToasts.showErrorToast(context, tr('image_convert_error'));
        return;
      }
      setState(() => isSide ? _side = bytes : _front = bytes);
    } catch (_) {
      if (mounted) AppToasts.showErrorToast(context, tr('image_convert_error'));
    }
  }

  // ==================== إرسال البيانات ====================
  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    if (_front == null || _side == null) {
      AppToasts.showWarningToast(context, tr('size_photo_need_both'));
      return;
    }
    final v = _formKey.currentState!.value;
    double? d(String key) => double.tryParse((v[key] ?? '').toString().trim());

    context.read<SizePredictionCubit>().predict(SizeRequestModel(
      heightCm: d('height_cm'),
      weightKg: d('weight_kg'),
      imageFront: base64Encode(_front!),
      imageSide: base64Encode(_side!),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isWide = width > 600;
    final digitsOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

    final heightField = CustomFormField(
      name: 'height_cm',
      label: tr('size_height_cm_label'),
      hint: '160',
      icon: Icons.height_rounded,
      keyboardType: TextInputType.number,
      inputFormatters: digitsOnly,
      validators: [
        FormBuilderValidators.required(errorText: tr('size_required')),
        FormBuilderValidators.between(120, 210, errorText: tr('size_err_height_range')),
      ],
    );
    final weightField = CustomFormField(
      name: 'weight_kg',
      label: tr('size_photo_weight_label'),
      hint: '60',
      icon: Icons.monitor_weight_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: digitsOnly,
      validators: [
        FormBuilderValidators.required(errorText: tr('size_required')),
        FormBuilderValidators.between(30, 250, errorText: tr('size_err_weight_range')),
      ],
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Icon(Icons.photo_camera_outlined, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('size_photo_title_first'),
            secondPart: tr('size_photo_title_second'),
            fontSize: isDesktop ? 18 : 15,
            spacing: ' ',
          ),
          actions: const [ArrowBack()],
        ),
        body: SizePredictionListener(
          productSizes: widget.productSizes,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? width * 0.2 : 20,
              vertical: 10,
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                spacing: 16,
                children: [
                  UnderlinedTitle(
                    firstPart: tr('size_photo_title_first'),
                    secondPart: tr('size_photo_title_second'),
                    fontSize: isDesktop ? 22 : 18,
                    isCenter: true,
                  ),
                  Text(
                    tr('size_photo_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                  ),

                  // ==================== 1) الطول والوزن ====================
                  SizeSectionCard(
                    icon: Icons.straighten_rounded,
                    title: tr('size_photo_data_section'),
                    subtitle: tr('size_photo_data_hint'),
                    child: isWide
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [Expanded(child: heightField), Expanded(child: weightField)],
                    )
                        : Column(spacing: 12, children: [heightField, weightField]),
                  ),

                  // ==================== 2) طريقة التصوير ====================
                  SizeSectionCard(
                    icon: Icons.tips_and_updates_outlined,
                    title: tr('size_photo_guide_section'),
                    subtitle: tr('size_photo_guide_hint'),
                    child: Column(
                      spacing: 10,
                      children: [
                        for (int i = 0; i < _guideSteps.length; i++)
                          SizeGuideStep(number: i + 1, text: tr(_guideSteps[i])),
                      ],
                    ),
                  ),

                  // ==================== 3) الصورتين ====================
                  SizeSectionCard(
                    icon: Icons.photo_library_outlined,
                    title: tr('size_photo_upload_section'),
                    subtitle: tr('size_photo_upload_hint'),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 14,
                          children: [
                            Expanded(
                              child: SizePhotoSlot(
                                label: tr('size_photo_front'),
                                isSide: false,
                                photo: _front,
                                onPick: () => _pick(false),
                                onRemove: () => setState(() => _front = null),
                              ),
                            ),
                            Expanded(
                              child: SizePhotoSlot(
                                label: tr('size_photo_side'),
                                isSide: true,
                                photo: _side,
                                onPick: () => _pick(true),
                                onRemove: () => setState(() => _side = null),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==================== زر الحساب ====================
                  BlocBuilder<SizePredictionCubit, SizePredictionState>(
                    builder: (context, state) {
                      final bool isLoading = state is SizePredictionLoading;
                      return Column(
                        spacing: 8,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 45 : 42,
                            child: AppButton(
                              label: isLoading ? '' : tr('size_predict_btn'),
                              icon: isLoading ? null : Icons.auto_awesome_rounded,
                              child: isLoading ? const CircularProgress(size: 20, color: Colors.white) : null,
                              onTap: isLoading ? null : _submit,
                            ),
                          ),
                          if (isLoading)
                            Text(
                              tr('size_photo_analyzing'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
