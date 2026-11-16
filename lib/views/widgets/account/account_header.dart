import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/widgets/image_helper.dart';
import '../../../data/models/user_model.dart';

// رأس صفحة الحساب: الصورة بجانب الاسم والإيميل فوق الخلفية
class AccountHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAvatarTap;
  final bool isLoading;

  const AccountHeader({
    super.key,
    required this.user,
    required this.onAvatarTap,
    this.isLoading = false,
  });

  static const _brand = Color(0xFF03C383);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final hasImage = user.image.isNotEmpty;
    final radius = isDesktop ? 46.0 : 34.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
      child: SizedBox(
        height: isDesktop ? 200 : 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الخلفية، تنقلب في الإنجليزي
            Transform.flip(
              flipX: Directionality.of(context) == TextDirection.ltr,
              child: SvgPicture.asset(
                'assets/images/account_header_bg.svg',
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 18),
              child: Row(
                children: [
                  // الصورة مع زر الكاميرا
                  GestureDetector(
                    onTap: isLoading ? null : onAvatarTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .35),
                          ),
                          child: CircleAvatar(
                            radius: radius,
                            backgroundColor: Colors.white,
                            backgroundImage: hasImage
                                ? MemoryImage(ImageHelper.decodeBase64(user.image))
                                : null,
                            child: isLoading
                            // تحميل فوق الصورة وقت الحذف
                                ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: .35),
                              ),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ),
                            )
                                : hasImage
                                ? null
                                : Icon(Icons.person, size: radius, color: Colors.grey),
                          ),
                        ),
                        PositionedDirectional(
                          bottom: 0,
                          end: 0,
                          child: Container(
                            padding: EdgeInsets.all(isDesktop ? 7 : 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: .15), blurRadius: 6),
                              ],
                            ),
                            child: Icon(CupertinoIcons.camera_fill, size: isDesktop ? 16 : 13, color: _brand),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isDesktop ? 18 : 12),

                  // الاسم والإيميل
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 21 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.verified_rounded, color: Colors.white, size: isDesktop ? 20 : 16),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 8 : 5),
                        Row(
                          children: [
                            Icon(CupertinoIcons.mail,
                                color: Colors.white.withValues(alpha: .85), size: isDesktop ? 16 : 13),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // الإيميل دائما من اليسار لليمين
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .88),
                                  fontSize: isDesktop ? 14 : 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // مساحة فاضية فوق الشنطة
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}