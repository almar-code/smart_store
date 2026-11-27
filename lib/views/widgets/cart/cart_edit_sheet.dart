import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_endpoints.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/colors/circleOfColor.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/cart/cart_cubit.dart';

// نافذة تعديل لون ومقاس الصنف
class CartEditSheet {
  static Future<void> show(BuildContext context, CartModel item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: _CartEditBody(item: item, screenContext: context),
      ),
    );
  }
}

class _CartEditBody extends StatefulWidget {
  final CartModel item;
  final BuildContext screenContext;

  const _CartEditBody({required this.item, required this.screenContext});

  @override
  State<_CartEditBody> createState() => _CartEditBodyState();
}

class _CartEditBodyState extends State<_CartEditBody> {
  ColorModel? _color;
  SizeModel? _size;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    // مطابقة الاختيار الحالي مع القوائم المتاحة
    _color = _findColor(item.selectedColor?.colorId) ?? (item.productColors.isNotEmpty ? item.productColors.first : null);
    _size = _findSize(item.selectedSize?.sizeId) ?? (item.productSizes.isNotEmpty ? item.productSizes.first : null);
  }

  ColorModel? _findColor(int? id) {
    for (final c in widget.item.productColors) {
      if (c.colorId == id) return c;
    }
    return null;
  }

  SizeModel? _findSize(int? id) {
    for (final s in widget.item.productSizes) {
      if (s.sizeId == id) return s;
    }
    return null;
  }

  bool get _changed =>
      _color?.colorId != widget.item.selectedColor?.colorId || _size?.sizeId != widget.item.selectedSize?.sizeId;

  String _colorName(ColorModel c) =>
      context.locale.languageCode == 'ar' ? c.colorName : (c.colorNameEn ?? c.colorName);

  Future<void> _save() async {
    if (!_changed || _saving) return;
    setState(() => _saving = true);
    final ok = await context.read<CartCubit>().updateItemOptions(
      product: widget.item,
      color: _color?.colorId != widget.item.selectedColor?.colorId ? _color : null,
      size: _size?.sizeId != widget.item.selectedSize?.sizeId ? _size : null,
      context: widget.screenContext,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final item = widget.item;
    final isAr = context.locale.languageCode == 'ar';
    final images = _color?.images ?? [];
    final image = images.isNotEmpty ? images.first.imgUrl : item.displayImage;

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + media.padding.bottom + media.viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('cart_edit_item'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.iconColor, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(height: 1, color: AppColors.borderColor.withOpacity(0.5)),
          const SizedBox(height: 14),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معاينة المنتج بالصورة حسب اللون المختار
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: CachedNetworkImage(
                            key: ValueKey(image),
                            imageUrl: ApiEndpoints.productImageUrl(image),
                            width: 70,
                            height: 88,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Image.asset(
                              'assets/images/app icon/icon.png',
                              width: 70,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? item.productName : (item.productNameEn ?? item.productName),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${item.unitPrice.toStringAsFixed(2)} \$",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  if (!item.canEditOptions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        tr('cart_no_options'),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),

                  // قائمة الالوان
                  if (item.productColors.isNotEmpty) ...[
                    _label(tr('cart_choose_color')),
                    _dropdown<ColorModel>(
                      value: _color,
                      icon: Icons.palette_outlined,
                      items: item.productColors
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            CircleOfColor(width: 16, height: 16, code: c.colorCode ?? "#000000"),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _colorName(c),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: AppColors.textColor),
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (c) => setState(() => _color = c),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // قائمة المقاسات
                  if (item.productSizes.isNotEmpty) ...[
                    _label(tr('cart_choose_size')),
                    _dropdown<SizeModel>(
                      value: _size,
                      icon: Icons.straighten_rounded,
                      items: item.productSizes
                          .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.sizeName, style: TextStyle(fontSize: 13, color: AppColors.textColor)),
                      ))
                          .toList(),
                      onChanged: (s) => setState(() => _size = s),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _changed ? 1 : 0.5,
                      child: AppButton(
                        label: tr('cart_save_changes'),
                        icon: _saving ? null : CupertinoIcons.checkmark_alt,
                        onTap: _changed && !_saving ? _save : null,
                        child: _saving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
    child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );

  // قائمة منسدلة بنفس هوية الحقول
  Widget _dropdown<T>({
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderColor),
    );
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: _saving ? null : onChanged,
      isExpanded: true,
      dropdownColor: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(CupertinoIcons.chevron_down, size: 16, color: AppColors.iconColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}