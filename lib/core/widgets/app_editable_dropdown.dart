import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../constants/app_colors.dart';

// قائمة منسدلة تقبل الاختيار أو الكتابة اليدوية
class AppEditableDropdown extends StatefulWidget {
  final String name;
  final String label;
  final String? hint;
  final IconData? icon;
  final List<String> options;
  final List<String? Function(String?)>? validators;

  const AppEditableDropdown({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    this.hint,
    this.icon,
    this.validators,
  });

  @override
  State<AppEditableDropdown> createState() => _AppEditableDropdownState();
}

class _AppEditableDropdownState extends State<AppEditableDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // نفس حدود قائمة البنوك والمحافظ
  OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: color, width: width),
  );

  // فلترة الخيارات حسب النص المكتوب
  Iterable<String> _filter(String text) {
    final query = text.trim().toLowerCase();
    if (query.isEmpty || widget.options.contains(text)) return widget.options;
    return widget.options.where((o) => o.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: widget.name,
      validator: widget.validators != null
          ? FormBuilderValidators.compose(widget.validators!)
          : null,
      builder: (field) {
        // مزامنة النص مع قيمة الحقل عند التعبئة أو التصفير
        final value = field.value ?? '';
        if (_controller.text != value) {
          _controller.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<String>(
              textEditingController: _controller,
              focusNode: _focusNode,
              optionsBuilder: (v) => _filter(v.text),
              onSelected: (selected) => field.didChange(selected),
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(color: AppColors.textColor, fontSize: 14),
                  onChanged: field.didChange,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    errorText: field.errorText,
                    errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
                    prefixIcon: widget.icon != null
                        ? Icon(widget.icon, color: AppColors.primary, size: 22)
                        : null,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
                      onPressed: () {
                        // فتح القائمة بالضغط على السهم
                        if (focusNode.hasFocus) {
                          focusNode.unfocus();
                        } else {
                          focusNode.requestFocus();
                        }
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    border: _border(AppColors.borderColor),
                    enabledBorder: _border(AppColors.borderColor),
                    focusedBorder: _border(AppColors.primary, 1.5),
                    errorBorder: _border(AppColors.error),
                    focusedErrorBorder: _border(AppColors.error, 1.5),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Material(
                      color: AppColors.backgroundSecondary,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(15),
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        // عرض القائمة بنفس عرض الحقل
                        constraints: BoxConstraints(
                          maxHeight: 220,
                          maxWidth: constraints.maxWidth,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      widget.icon ?? Icons.label_outline,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(color: AppColors.textColor, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}