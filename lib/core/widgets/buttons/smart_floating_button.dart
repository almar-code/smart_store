import 'package:flutter/material.dart';
import 'dart:async';
import '../../../views/screens/smart chat screen/smart_chat_screen.dart';
import '../../utils/AiRippleManager.dart';

class SmartFloatingButton extends StatefulWidget {
  const SmartFloatingButton({super.key});

  @override
  State<SmartFloatingButton> createState() => _SmartFloatingButtonState();
}

class _SmartFloatingButtonState extends State<SmartFloatingButton> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    // إغلاق تمدد الزر بعد 3 ثوانٍ تلقائياً
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // إغلاق التموج تلقائياً إذا تم تدمير الزر لمنع تعليق الـ Overlay
    AiRippleManager.closeRipple();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SmartChatScreen()),
      ),
      // استدعاء الكلاس المنعزل وتمرير الـ context
      onTap: () => AiRippleManager.toggleRipple(
        context,
        onStateChanged: () => setState(() {}), // لتحديث حالة الزر البصرية إن لزم الأمر
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        height: 47,
        width: _isExpanded ? 180 : 47,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: _isExpanded ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
          children: [
            if (_isExpanded)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Call me Almar",
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}