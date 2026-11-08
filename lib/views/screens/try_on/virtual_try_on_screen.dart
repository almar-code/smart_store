import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/three_dots_loader.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../logic/try_on/try_on_cubit.dart';
import '../../../logic/try_on/try_on_state.dart';

/// 👗 شاشة التجربة الافتراضية للعباية
/// [garmentUrl] = ApiEndpoints.productImageUrl(item.pImage)
class VirtualTryOnScreen extends StatelessWidget {
  final String garmentUrl;

  const VirtualTryOnScreen({super.key, required this.garmentUrl});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocProvider<TryOnCubit>(
      // 🚀 تنزيل صورة العباية في الخلفية فور فتح الشاشة
      create: (_) => di.sl<TryOnCubit>()..loadGarment(garmentUrl),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'virtual_try_on'.tr(),
              style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            actions: const [ArrowBack()],
          ),
          body: BlocConsumer<TryOnCubit, TryOnState>(
            listenWhen: (prev, curr) => curr.status == TryOnStatus.error && curr.errorKey != null,
            listener: (context, state) {
              final key = state.errorKey!;
              if (key.contains('full_body_required')) {
                AppToasts.showWarningToast(context,tr('full_body_required'));
              } else {
                AppToasts.showErrorToast(context, key.tr());
              }
            },            builder: (context, state) {
              final inputs = _buildInputs(context, state);
              final result = _ResultView(state: state);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: isDesktop
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Expanded(child: SingleChildScrollView(child: inputs)),
                    Expanded(child: result),
                  ],
                )
                    : SingleChildScrollView(
                  child: Column(
                    spacing: 12,
                    children: [
                      inputs,
                      SizedBox(height: 420, child: result),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BlocBuilder<TryOnCubit, TryOnState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 45,
                  child: AppButton(
                    label: 'try_on_start'.tr(),
                    icon: Icons.auto_awesome,
                    iconSize: 18,
                    onTap: state.isLoading ? null : () => context.read<TryOnCubit>().startTryOn(garmentUrl),
                    child: state.isLoading ? const CircularProgress(color: Colors.white,size: 20,) : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputs(BuildContext context, TryOnState state) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    bool isIpad = MediaQuery.of(context).size.width < 900 && MediaQuery.of(context).size.width > 450;
    double height = isDesktop ? 500 : isIpad ? 310 : 230;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        // 1️⃣ صورة العميلة + صورة العباية جنباً إلى جنب
        SizedBox(
          height: height,
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: _ImageCard(
                  label: 'try_on_your_photo'.tr(),
                  onTap: state.isLoading ? null : () => _showSourcePicker(context),
                  child: state.personImage != null
                      ? Image.memory(state.personImage!, fit: BoxFit.contain)
                      : const _EmptyPhotoHint(),
                ),
              ),
              Expanded(
                child: _ImageCard(
                  label: 'try_on_garment'.tr(),
                  // عرض صورة المنتج من الرابط مباشرة (والتنزيل يتم بالخلفية في الكيوبت)
                  child: Image.network(
                    garmentUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(child: ThreeDotsLoader()),
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/image_placeholder.png', fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2️⃣ نصائح لأفضل نتيجة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              Expanded(
                child: Text(
                  'try_on_tips'.tr(),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.6),
                ),
              ),
            ],
          ),
        ),

        // 3️⃣ نوع القطعة
        TitleBar(title: 'try_on_cloth_type'.tr(), isDecoration: false),
        _ClothTypeSelector(selected: state.clothType, enabled: !state.isLoading),
      ],
    );
  }

  void _showSourcePicker(BuildContext context) {
    final cubit = context.read<TryOnCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: AppIcon(icon: Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('try_on_camera'.tr(), style: TextStyle(color: AppColors.textColor)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.pickPersonImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: AppIcon(icon: Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('try_on_gallery'.tr(), style: TextStyle(color: AppColors.textColor)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.pickPersonImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة صورة بنفس شكل صور المنتج في التطبيق
class _ImageCard extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  const _ImageCard({required this.label, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(label, style: TextStyle(color: AppColors.textColor, fontSize: 13, fontWeight: FontWeight.w600)),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: AppShadow.commonShadow,
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPhotoHint extends StatelessWidget {
  const _EmptyPhotoHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 34),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'try_on_add_photo'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// اختيار نوع القطعة بنفس تصميم اختيار المقاسات
class _ClothTypeSelector extends StatelessWidget {
  final String selected;
  final bool enabled;

  const _ClothTypeSelector({required this.selected, required this.enabled});

  static const _types = ['overall', 'upper', 'lower'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _types.map((type) {
          final bool isSelected = selected == type;
          return InkWell(
            onTap: enabled ? () => context.read<TryOnCubit>().changeClothType(type) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: AppShadow.commonShadow,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderColor.withValues(alpha: 0.2),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Text(
                'try_on_type_$type'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// منطقة عرض النتيجة (فارغة / جاري المعالجة / النتيجة)
class _ResultView extends StatelessWidget {
  final TryOnState state;

  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (state.isLoading) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          const ThreeDotsLoader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'try_on_processing'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      );
    } else if (state.resultImage != null) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(state.resultImage!, fit: BoxFit.contain),
          PositionedDirectional(
            top: 10,
            end: 10,
            child: AppIcon(
              icon: Icons.share_outlined,
              color: AppColors.primary,
              onPressed: () => context.read<TryOnCubit>().shareResult('try_on_share_text'.tr()),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Icon(Icons.checkroom_outlined, color: AppColors.primary, size: 40),
          Text(
            'try_on_result_hint'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        TitleBar(title: 'try_on_result'.tr(), isDecoration: false),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
          ),
        ),
      ],
    );
  }
}
