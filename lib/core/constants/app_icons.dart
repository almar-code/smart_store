import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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