import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/size_prediction_model.dart';
import '../../../logic/size/size_cubit.dart';
import '../../screens/sizefinder/size_finder_screen.dart';

// ==================== 📦 بطاقة قسم في النموذج ====================
class SizeSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const SizeSectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.boxShadow.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ==================== 🔘 أزرار اختيار (Chips) ====================
/// options: القيمة المرسلة للسيرفر -> مفتاح الترجمة
class SizeChoiceChips extends StatelessWidget {
  final Map<String, String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool allowDeselect;

  const SizeChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final bool isSelected = selected == entry.key;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelected(isSelected && allowDeselect ? null : entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppShadow.commonShadow,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderColor.withOpacity(0.2),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Text(
              tr(entry.value),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==================== 📏 تبديل وحدة الطول (سم / قدم) ====================
class HeightUnitToggle extends StatelessWidget {
  final bool isCm;
  final ValueChanged<bool> onChanged;

  const HeightUnitToggle({super.key, required this.isCm, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget item(String label, bool active, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          item(tr('size_unit_cm'), isCm, () => onChanged(true)),
          item(tr('size_unit_ft'), !isCm, () => onChanged(false)),
        ],
      ),
    );
  }
}

// ==================== 🏅 شارة درجة الثقة ====================
class ConfidenceBadge extends StatelessWidget {
  final String confidence;
  const ConfidenceBadge({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (confidence) {
      'high' => AppColors.primary,
      'medium' => const Color(0xFFF5A623),
      _ => AppColors.redColor,
    };
    final IconData icon = switch (confidence) {
      'high' => Icons.verified_rounded,
      'medium' => Icons.info_outline_rounded,
      _ => Icons.help_outline_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 14, color: color),
          Text(
            tr('size_confidence_$confidence'),
            style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ==================== ✨ بطاقة المقاس الرئيسية في صفحة النتيجة ====================
class SizeResultHero extends StatelessWidget {
  final SizeResultModel result;
  const SizeResultHero({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final String message = tr(result.messageKey, namedArgs: {
      'width': '${result.widthSize ?? ''}',
      'length': '${result.lengthSize ?? ''}',
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        boxShadow: AppShadow.commonShadow,
      ),
      child: Column(
        spacing: 10,
        children: [
          ConfidenceBadge(confidence: result.confidence),
          Container(
            width: 110,
            height: 110,
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
              '${result.abayaSize}',
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textColor, fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
          if (result.finalLengthCm != null)
            Text(
              tr('size_final_length', namedArgs: {'cm': '${result.finalLengthCm}'}),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
        ],
      ),
    );
  }
}

// ==================== ✂️ بطاقة التعديل المطلوب (التقصير) ====================
class SizeAlterationCard extends StatelessWidget {
  final SizeResultModel result;
  const SizeAlterationCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    Widget cell(String labelKey, int? value) => Expanded(
          child: Column(
            spacing: 4,
            children: [
              Text(tr(labelKey), style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
              Text(
                '${value ?? '-'}',
                style: TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

    return SizeSectionCard(
      icon: Icons.content_cut_rounded,
      title: tr('size_alteration_title'),
      subtitle: tr('size_alteration_subtitle'),
      child: Row(
        children: [
          cell('size_width_size', result.widthSize),
          Container(width: 1, height: 36, color: AppColors.borderColor),
          cell('size_length_size', result.lengthSize),
        ],
      ),
    );
  }
}

// ==================== 📐 مواصفات المقاس ====================
class SizeSpecsCard extends StatelessWidget {
  final SizeSpecsModel specs;
  final int abayaSize;
  const SizeSpecsCard({super.key, required this.specs, required this.abayaSize});

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String labelKey, num value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tr(labelKey), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              Text(
                '$value ${tr('size_inch')}',
                style: TextStyle(color: AppColors.textColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

    return SizeSectionCard(
      icon: Icons.straighten_rounded,
      title: tr('size_specs_title', namedArgs: {'size': '$abayaSize'}),
      child: Column(
        children: [
          row(Icons.height_rounded, 'size_spec_length', abayaSize),
          row(Icons.swap_horiz_rounded, 'size_spec_width', specs.width),
          row(Icons.back_hand_outlined, 'size_spec_sleeve', specs.sleeve),
          row(Icons.circle_outlined, 'size_spec_armhole', specs.armhole),
        ],
      ),
    );
  }
}

// ==================== 💡 ملاحظة ====================
class SizeNoteTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  const SizeNoteTile({super.key, required this.text, this.icon = Icons.lightbulb_outline_rounded, this.color});

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? const Color(0xFFF5A623);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: AppColors.textColor, fontSize: 12.5, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ==================== 🔗 زر "اعرفي مقاسك" في صفحة المنتج ====================
/// يُوضع في خانة viewMoreShow داخل TitleBar الخاص بالمقاسات.
/// بعد معرفة المقاس، يتم اختياره تلقائياً في DialogSizeCubit إن كان متوفراً.
class FindMySizeButton extends StatelessWidget {
  final List<SizeModel> sizes;
  const FindMySizeButton({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return const SizedBox.shrink(); // منتج بدون مقاسات
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final String? picked = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (_) => SizeFinderScreen(productSizes: sizes)),
        );
        if (picked == null || !context.mounted) return;
        final match = sizes.where((s) => s.sizeName.trim() == picked).toList();
        if (match.isNotEmpty) context.read<DialogSizeCubit>().selectSize(match.first);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(Icons.straighten_rounded, size: 14, color: AppColors.primary),
            Text(
              tr('find_my_size'),
              style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
