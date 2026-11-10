import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/size_prediction_model.dart';
import '../../../logic/size_prediction/size_prediction_cubit.dart';
import '../../../logic/size_prediction/size_prediction_state.dart';
import '../../widgets/size_finder/size_finder_widgets.dart';
import 'size_result_screen.dart';

class SizeFinderScreen extends StatelessWidget {
  /// مقاسات المنتج الحالي (اختياري) لاختيار المقاس الناتج تلقائياً
  final List<SizeModel>? productSizes;

  const SizeFinderScreen({super.key, this.productSizes});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SizePredictionCubit>(),
      child: SizeFinderView(productSizes: productSizes),
    );
  }
}

class SizeFinderView extends StatefulWidget {
  final List<SizeModel>? productSizes;
  const SizeFinderView({super.key, this.productSizes});

  @override
  State<SizeFinderView> createState() => _SizeFinderViewState();
}

class _SizeFinderViewState extends State<SizeFinderView> {
  final _formKey = GlobalKey<FormBuilderState>();

  bool _isCm = true; // وحدة الطول
  bool _unknownHeight = false; // العميلة لا تعرف طولها بالضبط
  bool _showBust = false; // قسم محيط الصدر (اختياري)
  String? _heightRange;
  String? _clothing;
  String? _build;
  String _pref = 'normal';

  // ==================== خيارات الأزرار (القيمة -> مفتاح الترجمة) ====================
  static const Map<String, String> _heightRanges = {
    'u150': 'size_range_u150',
    '150': 'size_range_150',
    '155': 'size_range_155',
    '160': 'size_range_160',
    '165': 'size_range_165',
    '170': 'size_range_170',
  };
  static const Map<String, String> _clothingOptions = {
    'XS': 'size_clothing_xs',
    'S': 'size_clothing_s',
    'M': 'size_clothing_m',
    'L': 'size_clothing_l',
    'XL': 'size_clothing_xl',
    'XXL': 'size_clothing_xxl',
    '3XL': 'size_clothing_3xl',
  };
  static const Map<String, String> _buildOptions = {
    'slim': 'size_build_slim',
    'average': 'size_build_average',
    'curvy': 'size_build_curvy',
    'full': 'size_build_full',
    'plus': 'size_build_plus',
  };
  static const Map<String, String> _prefOptions = {
    'normal': 'size_pref_normal',
    'heels': 'size_pref_heels',
    'ankle': 'size_pref_ankle',
  };

  @override
  void initState() {
    super.initState();
    // تعبئة آخر قياسات محفوظة
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillSavedProfile());
  }

  void _fillSavedProfile() {
    final saved = context.read<SizePredictionCubit>().savedProfile;
    if (saved == null) return;
    setState(() {
      _isCm = saved.heightFt == null;
      _unknownHeight = saved.heightRange != null && saved.heightCm == null && saved.heightFt == null;
      _heightRange = saved.heightRange;
      _clothing = saved.clothing;
      _build = saved.build;
      _pref = saved.pref;
      _showBust = saved.bustCm != null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.patchValue({
        'height_cm': saved.heightCm?.toStringAsFixed(0) ?? '',
        'height_ft': saved.heightFt?.toString() ?? '',
        'height_in': saved.heightIn?.toString() ?? '',
        'weight_kg': saved.weightKg?.toStringAsFixed(0) ?? '',
        'bust_cm': saved.bustCm?.toStringAsFixed(0) ?? '',
      });
    });
  }

  // ==================== إرسال البيانات ====================
  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    double? d(String key) => double.tryParse((v[key] ?? '').toString().trim());
    int? i(String key) => int.tryParse((v[key] ?? '').toString().trim());

    if (_unknownHeight && _heightRange == null) {
      AppToasts.showWarningToast(context, tr('size_err_need_height'));
      return;
    }

    final request = SizeRequestModel(
      heightCm: !_unknownHeight && _isCm ? d('height_cm') : null,
      heightFt: !_unknownHeight && !_isCm ? i('height_ft') : null,
      heightIn: !_unknownHeight && !_isCm ? (i('height_in') ?? 0) : null,
      heightRange: _unknownHeight ? _heightRange : null,
      weightKg: d('weight_kg'),
      bustCm: _showBust ? d('bust_cm') : null,
      clothing: _clothing,
      build: _build,
      pref: _pref,
    );
    context.read<SizePredictionCubit>().predict(request);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final digitsOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Icon(Icons.straighten_rounded, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('size_finder_first'),
            secondPart: tr('size_finder_second'),
            fontSize: isDesktop ? 18 : 15,
            spacing: ' ',
          ),
          actions: const [ArrowBack()],
        ),
        body: BlocListener<SizePredictionCubit, SizePredictionState>(
          listener: (context, state) async {
            if (state is SizePredictionSuccess) {
              final cubit = context.read<SizePredictionCubit>();
              final String? picked = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => SizeResultScreen(result: state.result, productSizes: widget.productSizes),
                ),
              );
              cubit.reset();
              // تمرير المقاس المختار لصفحة المنتج
              if (picked != null && context.mounted) Navigator.of(context).pop(picked);
            } else if (state is SizePredictionNeedInput) {
              AppToasts.showWarningToast(context, tr(state.messageKey));
            } else if (state is SizePredictionError) {
              AppToasts.showErrorToast(context, tr(state.message));
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
              vertical: 10,
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                spacing: 16,
                children: [
                  UnderlinedTitle(
                    firstPart: tr('size_finder_first'),
                    secondPart: tr('size_finder_second'),
                    fontSize: isDesktop ? 22 : 18,
                    isCenter: true,
                  ),
                  Text(
                    tr('size_finder_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                  ),

                  // ==================== 1) الطول ====================
                  SizeSectionCard(
                    icon: Icons.height_rounded,
                    title: tr('size_height_section'),
                    subtitle: tr('size_height_hint'),
                    child: Column(
                      spacing: 12,
                      children: [
                        if (!_unknownHeight) ...[
                          HeightUnitToggle(isCm: _isCm, onChanged: (v) => setState(() => _isCm = v)),
                          if (_isCm)
                            CustomFormField(
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
                            )
                          else
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: CustomFormField(
                                    name: 'height_ft',
                                    label: tr('size_feet_label'),
                                    hint: '5',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validators: [
                                      FormBuilderValidators.required(errorText: tr('size_required')),
                                      FormBuilderValidators.between(4, 6, errorText: tr('size_err_height_range')),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: CustomFormField(
                                    name: 'height_in',
                                    label: tr('size_inches_label'),
                                    hint: '4',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validators: [
                                      FormBuilderValidators.between(0, 11,
                                          errorText: tr('size_err_height_range'), checkNullOrEmpty: false),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ] else
                          SizeChoiceChips(
                            options: _heightRanges,
                            selected: _heightRange,
                            onSelected: (v) => setState(() => _heightRange = v),
                          ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _unknownHeight = !_unknownHeight),
                            icon: Icon(
                              _unknownHeight ? Icons.edit_outlined : Icons.help_outline_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              tr(_unknownHeight ? 'size_know_height' : 'size_dont_know_height'),
                              style: TextStyle(color: AppColors.primary, fontSize: 12.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================== 2) الجسم (العرض) ====================
                  SizeSectionCard(
                    icon: Icons.accessibility_new_rounded,
                    title: tr('size_body_section'),
                    subtitle: tr('size_body_hint'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        CustomFormField(
                          name: 'weight_kg',
                          label: tr('size_weight_label'),
                          hint: '60',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: digitsOnly,
                          validators: [
                            FormBuilderValidators.between(30, 250,
                                errorText: tr('size_err_weight_range'), checkNullOrEmpty: false),
                          ],
                        ),
                        Text(tr('size_or_clothing'),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        SizeChoiceChips(
                          options: _clothingOptions,
                          selected: _clothing,
                          onSelected: (v) => setState(() => _clothing = v),
                        ),
                        Text(tr('size_or_build'),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        SizeChoiceChips(
                          options: _buildOptions,
                          selected: _build,
                          onSelected: (v) => setState(() => _build = v),
                        ),
                      ],
                    ),
                  ),

                  // ==================== 3) محيط الصدر (اختياري - للدقة) ====================
                  SizeSectionCard(
                    icon: Icons.straighten_rounded,
                    title: tr('size_bust_section'),
                    subtitle: tr('size_bust_hint'),
                    child: _showBust
                        ? CustomFormField(
                            name: 'bust_cm',
                            label: tr('size_bust_label'),
                            hint: '95',
                            icon: Icons.straighten_rounded,
                            keyboardType: TextInputType.number,
                            inputFormatters: digitsOnly,
                            validators: [
                              FormBuilderValidators.between(60, 180,
                                  errorText: tr('size_err_bust_range'), checkNullOrEmpty: false),
                            ],
                          )
                        : Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton.icon(
                              onPressed: () => setState(() => _showBust = true),
                              icon: Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                              label: Text(tr('size_add_bust'),
                                  style: TextStyle(color: AppColors.primary, fontSize: 12.5)),
                            ),
                          ),
                  ),

                  // ==================== 4) تفضيل الطول ====================
                  SizeSectionCard(
                    icon: Icons.tune_rounded,
                    title: tr('size_pref_section'),
                    child: SizeChoiceChips(
                      options: _prefOptions,
                      selected: _pref,
                      allowDeselect: false,
                      onSelected: (v) => setState(() => _pref = v ?? 'normal'),
                    ),
                  ),

                  // ==================== زر الحساب ====================
                  BlocBuilder<SizePredictionCubit, SizePredictionState>(
                    builder: (context, state) {
                      final bool isLoading = state is SizePredictionLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: isDesktop ? 45 : 42,
                        child: AppButton(
                          label: isLoading ? '' : tr('size_predict_btn'),
                          icon: isLoading ? null : Icons.auto_awesome_rounded,
                          child: isLoading ? const CircularProgress(size: 20, color: Colors.white) : null,
                          onTap: isLoading ? null : _submit,
                        ),
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
