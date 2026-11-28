import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../data/models/saved_size_model.dart';
import 'size_finder_widgets.dart';

// لون البطاقة حسب درجة الدقة
Color savedSizeColor(String confidence) => switch (confidence) {
  'high' => AppColors.primary,
  'medium' => const Color(0xFFF5A623),
  _ => AppColors.redColor,
};

// ==================== نافذة تسمية المقاس قبل الحفظ ====================
/// ترجع الاسم المكتوب أو null عند الإلغاء
class SaveSizeSheet extends StatefulWidget {
  final int abayaSize;
  final String? initialName;
  final bool isRename;

  const SaveSizeSheet({super.key, required this.abayaSize, this.initialName, this.isRename = false});

  static Future<String?> show(BuildContext context, {required int abayaSize, String? initialName, bool isRename = false}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (_) => SaveSizeSheet(abayaSize: abayaSize, initialName: initialName, isRename: isRename),
    );
  }

  @override
  State<SaveSizeSheet> createState() => _SaveSizeSheetState();
}

class _SaveSizeSheetState extends State<SaveSizeSheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  // أسماء جاهزة للاختيار السريع
  static const List<String> _quickNames = [
    'saved_size_name_me',
    'saved_size_name_mother',
    'saved_size_name_sister',
    'saved_size_name_daughter',
  ];

  void _save() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    Navigator.pop(context, _formKey.currentState!.value['size_name'].toString().trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // رفع النافذة فوق الكيبورد
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.ContainerColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderSecondary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 14,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(4)),
                ),
                // دائرة المقاس
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(
                    '${widget.abayaSize}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  tr(widget.isRename ? 'saved_size_rename_title' : 'saved_size_save_title'),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textColor),
                ),
                Text(
                  tr('saved_size_save_hint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                CustomFormField(
                  name: 'size_name',
                  label: tr('saved_size_name_label'),
                  icon: Icons.person_outline_rounded,
                  initialValue: widget.initialName ?? tr('saved_size_name_me'),
                  validators: [
                    FormBuilderValidators.required(errorText: tr('size_required')),
                    FormBuilderValidators.maxLength(20, errorText: tr('saved_size_name_long')),
                  ],
                ),
                // اختيار سريع للاسم
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _quickNames
                      .map((key) => ActionChip(
                    label: Text(tr(key), style: TextStyle(fontSize: 12, color: AppColors.textColor)),
                    backgroundColor: AppColors.background,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _formKey.currentState?.fields['size_name']?.didChange(tr(key)),
                  ))
                      .toList(),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: AppButton(
                    label: tr(widget.isRename ? 'saved_size_rename_btn' : 'saved_size_save_btn'),
                    icon: Icons.bookmark_add_outlined,
                    borderRadius: 17,
                    onTap: _save,
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

// ==================== تفاصيل المقاس داخل البطاقة المفتوحة ====================
class SavedSizeDetails extends StatelessWidget {
  final SavedSizeModel size;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const SavedSizeDetails({super.key, required this.size, required this.onRename, required this.onDelete});

  String _num(double? v) => v == null ? '-' : (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textColor),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final String inch = tr('size_inch');
    return Column(
      children: [
        const SizedBox(height: 15),
        const Divider(thickness: 0.5),
        Row(
          children: [
            ConfidenceBadge(confidence: size.confidence),
            const Spacer(),
            Text(
              tr(size.method == 'photo' ? 'saved_size_by_photo' : 'saved_size_by_manual'),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _row(tr('saved_size_abaya'), '${size.abayaSize}'),
        if (size.cutLengthTo != null) _row(tr('saved_size_cut'), '${size.cutLengthTo}'),
        if (size.lengthSize != null && size.widthSize != null)
          _row('${tr('size_length_size')} / ${tr('size_width_size')}', '${size.lengthSize} / ${size.widthSize}'),
        if (size.finalLengthCm != null) _row(tr('saved_size_final_length'), '${size.finalLengthCm} ${tr('saved_size_cm')}'),
        if (size.specWidth != null) _row(tr('size_spec_width'), '${_num(size.specWidth)} $inch'),
        if (size.specSleeve != null) _row(tr('size_spec_sleeve'), '${_num(size.specSleeve)} $inch'),
        if (size.specArmhole != null && size.specArmhole! > 0) _row(tr('size_spec_armhole'), '${_num(size.specArmhole)} $inch'),
        if (size.heightCm != null) _row(tr('saved_size_height'), '${_num(size.heightCm)} ${tr('saved_size_cm')}'),
        if (size.weightKg != null) _row(tr('saved_size_weight'), '${_num(size.weightKg)} ${tr('saved_size_kg')}'),
        _row(tr('saved_size_date'), DateHelper.formatDateOnly(size.savedAt.toIso8601String())),
        const SizedBox(height: 15),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: tr('saved_size_rename'),
                  icon: Icons.edit_outlined,
                  borderRadius: 17,
                  onTap: onRename,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: tr('delete'),
                  icon: Icons.delete_outline_rounded,
                  borderRadius: 17,
                  color: AppColors.background,
                  textColor: AppColors.redColor,
                  borderColor: AppColors.redColor.withOpacity(0.4),
                  onTap: onDelete,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== حالة عدم وجود مقاسات ====================
class SavedSizesEmpty extends StatelessWidget {
  final VoidCallback onFindSize;
  const SavedSizesEmpty({super.key, required this.onFindSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        spacing: 12,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.08)),
            child: Icon(Icons.bookmarks_outlined, size: 40, color: AppColors.primary),
          ),
          Text(
            tr('saved_sizes_empty_title'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
          ),
          Text(
            tr('saved_sizes_empty_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 220,
            height: 45,
            child: AppButton(
              label: tr('find_my_size'),
              icon: Icons.straighten_rounded,
              borderRadius: 17,
              onTap: onFindSize,
            ),
          ),
        ],
      ),
    );
  }
}
