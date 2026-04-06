import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/navigation/navigation_cubit.dart';
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

class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.black,size: 20,),
      onPressed: () {
        // استدعاء دالة فتح الدراور من الكوبيت مباشرة
        context.read<NavigationCubit>().openDrawer();
      },
    );
  }
}