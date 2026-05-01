import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/constants/app_colors.dart'; // تأكد من ضبط المسار الصحيح

class CustomFormField extends StatelessWidget {
  final String name;
  final String label;
  final String? hint;
  final IconData? icon;
  final int maxLines;
  final Color? color;
  final List<String? Function(String?)>? validators;
  final TextInputType keyboardType;
  const CustomFormField({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    this.icon,
    this.maxLines = 1,
    this.validators,
    this.color ,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        // الأيقونة تظهر في البداية (يسار في الإنجليزي)
        prefixIcon: icon != null
            ? Icon(icon, color: color ?? AppColors.primary, size: 20)
            : null,
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 13),
        filled: true,
        fillColor: AppColors.backgroundSecondary.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

        // حواف دائرية (7.0) كما في الكود الخاص بك
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: color ?? AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
      ),
      validator: validators != null
          ? FormBuilderValidators.compose(validators!)
          : null,
    );
  }
}