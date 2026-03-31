import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_icons.dart';
import 'constant/app_search.dart';
import 'constant/app_title.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex; // نمرر رقم الصفحة الحالية
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;

  const ModernAppBar({
    super.key,
    required this.currentIndex, // مطلوب دائماً
    this.onSearchTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              // --- القسم الأيمن (قائمة وبحث) ---
                Expanded(
                child: Row(
                  children: [
                    if(currentIndex ==2)
                      IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    if(currentIndex ==3)
                      CartBadge(count: "3",onTap: onCartTap,),
                    if(currentIndex ==1)
                      IconButton(
                        icon: const Icon(CupertinoIcons.search, color: Colors.black),
                        onPressed: onSearchTap,
                      ),
                  ],
                ),
              ),
              if(currentIndex ==2)
              Expanded(
                  flex: 3,
                  child: Center(
                    child:Expanded(
                      flex: 2,
                      child: Center(
                        child: CustomSearchBar(widthFactor: 0.8), // عرض مخصص للابتوب
                      ),
                    ),
                  )
              ),
              SizedBox(width: 20,),
              Expanded(
                flex: 0,
                child: Row(
                  children: [
                    Center(
                      child: DynamicAppTitle(currentIndex: currentIndex),
                    ),
                    SizedBox(width: 8),
                    Image.asset(
                      'lib/core/widgets/logo/logo.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 5);
}