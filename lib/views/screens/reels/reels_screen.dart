import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/bloc/theme_bloc.dart' show ThemeBloc;
import '../../../core/theme/bloc/theme_state.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../widgets/flash/flash_screen.dart';
class ReelScreen extends StatelessWidget {
  final int pageIndex;

  const ReelScreen({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentPage) {
        bool isActivePage = currentPage == pageIndex;
        bool isDesktop = MediaQuery.of(context).size.width > 800;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: isDesktop
              ? Row(
            children: [
              SizedBox(
                width: 412,
                child: Reels(isPageActive: isActivePage),
              ),
              const Expanded(child: SizedBox()),
            ],
          )
              : Reels(isPageActive: isActivePage),
        );
      },
    );
  }
}

class Reels extends StatefulWidget {
  final bool isPageActive; // 👈 جديد

  const Reels({super.key, required this.isPageActive});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final List<Map<String, dynamic>> reels = [
    {
      "id": 1,
      "videoUrl": "assets/videos/videos1.mp4",
      "productId": 10,
    },
    {
      "id": 2,
      "videoUrl": "assets/videos/videos2.mp4",
      "productId": null,
    },
    {
      "id": 3,
      "videoUrl": "assets/videos/videos3.mp4",
      "productId": 22,
    },
  ];

  PageController controller = PageController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      itemCount: reels.length,
      itemBuilder: (context, index) {
        return ReelItem(
          reel: reels[index],
          isActive: index == currentIndex,
          isScreenActive: widget.isPageActive, // 👈 المهم
        );
      },
    );
  }
}

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> reel;
  final bool isActive;
  final bool isScreenActive;

  const ReelItem({
    super.key,
    required this.reel,
    required this.isActive,
    required this.isScreenActive,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();

    videoController =
    VideoPlayerController.asset(widget.reel["videoUrl"])
      ..initialize().then((_) {
        setState(() {});
        videoController.setLooping(true);

        if (widget.isActive && widget.isScreenActive) {
          videoController.play();
        }
      });
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!videoController.value.isInitialized) return;

    if (widget.isActive && widget.isScreenActive) {
      videoController.play();
    } else {
      videoController.pause();
      videoController.seekTo(Duration.zero); // 👈 مهم
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (!videoController.value.isInitialized) return;

    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }

    setState(() {});
  }

  void forward() {
    final pos = videoController.value.position;
    videoController.seekTo(pos + const Duration(seconds: 5));
  }

  void rewind() {
    final pos = videoController.value.position;
    videoController.seekTo(pos - const Duration(seconds: 5));
  }

  void speedUp(bool fast) {
    videoController.setPlaybackSpeed(fast ? 2.0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: togglePlay,

      onLongPressStart: (_) => speedUp(true),
      onLongPressEnd: (_) => speedUp(false),

      onDoubleTapDown: (details) {
        final width = MediaQuery.of(context).size.width;

        if (details.localPosition.dx > width / 2) {
          forward();
        } else {
          rewind();
        }
      },

      child: Stack(
        children: [
          /// 🎬 الفيديو
          SizedBox.expand(
            child: videoController.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: IgnorePointer(
                  child: VideoPlayer(videoController),
                ),
              ),
            )
            : const VideoLoadingShimmer(),
          ),

          /// ▶️ أيقونة التشغيل
          if (!videoController.value.isPlaying)
            Center(
              child: Container(
                padding: EdgeInsets.only(left: 5),
                width:  50,
                height:  50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.play_arrow_solid,
                  color: Colors.white,
                  size:  35,
                ),
              ),
            ),

          PositionedDirectional(
            end: 10,
            top: 300,
            child: Column(
              spacing: 25,
                children: [

                  Column(
                    children: const [
                      Icon(CupertinoIcons.heart, color: Colors.white, size: 29),
                      SizedBox(height: 4),
                      Text(
                        "1.2K",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),


                  Column(
                    children: const [
                      Icon(CupertinoIcons.conversation_bubble,
                          color: Colors.white, size: 28),
                      SizedBox(height: 4),
                      Text(
                        "320",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/bookmark-simple.svg",
                        width: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "89",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),


                  Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/paper-plane-tilt.svg",
                        width: 28,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "12",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],

            ),
          ),

          /// 👤 معلومات + المنتج
          PositionedDirectional(
            start: 10,
            bottom: 87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.reel["productId"] != null)
                  GestureDetector(
                    onTap: () {
                      print("Go to product ${widget.reel["productId"]}");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        "عرض المنتج",

                        style: TextStyle(color: Colors.white,fontSize: 10),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                Row(
                  children: const [
                    CircleAvatar(
                      backgroundImage:
                      NetworkImage("assets/images/Gemini_Generated_Image_ez61caez61caez61.png"),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Nice Store",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}