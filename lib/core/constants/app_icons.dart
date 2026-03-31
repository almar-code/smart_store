import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';

class SocialIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const SocialIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size=18,
  });

  @override
  State<SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<SocialIcon> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          widget.icon,
          color: isHovering ? widget.color : Colors.grey,
          size: widget.size,
        ),
      ),
    );
  }
}

class CartBadge extends StatelessWidget {
  final String count; // عدد المنتجات (مثلاً "3")
  final VoidCallback? onTap; // ماذا يحدث عند الضغط

  const CartBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        SizedBox(
          width: 35,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 4,
            ),
            child: GestureDetector(
              onTap: onTap, // ربط الضغطة هنا
              child: const Icon(CupertinoIcons.cart, size: 21),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Positioned(
          bottom: 23,
          child: Text(
            count, // القيمة المتغيرة
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}