import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../widgets/reels/store_profile_image.dart';
class StoreProfile extends StatelessWidget {
  const StoreProfile({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: isDesktop ? null : AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing:10,
          leading: null,
          title:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Logo(),
              const SizedBox(width: 6),
              AppTitle(),
            ],
          ),
          actions: [
            ArrowBack()

          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [

                      /// صورة
                      StoreProfileImage(
                        imagePath: "assets/images/Gemini_Generated_Image_ez61caez61caez61.png",
                        radius: 30,
                      ),

                      const SizedBox(width: 20),

                      /// Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 15,
                          children: const [
                            _StatItem("12", "Posts"),
                            _StatItem("5.4K", "Followers"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                       Text(
                        "Nice Store",
                        style: TextStyle(color: AppColors.textColor),
                      ),
                      Text(
                        "Take care of the minute details",
                        style: TextStyle(color: AppColors.textSecondary,fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 10,
                    children: [
                      Expanded(child: _buildButton("Follow")),
                      Expanded(child: _buildButton("Messaging")),
                      Expanded(child: _buildButton("Share")),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                 TabBar(
                  labelColor:  AppColors.primary.withOpacity(0.4),
                   indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.video_library)),
                  ],
                ),

                /// 📸 Content
                Expanded(
                  child: TabBarView(
                    children: [
                      _ReelsGrid(),
                      _ReelsGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildButton(String text) {
    return Container(
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.textColor),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
              color: AppColors.textColor, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style:  TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ReelsGrid extends StatelessWidget {
  final List<String> reels = List.generate(
    9,
        (index) => "assets/images/${index}.jpg",
  );

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return MasonryGridView.count(
      padding: const EdgeInsets.all(2),
      crossAxisCount: isDesktop ? 7 : 3,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: reels.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [

              Image.network(
                reels[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              PositionedDirectional(
                bottom: 6,
                start: 6,
                child: Row(
                  children: [
                     Icon(
                      CupertinoIcons.eye_slash,
                      color: AppColors.iconColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${(index + 1) * 120}", // 👈 رقم وهمي
                      style:  TextStyle(
                        color: AppColors.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}