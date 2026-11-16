import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../data/local/reels_local.dart';
import '../../../logic/videos/video_cubit.dart';
import '../../widgets/reels/reel_grid_tile.dart';
import 'reels_player_screen.dart';

class SavedReelsScreen extends StatelessWidget {
  const SavedReelsScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          tr('clear_saved_title'),
          style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(tr('clear_saved_msg'), style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('cancel'), style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('clear_all'), style: TextStyle(color: AppColors.redColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<VideoCubit>().clearSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isAr = context.locale.languageCode == 'ar';

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: Icon(CupertinoIcons.bookmark, size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('first saved'),
            secondPart: tr('second saved'),
            fontSize: isDesktop ? 18 : 15,
            spacing: isAr ? ' ' : ' ',
          ),
          actions: [
            ValueListenableBuilder<Box>(
              valueListenable: ReelsLocal.listenable(),
              builder: (context, _, __) => ReelsLocal.savedVideos().isEmpty
                  ? const SizedBox()
                  : AppIcon(
                icon: CupertinoIcons.trash,
                color: AppColors.redColor,
                onPressed: () => _confirmClear(context),
              ),
            ),
            const ArrowBack(),
            const SizedBox(width: 10),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientTop, AppColors.gradientBottom],
            ),
          ),
          child: const SavedReelsGrid(),
        ),
      ),
    );
  }
}

// شبكة المحفوظات تستخدم هنا وفي صفحة المتجر
class SavedReelsGrid extends StatelessWidget {
  const SavedReelsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: ReelsLocal.listenable(),
      builder: (context, _, __) {
        final saved = ReelsLocal.savedVideos();
        if (saved.isEmpty) return const _EmptySaved();

        return LayoutBuilder(
          builder: (context, box) {
            final cols = (box.maxWidth / 170).floor().clamp(3, 6);
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 9 / 16,
              ),
              itemCount: saved.length,
              itemBuilder: (_, i) => ReelGridTile(
                video: saved[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReelsPlayerScreen(videos: saved, initialIndex: i)),
                ),
                onRemove: () => context.read<VideoCubit>().toggleSave(saved[i]),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
                border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 12),
              ),
              child: Icon(CupertinoIcons.bookmark, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              tr('no_saved_reels'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor),
            ),
            const SizedBox(height: 6),
            Text(
              tr('no_saved_hint'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}