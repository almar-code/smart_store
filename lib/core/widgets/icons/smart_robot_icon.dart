import 'package:flutter/material.dart';

class AiRobotAvatar extends StatelessWidget {
  final double padding;      // التحكم في حجم المساحة الداخلية حول الأيقونة
  final double iconSize;     // التحكم في حجم أيقونة الروبوت
  final VoidCallback? onTap; // الحدث الذي يتم إطلاقه عند النقر (يمكن أن يكون null إذا كنت تريده للعرض فقط)

  const AiRobotAvatar({
    super.key,
    this.padding = 8.0,       // قيمة افتراضية في حال لم يتم تمريرها
    this.iconSize = 20.0,     // قيمة افتراضية
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // استخدمنا GestureDetector لالتقاط حدث النقر وتمريره للخارج
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF03C383), Color(0xFF25F5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}