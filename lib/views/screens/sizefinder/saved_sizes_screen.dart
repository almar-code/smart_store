import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/cards/drop_card.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../data/models/saved_size_model.dart';
import '../../../logic/saved_sizes/saved_sizes_cubit.dart';
import '../../../logic/saved_sizes/saved_sizes_state.dart';
import '../../widgets/size_finder/saved_size_widgets.dart';
import 'size_finder_screen.dart';

// المقاسات المحفوظة للعميلة
class SavedSizesScreen extends StatelessWidget {
  const SavedSizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SavedSizesCubit>()..load(),
      child: const SavedSizesView(),
    );
  }
}

class SavedSizesView extends StatelessWidget {
  const SavedSizesView({super.key});

  Future<void> _rename(BuildContext context, SavedSizeModel size) async {
    final cubit = context.read<SavedSizesCubit>();
    final name = await SaveSizeSheet.show(context, abayaSize: size.abayaSize, initialName: size.name, isRename: true);
    if (name != null) await cubit.rename(size.id, name);
  }

  Future<void> _delete(BuildContext context, SavedSizeModel size) async {
    final cubit = context.read<SavedSizesCubit>();
    final ok = await AppToasts.showConfirmDialog(
      context: context,
      title: tr('saved_size_delete_title'),
      message: tr('saved_size_delete_msg', namedArgs: {'name': size.name}),
    );
    if (ok == true) await cubit.delete(size.id);
  }

  // بعد الحساب الجديد نعيد قراءة القائمة
  Future<void> _findSize(BuildContext context) async {
    final cubit = context.read<SavedSizesCubit>();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SizeFinderScreen()));
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Icon(Icons.bookmarks_outlined, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('saved_sizes_first'),
            secondPart: tr('saved_sizes_second'),
            fontSize: isDesktop ? 18 : 15,
            spacing: ' ',
          ),
          actions: const [ArrowBack()],
        ),
        body: BlocBuilder<SavedSizesCubit, SavedSizesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? width * 0.2 : 16,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.items.isEmpty)
                    Center(child: SavedSizesEmpty(onFindSize: () => _findSize(context)))
                  else ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 15),
                      child: Row(
                        children: [
                          Text(
                            tr('saved_sizes_list_title'),
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          // إضافة مقاس جديد
                          TextButton.icon(
                            onPressed: () => _findSize(context),
                            icon: Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                            label: Text(
                              tr('saved_sizes_add'),
                              style: TextStyle(color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.items.map(
                          (size) => DropCard(
                        title: size.name,
                        subtitle: tr('saved_size_subtitle', namedArgs: {
                          'size': '${size.abayaSize}',
                          'date': DateHelper.formatDateOnly(size.savedAt.toIso8601String()),
                        }),
                        icon: size.method == 'photo' ? Icons.photo_camera_outlined : Icons.straighten_rounded,
                        color: savedSizeColor(size.confidence),
                        isSelected: state.openId == size.id,
                        onTap: () => context.read<SavedSizesCubit>().toggle(size.id),
                        expandedContent: SavedSizeDetails(
                          size: size,
                          onRename: () => _rename(context, size),
                          onDelete: () => _delete(context, size),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
