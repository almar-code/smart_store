import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/refresh_button.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../../logic/videos/video_cubit.dart';
import '../../../logic/videos/video_state.dart';
import '../../widgets/flash/flash_screen.dart';
import '../../widgets/reels/reels_feed.dart';
import 'store_profile.dart';

class ReelScreen extends StatelessWidget {
  final int pageIndex;
  const ReelScreen({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentPage) {
        final feed = _FeedArea(
          isActive: currentPage == pageIndex,
          bottomInset: isDesktop ? 12 : 80,
        );

        return Scaffold(
          backgroundColor: isDesktop ? AppColors.background : Colors.black,
          body: isDesktop
              ? SafeArea(
            child: Row(
              children: [
                // الريلز باطار جوال
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: ColoredBox(color: Colors.black, child: feed),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: AppColors.borderColor.withOpacity(0.4)),
                const Expanded(child: StoreProfile()),
              ],
            ),
          )
              : feed,
        );
      },
    );
  }
}

class _FeedArea extends StatelessWidget {
  final bool isActive;
  final double bottomInset;
  const _FeedArea({required this.isActive, required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoCubit, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading || state is VideoInitial) return const VideoLoadingShimmer();

        if (state is VideoLoaded) {
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.backgroundSecondary,
            onRefresh: () => context.read<VideoCubit>().getAllVideos(silent: true),
            child: ReelsFeed(
              key: ValueKey(state.version),
              videos: state.videos,
              isActive: isActive,
              isLoadingMore: state.isLoadingMore,
              onLoadMore: context.read<VideoCubit>().loadMore,
              bottomInset: bottomInset,
            ),
          );
        }

        final message = state is VideoError ? state.message : tr('no_reels');
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.film, color: Colors.white54, size: 46),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 15),
              SizedBox(
                height: 34,
                width: 130,
                child: RefreshButton(onPressed: () => context.read<VideoCubit>().getAllVideos()),
              ),
            ],
          ),
        );
      },
    );
  }
}