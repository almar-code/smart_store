import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/constants/app_colors.dart';

class CustomFormField extends StatefulWidget {
  final String name;
  final String label;
  final String? hint;
  final IconData? icon;
  final int maxLines;
  final Color? color;
  final Color? labelColor;
  final List<String? Function(String?)>? validators;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool isPasswordField; // خاصية لتحديد ما إذا كان الحقل كلمة مرور
  final List<TextInputFormatter>? inputFormatters; // علشان افلتر الحفل يقبل ارقام فقط

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
    this.initialValue,
    this.isPasswordField = false, // القيمة الافتراضية ليست كلمة مرور
    this.inputFormatters,
    this.labelColor
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  // متغير للتحكم في إخفاء النص أو إظهاره
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // يبدأ النص مخفياً إذا كان الحقل مخصصاً لكلمة المرور
    _obscureText = widget.isPasswordField;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      // حقل كلمة المرور يجب أن يكون سطر واحد دائماً ليعمل الإخفاء بشكل صحيح
      maxLines: widget.isPasswordField ? 1 : widget.maxLines,
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText, // ربط المتغير بخاصية الإخفاء
      style: TextStyle(color: AppColors.textColor, fontSize: 14),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: widget.inputFormatters,


      decoration: InputDecoration(

        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.primary, size: 20)
            : null,

        // إضافة أيقونة العين فقط إذا كان الحقل لكلمة المرور
        suffixIcon: widget.isPasswordField
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: () {
            // تحديث الحالة لتبديل الإخفاء والإظهار
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,


        labelStyle: TextStyle(color: widget.labelColor ?? AppColors.textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),        // hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 13),
        // filled: true,
        // fillColor: AppColors.backgroundSecondary.withOpacity(0.3),
        // contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.9),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
      ),
      validator: widget.validators != null
          ? FormBuilderValidators.compose(widget.validators!)
          : null,
    );
  }
}