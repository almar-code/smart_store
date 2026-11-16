import 'package:flutter/material.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../data/models/video_model.dart';
import '../../widgets/reels/reels_feed.dart';

class ReelsPlayerScreen extends StatelessWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const ReelsPlayerScreen({super.key, required this.videos, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final feed = ReelsFeed(videos: videos, initialIndex: initialIndex, bottomInset: 12);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // اطار جوال في الشاشات الكبيرة
            Positioned.fill(
              child: isWide
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(borderRadius: BorderRadius.circular(22), child: feed),
                  ),
                ),
              )
                  : feed,
            ),
            const PositionedDirectional(top: 10, end: 10, child: ArrowBack()),
          ],
        ),
      ),
    );
  }
}