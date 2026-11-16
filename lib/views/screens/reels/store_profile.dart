import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/compact_count.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../logic/videos/video_cubit.dart';
import '../../../logic/videos/video_state.dart';
import '../../widgets/reels/reel_grid_tile.dart';
import '../../widgets/reels/reel_item.dart';
import 'reels_player_screen.dart';
import 'saved_reels_screen.dart';

class StoreProfile extends StatelessWidget {
  final bool isAppBar;
  const StoreProfile({super.key, this.isAppBar = false});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: isAppBar
            ? AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 10,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Logo(height: isDesktop ? 30 : 27, width: isDesktop ? 30 : 27),
              const SizedBox(width: 6),
              AppTitle(fontSize: isDesktop ? 20 : 17),
            ],
          ),
          actions: const [ArrowBack(), SizedBox(width: 10)],
        )
            : null,
        body: SafeArea(
          child: BlocBuilder<VideoCubit, VideoState>(
            builder: (context, state) {
              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(child: _Header(data: state is VideoLoaded ? state : null)),
                  SliverPersistentHeader(pinned: true, delegate: _TabsDelegate()),
                ],
                body: TabBarView(
                  children: [
                    _AllReelsGrid(state: state),
                    const SavedReelsGrid(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VideoLoaded? data;
  const _Header({this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // صورة بإطار متدرج
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.35)]),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
                  child: CircleImage(imagePath: storeLogo, radius: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(compactCount(data?.total ?? 0), tr('reels_count')),
                    _Stat(compactCount(data?.totalViews ?? 0), tr('views')),
                    _Stat(compactCount(data?.totalLikes ?? 0), tr('likes')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Nice Store', style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 4),
              Icon(Icons.verified, color: AppColors.primary, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(tr('store_bio'), style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProfileButton(
                  icon: CupertinoIcons.share,
                  label: tr('share_store'),
                  filled: true,
                  onTap: () => Share.share('${tr('share_store_text')}\n${dotenv.env['STORE_APP_URL'] ?? ''}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileButton(
                  icon: CupertinoIcons.bookmark,
                  label: tr('saved_reels'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SavedReelsScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ProfileButton({required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? Colors.white : AppColors.textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : AppColors.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شريط التبويبات يبقى ثابتا عند التمرير
class _TabsDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.iconColor,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.borderColor.withOpacity(0.4),
        tabs: const [
          Tab(icon: Icon(CupertinoIcons.play_rectangle)),
          Tab(icon: Icon(CupertinoIcons.bookmark)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _AllReelsGrid extends StatelessWidget {
  final VideoState state;
  const _AllReelsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s is VideoLoading || s is VideoInitial) return const Center(child: CircularProgress());
    if (s is! VideoLoaded) {
      return Center(child: Text(tr('no_reels'), style: TextStyle(color: AppColors.textSecondary)));
    }

    // تحميل الدفعة التالية عند الاقتراب من النهاية
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) context.read<VideoCubit>().loadMore();
        return false;
      },
      child: LayoutBuilder(
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
            itemCount: s.videos.length,
            itemBuilder: (_, i) => ReelGridTile(
              video: s.videos[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ReelsPlayerScreen(videos: s.videos, initialIndex: i)),
              ),
            ),
          );
        },
      ),
    );
  }
}