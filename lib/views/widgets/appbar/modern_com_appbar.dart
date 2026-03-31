import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_icons.dart';
import 'constant/app_search.dart';
import 'constant/app_title.dart';

class SearchAppbar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex; // نمرر رقم الصفحة الحالية
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;

  const SearchAppbar({
    super.key,
    required this.currentIndex, // مطلوب دائماً
    this.onSearchTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
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
                child: Center(
                  child: DynamicAppTitle(currentIndex:currentIndex),
                ),
              ),
              Expanded(flex: 5, child: SizedBox()),
              if(currentIndex ==2)
              Expanded(
                flex: 2,
                child: Center(
                  child:Expanded(
                    flex: 2,
                    child: Center(
                      child: CustomSearchBar(widthFactor: 0.3), // عرض مخصص للابتوب
                    ),
                  ),
                )
              ),
              if(currentIndex ==3)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Expanded(
                    child: CartBadge(count: "3"),
                ),
              ),
              SizedBox(width: 10,),
              if(currentIndex ==2)
                Expanded(
                  child: Row(
                    children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.bell,
                              color: Colors.black,
                              size: 20, // تحكم بحجم الأيقونة هنا
                            ),
                            onPressed: onSearchTap,
                          ),
                        ),
                      SizedBox(width: 10,),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.mail,
                              color: Colors.black,
                              size: 20, // تحكم بحجم الأيقونة هنا
                            ),
                            onPressed: onSearchTap,
                          ),
                        ),
                      SizedBox(width: 10,),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset('assets/images/user.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.fill,),
                        ),
                    ],
                  ),
                ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
