import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/saved_size_model.dart';
import '../../../data/models/size_prediction_model.dart';
import '../../../logic/saved_sizes/saved_sizes_cubit.dart';
import '../../widgets/size_finder/saved_size_widgets.dart';
import '../../widgets/size_finder/size_finder_widgets.dart';
import '../smart chat screen/smart_chat_screen.dart';

class SizeResultScreen extends StatefulWidget {
  final SizeResultModel result;
  final SizeRequestModel? request; // بيانات الطلب لحفظها مع المقاس
  final List<SizeModel>? productSizes;

  const SizeResultScreen({super.key, required this.result, this.request, this.productSizes});

  @override
  State<SizeResultScreen> createState() => _SizeResultScreenState();
}

class _SizeResultScreenState extends State<SizeResultScreen> {
  final SavedSizesCubit _savedCubit = sl<SavedSizesCubit>();
  bool _saved = false;

  SizeResultModel get result => widget.result;
  List<SizeModel>? get productSizes => widget.productSizes;

  // هل المقاس المقترح متوفر في المنتج الحالي؟
  bool get _availableInProduct =>
      productSizes != null && productSizes!.any((s) => s.sizeName.trim() == '${result.abayaSize}');

  @override
  void dispose() {
    _savedCubit.close();
    super.dispose();
  }

  // حفظ المقاس في المقاسات المحفوظة
  Future<void> _saveSize() async {
    final name = await SaveSizeSheet.show(context, abayaSize: result.abayaSize!);
    if (name == null || !mounted) return;
    await _savedCubit.add(SavedSizeModel.fromResult(name: name, result: result, request: widget.request));
    if (!mounted) return;
    setState(() => _saved = true);
    AppToasts.showSuccessToast(context, tr('saved_size_done'));
  }

  // الرجوع يغلق صفحات المقاس ويعود للصفحة التي فُتحت منها (الملف الشخصي أو المنتج)
  void _closeFlow() => Navigator.of(context).pop(kSizeFlowClose);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final bool fromProduct = productSizes != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeFlow();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.background,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: Icon(Icons.verified_outlined, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
            titleSpacing: 0,
            title: AppTitle(
              firstPart: tr('size_result_first'),
              secondPart: tr('size_result_second'),
              fontSize: isDesktop ? 18 : 15,
              spacing: ' ',
            ),
            actions: [
              AppIcon(icon: Icons.arrow_forward_ios_outlined, onPressed: _closeFlow, color: AppColors.primary),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
              vertical: 10,
            ),
            child: Column(
              spacing: 14,
              children: [
                SizeResultHero(result: result),

                // ✂️ تعديل مطلوب (عرض أكبر من الطول)
                if (result.needsAlteration) SizeAlterationCard(result: result),

                // 📐 مواصفات المقاس
                if (result.specs != null) SizeSpecsCard(specs: result.specs!, abayaSize: result.abayaSize!),

                // 💡 الملاحظات القادمة من المحرك
                ...result.notes.map(
                      (key) => SizeNoteTile(
                    title: tr('size_note_title'),
                    text: tr(key, namedArgs: {'alt': '${result.altSize ?? ''}'}),
                  ),
                ),

                // 🧑‍💼 حالة تحتاج تأكيد من خدمة العملاء
                if (result.needsHuman)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const SmartChatScreen())),
                    child: SizeNoteTile(
                      text: tr('size_needs_human'),
                      icon: Icons.support_agent_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                // ⚠️ المقاس غير متوفر في هذا المنتج
                if (fromProduct && !_availableInProduct)
                  SizeNoteTile(
                    text: tr('size_not_available', namedArgs: {'size': '${result.abayaSize}'}),
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.redColor,
                  ),

                const SizedBox(height: 4),

                // ==================== الأزرار ====================
                if (fromProduct && _availableInProduct)
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 45 : 42,
                    child: AppButton(
                      label: tr('size_apply', namedArgs: {'size': '${result.abayaSize}'}),
                      icon: Icons.check_circle_outline_rounded,
                      onTap: () => Navigator.of(context).pop('${result.abayaSize}'),
                    ),
                  ),
                // حفظ المقاس للرجوع له لاحقاً
                SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 45 : 42,
                  child: AppButton(
                    label: tr(_saved ? 'saved_size_saved' : 'saved_size_save_btn'),
                    icon: _saved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                    color: _saved ? AppColors.primary.withOpacity(0.12) : null,
                    textColor: _saved ? AppColors.primary : Colors.white,
                    onTap: _saved ? null : _saveSize,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 45 : 42,
                  child: AppButton(
                    label: tr('size_recalculate'),
                    icon: Icons.refresh_rounded,
                    color: AppColors.background,
                    textColor: AppColors.textColor,
                    borderColor: AppColors.borderSecondary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}