import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_store/core/widgets/app_button.dart';
import 'package:video_player/video_player.dart';

// استيراد الملفات الخاصة بك (تأكد من صحة المسارات)
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/refresh_button.dart';
import '../../../data/local/shared preferences/local_storage_service.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../../logic/videos/comments_cubit.dart';
import '../../../logic/videos/video_cubit.dart Dart.dart';
import '../../../logic/videos/video_state.dart'; // الحالات الجديدة
import '../../../data/models/video_model.dart'; // الموديل الجديد
import '../../widgets/flash/flash_screen.dart';
import '../product/product_details_screen.dart';
import 'store_profile.dart';

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
          appBar: isDesktop
              ? AppBar(
            backgroundColor: AppColors.background,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleImage(
                  imagePath: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
                  radius: 20,
                ),
                const SizedBox(width: 6),
                AppTitle(fontSize: 22),
              ],
            ),
          )
              : null,
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<VideoCubit>().getAllVideos();
            },
            color: AppColors.primary, // لون مؤشر التحميل (يمكنك ربطه بهوية المشروع)
            backgroundColor: AppColors.backgroundSecondary,
            child: isDesktop
                ? Row(
              children: [
                SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Reels(isPageActive: isActivePage),
                  ),
                ),
                const Expanded(child: StoreProfile()),
              ],
            )
                : Reels(isPageActive: isActivePage),
          ),
        );
      },
    );
  }
}

class Reels extends StatefulWidget {
  final bool isPageActive;

  const Reels({super.key, required this.isPageActive});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  PageController controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // استدعاء البيانات من الـ Cubit
    return BlocBuilder<VideoCubit, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading) {
          return const Center(child: CircularProgress());
        } else if (state is VideoLoaded) {
          return PageView.builder(
            controller: controller,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: state.videos.length,
            itemBuilder: (context, index) {
              return ReelItem(
                videoModel: state.videos[index], // تمرير الموديل بدلاً من Map
                isActive: index == currentIndex,
                isScreenActive: widget.isPageActive,
              );
            },
          );
        } else if (state is VideoEmpty) {
          return const Center(child: Text("لا توجد فيديوهات حالياً", style: TextStyle(color: Colors.white)));
        } else if (state is VideoError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15,
              children: [
                Text(state.message, style: TextStyle(color: Colors.white)),
                SizedBox(
                    height: 30,
                    width: 120,
                  child: RefreshButton(onPressed: () async {
                    await context.read<VideoCubit>().getAllVideos();
                  },)
                )
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ReelItem extends StatefulWidget {
  final VideoModel videoModel; // تحديث النوع
  final bool isActive;
  final bool isScreenActive;

  const ReelItem({
    super.key,
    required this.videoModel,
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

    loadSavedState();

    videoController =
    VideoPlayerController.networkUrl(
      Uri.parse(widget.videoModel.videoUrl),
    )
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          videoController.setLooping(true);

          if (widget.isActive &&
              widget.isScreenActive) {
            videoController.play();
          }
        }
      });
  }
  Future<void> loadSavedState() async {

    final isSaved =
    await LocalStorageService.isVideoSaved(
      widget.videoModel.videoId,
    );

    if(mounted){

      setState(() {

        widget.videoModel.isSaved = isSaved;

      });
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!videoController.value.isInitialized) return;

    if (widget.isActive && widget.isScreenActive) {
      videoController.play();
    } else {
      videoController.pause();
      videoController.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (!videoController.value.isInitialized) return;
    videoController.value.isPlaying ? videoController.pause() : videoController.play();
    setState(() {});
  }
  void stopPlay() {
    if (!videoController.value.isInitialized) return;
    videoController.pause();
    setState(() {}); // لتحديث واجهة المستخدم وإظهار زر التشغيل إذا عدت للخلف
  }
  void forward() {
    final pos = videoController.value.position;
    videoController.seekTo(pos + const Duration(seconds: 5));
  }
  void rewind() {
    final pos = videoController.value.position;
    videoController.seekTo(pos - const Duration(seconds: 5));
  }
  void speedUp(bool fast) => videoController.setPlaybackSpeed(fast ? 2.0 : 1.0);
  void _showBigHeart(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 250.0),
          child: AnimatedScale(
            scale: 4,
            duration:  Duration(seconds: 1),
            curve: Curves.bounceIn,
            child: Icon(
              CupertinoIcons.heart_fill,
              color: Colors.red,
              size: 25,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // إزالة القلب بعد 500 مللي ثانية
    Future.delayed( Duration(seconds: 1), () {
      overlayEntry.remove();
    });
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
        if(details.localPosition.dx > 80 && details.localPosition.dx < width-80){
        setState(() {
          _showBigHeart(context);
        // تحديث الواجهة فوراً لتجربة مستخدم سريعة (UI Feedback)
        if (!widget.videoModel.isLiked){
          widget.videoModel.isLiked = !widget.videoModel.isLiked;
          widget.videoModel.likesCount++;
          context.read<VideoCubit>().toggleLikeOnServer(
              widget.videoModel.videoId,
              widget.videoModel.isLiked // نمرر الحالة الحالية بعد التعديل ليعرف السيرفر هل يزود أم ينقص
          );
        }
        });
        // إرسال الطلب للسيرفر في الخلفية

        } else if (details.localPosition.dx > width-80) {
          forward();
        } else if(details.localPosition.dx < 80){
          rewind();
        }
      },
      child: Stack(
        children: [
          /// الفيديو
          SizedBox.expand(
            child: videoController.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: IgnorePointer(child: VideoPlayer(videoController)),
              ),
            )
                : const VideoLoadingShimmer(),
          ),

          /// أيقونة التشغيل الوسطى
          if (!videoController.value.isPlaying && videoController.value.isInitialized)
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.play_arrow_solid, color: Colors.white, size: 35),
              ),
            ),

          /// التفاعل (لايك، كومنت، الخ)
          /// التفاعل الحقيقي (لايك، حفظ، مشاركة)
          PositionedDirectional(
            end: 10,
            top: 300,
            child: Column(
              spacing: 25,
              children: [
                // 1. زر الإعجاب (Like)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      // تحديث الواجهة فوراً لتجربة مستخدم سريعة (UI Feedback)
                      widget.videoModel.isLiked = !widget.videoModel.isLiked;
                      widget.videoModel.isLiked
                          ? widget.videoModel.likesCount++
                          : widget.videoModel.likesCount--;
                    });
                    // إرسال الطلب للسيرفر في الخلفية
                    context.read<VideoCubit>().toggleLikeOnServer(
                        widget.videoModel.videoId,
                        widget.videoModel.isLiked // نمرر الحالة الحالية بعد التعديل ليعرف السيرفر هل يزود أم ينقص
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        widget.videoModel.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: widget.videoModel.isLiked ? Colors.red : Colors.white,
                        size: 29,
                      ),
                      const SizedBox(height: 4),
                      Text(widget.videoModel.likesCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),

                // 2. زر التعليقات (سنتركه كأيقونة حالياً وجاهز للربط لاحقاً)
                GestureDetector(
                  onTap: () {
                    showCommentsBottomSheet(context,  widget.videoModel,);
                  },
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.conversation_bubble,
                        color: Colors.white,
                        size: 29,
                      ),
                      const SizedBox(height: 4),
                      // يمكنك لاحقاً تمرير عداد التعليقات الإجمالي من الـ videoModel هنا
                      Text(
                        widget.videoModel.commentsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. زر الحفظ (Save)
                GestureDetector(
                  onTap: () async {

                    final isSaved =
                    await LocalStorageService.toggleSaveVideo(
                      widget.videoModel.videoId,
                    );

                    setState(() {

                      widget.videoModel.isSaved = isSaved;

                      if(isSaved){
                        widget.videoModel.savesCount++;
                      }else{
                        widget.videoModel.savesCount--;
                      }

                    });

                  },
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/bookmark-simple.svg",
                        width: 28,
                        colorFilter: ColorFilter.mode(
                          widget.videoModel.isSaved
                              ? Colors.green
                              : Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.videoModel.savesCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),

                // 4. زر المشاركة (Share)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.videoModel.sharesCount++;
                    });
                    // فتح نافذة المشاركة الخاصة بنظام الهاتف
                    // Share.share('شاهد هذا الفيديو: ${widget.videoModel.videoUrl}');

                    context.read<VideoCubit>().incrementShareOnServer(widget.videoModel.videoId);
                  },
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/images/paper-plane-tilt.svg",
                        width: 28,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.videoModel.sharesCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// معلومات المتجر والمنتج
          PositionedDirectional(
            start: 15,
            bottom: isDesktop ? 10 : 87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.videoModel.productId != null)
                  GestureDetector(
                    onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => ProductDetailsScreen(productID: widget.videoModel.productId,))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text("عرض المنتج", style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                const SizedBox(height: 10),
                InkWell(
                  onTap:(){
                    stopPlay();
                    Navigator.of(context,).push(MaterialPageRoute(builder: (context) => StoreProfile(isAppBar: true,)));
                  },
                  child: Row(
                    children:  [
                      CircleImage(
                        imagePath: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
                        radius: 20,
                      ),
                      SizedBox(width: 7),
                      Text(
                        "Nice Store",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 29),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildSvgButton(String path, String label) {
    return Column(
      children: [
        SvgPicture.asset(path, width: 28, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

}
void showCommentsBottomSheet(
    BuildContext context,
    VideoModel video,
    ) {

  final commentsCubit =
  BlocProvider.of<CommentsCubit>(context);

  // تحميل تعليقات الفيديو الحالي
  commentsCubit.loadComments(video.videoId);

  showModalBottomSheet(

    context: context,

    isScrollControlled: true,

    backgroundColor: AppColors.background,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),

    builder: (sheetContext) {

      final TextEditingController
      commentController =
      TextEditingController();

      return SafeArea(

        child: BlocProvider.value(

          value: commentsCubit,

          child: Padding(

            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext)
                  .viewInsets
                  .bottom,
            ),

            child: Container(

              height:
              MediaQuery.of(sheetContext)
                  .size
                  .height *
                  0.65,

              padding:
              const EdgeInsets.all(16.0),

              child: Column(

                children: [

                  // الخط العلوي
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                      AppColors
                          .backgroundSecondary,
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "التعليقات",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      AppColors.textColor,
                    ),
                  ),

                  const Divider(),

                  // قائمة التعليقات
                  Expanded(

                    child:
                    BlocBuilder<
                        CommentsCubit,
                        CommentsState>(
                      builder:
                          (blocContext, state) {

                        // تحميل
                        if (state
                        is CommentsLoading) {

                          return const Center(
                            child:
                            CircularProgress(),
                          );
                        }

                        // نجاح
                        else if (state
                        is CommentsLoaded) {

                          if (state
                              .comments
                              .isEmpty) {

                            return Center(
                              child: Text(
                                "لا توجد تعليقات بعد",
                                style: TextStyle(
                                  color:
                                  AppColors
                                      .textSecondary,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(

                            itemCount:
                            state.comments.length,

                            itemBuilder:
                                (context, index) {

                              final comment =
                              state.comments[index];

                              return ListTile(

                                leading:
                                CircleAvatar(

                                  backgroundColor:
                                  Colors.grey[200],

                                  backgroundImage:
                                  comment.customerImage !=
                                      null
                                      ? NetworkImage(
                                    comment.customerImage!,
                                  )
                                      : const AssetImage(
                                    'assets/images/image_placeholder.png',
                                  )
                                  as ImageProvider,
                                ),

                                title: Text(

                                  comment.customerName ,

                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 13,
                                    color:
                                    AppColors.textColor,
                                  ),
                                ),

                                subtitle: Text(

                                  comment.commentText,

                                  style: TextStyle(
                                    color:
                                    AppColors
                                        .textColor,
                                    fontSize: 13,
                                  ),
                                ),

                                // مؤشر الإرسال
                                trailing:
                                comment.isSending
                                    ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child:
                                  CircularProgress()
                                )
                                    : null,
                              );
                            },
                          );
                        }

                        // خطأ
                        else if (state
                        is CommentsError) {

                          return Center(
                            child:
                            Text(state.message),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),

                  const Divider(),

                  // حقل الكتابة
                  Row(

                    children: [

                      Expanded(

                        child: TextField(

                          controller:
                          commentController,

                          style: TextStyle(
                            color:
                            AppColors.textColor,
                          ),

                          decoration: InputDecoration(

                            hintText:
                            "أضف تعليقاً...",

                            hintStyle: TextStyle(
                              color:
                              AppColors
                                  .textSecondary,
                              fontSize: 14,
                            ),

                            border:
                            InputBorder.none,
                          ),
                        ),
                      ),

                      IconButton(

                        icon: Icon(
                          Icons.send,
                          color:
                          AppColors.primary,
                        ),

                        onPressed: () {

                          final commentText =
                          commentController.text
                              .trim();

                          if (commentText
                              .isNotEmpty) {

                            // إرسال التعليق
                            commentsCubit.sendComment(

                              video,

                              1,

                              commentText,
                            );

                            // تنظيف الحقل
                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}