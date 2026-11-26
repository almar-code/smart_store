import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/size_prediction_model.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../logic/size/size_cubit.dart';
import '../../../logic/size_prediction/size_prediction_cubit.dart';
import '../../../logic/size_prediction/size_prediction_state.dart';
import '../../screens/sizefinder/size_finder_screen.dart';
import '../../screens/sizefinder/size_result_screen.dart';

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

// ====================  أزرار اختيار (Chips) ====================
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

// ==================== بطاقة المقاس الرئيسية في صفحة النتيجة ====================
class SizeResultHero extends StatelessWidget {
  final SizeResultModel result;
  const SizeResultHero({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    final String message = tr(result.messageKey, namedArgs: {
      'width': '${result.widthSize ?? ''}',
      'length': '${result.lengthSize ?? ''}',
    });

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final double imageWidth = c.maxWidth * 0.42;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // لمسة خضراء خلف العباية
              PositionedDirectional(
                end: -c.maxWidth * 0.12,
                top: -c.maxWidth * 0.05,
                bottom: -c.maxWidth * 0.12,
                width: imageWidth + c.maxWidth * 0.12,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(400),
                      bottomStart: Radius.circular(120),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.28), AppColors.primary.withOpacity(0.06)],
                      begin: AlignmentDirectional.bottomEnd,
                      end: AlignmentDirectional.topStart,
                    ),
                  ),
                ),
              ),
              // المانيكان
              PositionedDirectional(
                end: -c.maxWidth * 0.04,
                top: 6,
                bottom: -18,
                width: imageWidth + c.maxWidth * 0.04,
                child: Image.asset(
                  'assets/images/size_result_mannequin1.png',
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 20 : 14, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        spacing: isDesktop ? 8 : 6,
                        children: [
                          ConfidenceBadge(confidence: result.confidence),
                          SizeRing(size: result.abayaSize ?? 0, diameter: isDesktop ? 118 : 88),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: isDesktop ? 15 : 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (result.finalLengthCm != null)
                            Text(
                              tr('size_final_length', namedArgs: {'cm': '${result.finalLengthCm}'}),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: isDesktop ? 11.5 : 10),
                            ),
                        ],
                      ),
                    ),
                    // مساحة المانيكان
                    SizedBox(width: imageWidth - 22),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// حلقة المقاس مع علامة الصح والنجوم
class SizeRing extends StatelessWidget {
  final int size;
  final double diameter;
  const SizeRing({super.key, required this.size, this.diameter = 128});

  static const _gradient = LinearGradient(
    colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter + 20,
      height: diameter + 6,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // الحلقة الخارجية
          Container(
            width: diameter,
            height: diameter,
            padding: EdgeInsets.all(diameter * 0.075),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient,
              boxShadow: [
                BoxShadow(color: const Color(0xFF03C383).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 6)),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card),
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFF0B7A62), Color(0xFF03C383)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(r),
                child: Text(
                  '$size',
                  style: TextStyle(color: Colors.white, fontSize: diameter * 0.36, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          // علامة الصح
          Positioned(
            bottom: 2,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(diameter * 0.035),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF03C383),
                border: Border.all(color: AppColors.card, width: 2.5),
              ),
              child: Icon(Icons.check_rounded, size: diameter * 0.17, color: Colors.white),
            ),
          ),
          // نجوم
          Positioned(
            top: 4,
            right: -2,
            child: Icon(Icons.auto_awesome, size: diameter * 0.15, color: const Color(0xFF03C383)),
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

// ==================== مواصفات المقاس ====================
class SizeSpecsCard extends StatelessWidget {
  final SizeSpecsModel specs;
  final int abayaSize;
  const SizeSpecsCard({super.key, required this.specs, required this.abayaSize});

  // 25.0 تظهر 25 و 29.75 كما هي
  String _num(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    Widget row(IconData icon, String labelKey, num value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.12)),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tr(labelKey), style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          ),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: _num(value),
                style: TextStyle(color: AppColors.textColor, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' ${tr('size_inch')}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ]),
          ),
        ],
      ),
    );

    Widget line() => Divider(height: 1, thickness: 0.6, color: AppColors.borderColor.withOpacity(0.35));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withOpacity(0.12),
                ),
                child: Transform.rotate(
                  angle: -0.6,
                  child: Icon(Icons.straighten_rounded, color: AppColors.primary, size: 22),
                ),
              ),
              Expanded(
                child: Text(
                  tr('size_specs_title', namedArgs: {'size': '$abayaSize'}),
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: isDesktop ? 18 : 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      row(Icons.height_rounded, 'size_spec_length', abayaSize),
                      line(),
                      row(Icons.swap_horiz_rounded, 'size_spec_width', specs.width),
                      line(),
                      row(Icons.checkroom_outlined, 'size_spec_sleeve', specs.sleeve),
                      if (specs.armhole > 0) ...[
                        line(),
                        row(Icons.circle_outlined, 'size_spec_armhole', specs.armhole),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // صورة العباية مع خطوط القياس
                Expanded(
                  flex: 4,
                  child: Image.asset(
                    'assets/images/size_abaya_back.png',
                    fit: BoxFit.contain,
                    height: isDesktop ? 260 : 220,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ملاحظة ====================
class SizeNoteTile extends StatelessWidget {
  final String text;
  final String? title;
  final IconData icon;
  final Color? color;
  const SizeNoteTile({
    super.key,
    required this.text,
    this.title,
    this.icon = Icons.lightbulb_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? const Color(0xFFF5A623);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, size: 28, color: c),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(color: AppColors.primary, fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                Text(text, style: TextStyle(color: AppColors.textColor, fontSize: 12.5, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================  زر "اعرفي مقاسك" في صفحة المنتج ====================
/// يُوضع في خانة viewMoreShow داخل TitleBar الخاص بالمقاسات.
/// بعد معرفة المقاس، يتم اختياره تلقائياً في DialogSizeCubit إن كان متوفراً.
class FindMySizeButton extends StatelessWidget {
  final List<SizeModel> sizes;
  const FindMySizeButton({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return const SizedBox.shrink(); // منتج بدون مقاسات
    return InkWell(
      borderRadius: BorderRadius.circular(7),
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
          borderRadius: BorderRadius.circular(7),
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

// قيمة ترجع من صفحة النتيجة لإغلاق كل صفحات المقاس والرجوع لما قبلها
const String kSizeFlowClose = '__size_flow_close__';

// ==================== متابعة نتيجة الحساب (مشترك بين اليدوي والصور) ====================
class SizePredictionListener extends StatelessWidget {
  final List<SizeModel>? productSizes;
  final Widget child;

  const SizePredictionListener({super.key, this.productSizes, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SizePredictionCubit, SizePredictionState>(
      listener: (context, state) async {
        if (state is SizePredictionSuccess) {
          final cubit = context.read<SizePredictionCubit>();
          final String? picked = await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (_) => SizeResultScreen(
                result: state.result,
                request: cubit.lastRequest,
                productSizes: productSizes,
              ),
            ),
          );
          cubit.reset();
          // تمرير المقاس المختار للصفحة السابقة
          if (picked != null && context.mounted) Navigator.of(context).pop(picked);
        } else if (state is SizePredictionNeedInput) {
          AppToasts.showWarningToast(context, tr(state.messageKey));
        } else if (state is SizePredictionError) {
          AppToasts.showErrorToast(context, tr(state.message));
        }
      },
      child: child,
    );
  }
}

// ==================== رأس صفحة اختيار الطريقة ====================
class SizeMethodHeader extends StatelessWidget {
  const SizeMethodHeader({super.key});

  // ألوان ثابتة لأن خلفية الصورة فاتحة في الوضعين
  static const Color _titleColor = Color(0xFF1E293B);
  static const Color _subtitleColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isTablet = width > 600;
    final double height = isDesktop ? 260 : (isTablet ? 220 : 175);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: [
            // الصورة بالعرض كامل مع بقاء المانيكان ظاهر يميناً
            Positioned.fill(
              child: Image.asset(
                'assets/images/size_header.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            // النص فوق الجزء الفارغ من الصورة
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: isTablet ? 0.55 : 0.6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: isDesktop ? 12 : 8,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: isDesktop ? 28 : (isTablet ? 22 : 18),
                            fontWeight: FontWeight.bold,
                            color: _titleColor,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(text: '${tr('size_method_title_1')} '),
                            TextSpan(text: tr('size_method_title_2'), style: TextStyle(color: AppColors.primary)),
                            TextSpan(text: ' ${tr('size_method_title_3')}'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // خط تحت العنوان
                      Container(
                        width: isDesktop ? 80 : 56,
                        height: 3.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(colors: [Color(0xFF03C383), Color(0xFF25F5FC)]),
                        ),
                      ),
                      Text(
                        tr('size_method_subtitle'),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _subtitleColor,
                          fontSize: isDesktop ? 14 : (isTablet ? 12.5 : 11),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== بطاقة اختيار طريقة القياس ====================
class SizeMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> points;
  final String image;
  final String? badge;
  final bool highlighted;
  final VoidCallback onTap;

  const SizeMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.points,
    required this.image,
    required this.onTap,
    this.badge,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: highlighted ? AppColors.primary.withOpacity(0.35) : AppColors.borderColor.withOpacity(0.25),
              width: highlighted ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (highlighted ? AppColors.primary : Colors.black).withOpacity(highlighted ? 0.10 : 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // النصوص
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: highlighted ? AppColors.primary : AppColors.primary.withOpacity(0.12),
                              ),
                              child: Icon(icon, size: 26, color: highlighted ? Colors.white : AppColors.primary),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: isDesktop ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.6),
                            ),
                            const SizedBox(height: 12),
                            ...points.map(
                                  (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    Icon(Icons.check_rounded, size: 17, color: AppColors.primary),
                                    Expanded(
                                      child: Text(p, style: TextStyle(color: AppColors.textColor, fontSize: 12.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // الصورة التوضيحية وزر البدء
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            SizedBox(height: badge != null ? 26 : 8),
                            Image.asset(image, fit: BoxFit.contain),
                            const Spacer(),
                            _StartButton(label: tr('size_method_start')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // شارة الأدق
              if (badge != null)
                PositionedDirectional(
                  top: 14,
                  end: 16,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const PositionedDirectional(
                        top: -12,
                        end: -8,
                        child: Icon(Icons.auto_awesome, size: 16, color: Color(0xFFF5C542)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// زر "ابدئي الآن" داخل البطاقة
class _StartButton extends StatelessWidget {
  final String label;
  const _StartButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textColor, fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ==================== شريط الخصوصية أسفل صفحة الاختيار ====================
class SizePrivacyBar extends StatelessWidget {
  const SizePrivacyBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tr('size_method_privacy'),
              style: TextStyle(color: AppColors.textColor, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.primary.withOpacity(0.25),
          ),
          Icon(Icons.verified_user_outlined, size: 24, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ==================== خانة صورة (أمامية أو جانبية) ====================
class SizePhotoSlot extends StatelessWidget {
  final String label;
  final bool isSide;
  final Uint8List? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const SizePhotoSlot({
    super.key,
    required this.label,
    required this.isSide,
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photo != null;
    return Column(
      spacing: 8,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasPhoto ? AppColors.primary : AppColors.primary.withOpacity(0.25),
                    width: hasPhoto ? 1.6 : 1,
                  ),
                ),
                child: hasPhoto
                    ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(photo!, fit: BoxFit.cover),
                    // زر حذف الصورة
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: InkWell(
                        onTap: onRemove,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black.withOpacity(0.55),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
                    : Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    spacing: 8,
                    children: [
                      // صورة توضيحية لوضعية الوقوف
                      Expanded(
                        child: Image.asset(
                          isSide ? 'assets/images/size_pose_side1.jpg' : 'assets/images/size_pose_front1.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 15, color: AppColors.primary),
                          Flexible(
                            child: Text(
                              tr('size_photo_add'),
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Icon(
              hasPhoto ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 15,
              color: hasPhoto ? AppColors.primary : AppColors.textSecondary,
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textColor, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== خطوة مرقمة في إرشادات التصوير ====================
class SizeGuideStep extends StatelessWidget {
  final int number;
  final String text;

  const SizeGuideStep({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Text(
            '$number',
            style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(text, style: TextStyle(color: AppColors.textColor, fontSize: 12.5, height: 1.5)),
        ),
      ],
    );
  }
}