import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/drop_card.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
// --- 1. الصفحة الرئيسية ---
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // تتبع العنصر المفتوح حالياً
  String? _activeTag;
  String? _activeAdd;

  void _toggleExpand(String tag , { String? tagAdd }) {
    setState(() {
      _activeTag = (_activeTag == tag ) ?  (_activeTag == "add_main" && tagAdd != null) ? "add_main" :null : tag;
      _activeAdd = (_activeAdd == tagAdd ) ?  null : tagAdd;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Icon( CupertinoIcons.list_bullet_below_rectangle,
            size: isDesktop ? 25 : 21, color: AppColors.iconColor),
        titleSpacing: 0,
        title: AppTitle(firstPart: tr('first orders'),secondPart: tr('second orders'),fontSize: isDesktop?18: 15,spacing: (context.locale.languageCode == 'ar') ? '' :' ',),
        actions: [
          ArrowBack(),
          SizedBox(width: 10,)
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,
              AppColors.gradientBottom,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(
            horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
            vertical:isDesktop ? 20 : 10,
          ),
          child: Column(
            children: [
              UnderlinedTitle(
                firstPart:(context.locale.languageCode == 'en') ? tr('Orders') : tr('list'),
                secondPart: (context.locale.languageCode == 'en') ? tr('list') : tr('Orders'),
                fontSize: isDesktop ? 22 : 18,
                isCenter: true,
              ),
              const SizedBox(height: 8),
              Text(
                "Follow your orders and find out about their condition".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color:  AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 30),
              DropCard(
                title: "000127378",
                subtitle: "The order is complete",
                icon: Icons.done,
                color: AppColors.primary,
                isSelected: _activeTag == "000127378",
                onTap: () => _toggleExpand("000127378"),
                expandedContent: _buildDefaultDetails([]),
              ),

              DropCard(
                title: "000127335",
                subtitle: "The order is on hold",
                icon: Icons.access_time_rounded,
                color:  Color(0xFFE16B38),
                isSelected: _activeTag == "000127335",
                onTap: () => _toggleExpand("000127335"),
                expandedContent: _buildDefaultDetails([]),
              ),
              DropCard(
                title: "000128888",
                subtitle: "The order has been canceled",
                icon: Icons.error_outline,
                color:  Color(0x93FB0404),
                isSelected: _activeTag == "000128888",
                onTap: () => _toggleExpand("000128888"),
                expandedContent: _buildDefaultDetails([]),
              ),
              DropCard(
                title: "0001272822",
                subtitle: "The order is ready",
                icon: Icons.timeline,
                color:  Color(0xFF38E1D3),
                isSelected: _activeTag == "0001272822",
                onTap: () => _toggleExpand("0001272822"),
                expandedContent: _buildDefaultDetails([]),
              ),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDefaultDetails(List<Map<String, String>> orderDetails) {
    return Column(
      children: [
        const SizedBox(height: 15),
        const Divider(thickness: 0.5),
        _detailRow("Order number:","00038767"),
        _detailRow("Amount:", "\$24.50"),
        _detailRow("Method:", "MasterCard Transfer"),
        _detailRow("Location:", "Yemen/Taiz"),
      ],
    );
  }

  Widget _detailRow(String textSecondary, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(textSecondary, style:  TextStyle(color: AppColors.textSecondary)), Text(text, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
}
