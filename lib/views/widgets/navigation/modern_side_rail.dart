import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';

class ModernSideRail extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernSideRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernSideRail> createState() => _ModernSideRailState();
}

class _ModernSideRailState extends State<ModernSideRail> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) setState(() => isExpanded = true);
        });
      },
      onExit: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => isExpanded = false);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: isExpanded ? 230 : 70,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(right: BorderSide(color: AppColors.borderColor)),
          boxShadow: [
            if (isExpanded)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(5, 0),
              ),
          ],
        ),
        child: ClipRect(
          // 🔥 يمنع أي Overflow
          child: Column(
            children: [
              const SizedBox(height: 10),

              _buildLogo(),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      0,
                      Icons.play_circle_outline,
                      Icons.play_circle,
                      "Reels",
                      size: 20,
                    ),
                    _buildMenuItem(
                      1,
                      Icons.auto_awesome_outlined,
                      Icons.auto_awesome,
                      "New",
                      size: 21,
                    ),
                    _buildMenuItem(2, Icons.home_outlined, Icons.home, "Home"),
                    _buildMenuItem(
                      3,
                      CupertinoIcons.cart,
                      CupertinoIcons.cart_fill,
                      "Cart",
                      size: 19,
                    ),
                    _buildMenuItem(
                      4,
                      Icons.person_outline,
                      Icons.person,
                      "Omar",
                    ),
                    _buildMenuItem(
                      5,
                      Icons.favorite_outline,
                      Icons.favorite,
                      "Favorite",
                      size: 20,
                    ),
                  ],
                ),
              ),

              _buildBottomSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: [
          // 🔥 اللوجو
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),

          const SizedBox(width: 3),

          // 🔥 النص يظهر فقط عند التوسع
          if (isExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Nice abayas",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    double size = 22,
  }) {
    final bool isSelected = widget.currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max, // 🔥 مهم
            children: [
              SizedBox(
                width: 48,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: size,
                  color: isSelected ? AppColors.primary : AppColors.textColor,
                ),
              ),

              if (isExpanded)
                Flexible(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isExpanded ? 1 : 0,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // 🔥 حل نهائي
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textColor,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            direction: isExpanded ? Axis.horizontal : Axis.vertical,
            // spacing: 12,
            children: [
              SocialIcon(
                icon: FontAwesomeIcons.whatsapp,

                color: Color(0xFF25D366),
              ),
              Icon(FontAwesomeIcons.instagram, color: Colors.transparent),
              SocialIcon(
                icon: FontAwesomeIcons.instagram,

                color: Color(0xFFE1306C),
              ),
              Icon(FontAwesomeIcons.instagram, color: Colors.transparent),
              SocialIcon(
                icon: FontAwesomeIcons.facebook,

                color: Color(0xFF1877F2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
