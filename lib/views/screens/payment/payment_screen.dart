import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/views/screens/payment/payment_success_screen.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/cancel_button.dart';
import '../../../core/widgets/drop_card.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../widgets/payment/add_payment.dart';
// --- 1. الصفحة الرئيسية ---
class SelectPaymentMethodPage extends StatefulWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  State<SelectPaymentMethodPage> createState() => _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
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
        leading: Icon( Icons.credit_card,
            size: isDesktop ? 25 : 21, color: AppColors.iconColor),
        titleSpacing: 0,
        title: AppTitle(
          firstPart: tr('Select'),
          secondPart: tr('Method'),
          fontSize: isDesktop ? 18 : 15,
          spacing: ' ',
        ),
        actions: [
          ArrowBack(),
          SizedBox(width: 10,)
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          // التدرج اللوني من الأعلى للأسفل كما في الصورة
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientTop,    // سيأخذ 0xFF1C1C1E في الليل و 0xFFFFFFFF في النهار
              AppColors.gradientBottom, // سيأخذ 0xFF000000 في الليل و 0xFFE8EAF0 في النهار
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
                firstPart: tr('Select'),
                secondPart: tr('Method'),
                fontSize: isDesktop ? 22 : 18,
                isCenter: true,
              ),
              const SizedBox(height: 8),
              Text(
                "Select method you prefer to withdraw\nfunds from World App",
                textAlign: TextAlign.center,
                style: TextStyle(color:  AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 30),
               Align(
                alignment:(context.locale.languageCode == 'en') ? Alignment.centerLeft : Alignment.centerRight,
                child: Text("Payment Methods", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),

              // 1. بكس الكاش (لا ينفتح)
              DropCard(
                title: "Cash",
                subtitle: "Cash on Delivery",
                icon: Icons.money,
                color: AppColors.primary,
                isSelected: _activeTag == "cash",
                onTap: () => setState(() => _activeTag = "cash"),
                isExpandable: false, // العنصر الوحيد الذي لا ينسدل
              ),

              // 2. بكس Mastercard
              DropCard(
                title: "Mastercard",
                subtitle: "************7789 • 04/28",
                icon: Icons.credit_card,
                color: const Color(0xFFFF5F00),
                isSelected: _activeTag == "master",
                onTap: () => _toggleExpand("master"),
                expandedContent: _buildDefaultDetails("Mastercard",color: Color(0xFFFF5F00)),
              ),

              // 3. بكس Visa
              DropCard(
                title: "Visa",
                subtitle: "************4421 • 06/29",
                icon: Icons.account_balance_wallet,
                color: const Color(0xFF1A1F71),
                isSelected: _activeTag == "visa",
                onTap: () => _toggleExpand("visa"),
                expandedContent: _buildDefaultDetails("Visa",color: Color(0xFF1A1F71) ),
              ),

              // 4. بكس Add Method الرئيسي
              DropCard(
                title: "Add Method",
                subtitle: "Add a new payment method",
                icon: Icons.add,
                color: AppColors.iconColor,
                isSelected: _activeTag == "add_main",
                onTap: () => _toggleExpand("add_main"),
                expandedContent: Column(
                  children: [
                    const SizedBox(height: 10),
                    // البكسات الداخلية (أصغر قليلاً وتنسدل أيضاً)
                    DropCard(
                      title: "Card",
                      subtitle: "Variable fees • Takes minutes",
                      icon: Icons.credit_card,
                      color: AppColors.primary,
                      isSelected: _activeAdd == "add_card",
                      onTap: () => _toggleExpand("add_main",tagAdd: "add_card"),
                      isSmall: true, // تصغير الحجم
                      expandedContent: AddCardForm(onCancel: () => setState(() => _activeTag = null)),
                    ),
                    DropCard(
                      title: "Bank Transfer",
                      subtitle: "Variable fees • Up to 2 days",
                      icon: Icons.account_balance,
                      color: const Color(0xFF5C2FCF),
                      isSelected: _activeAdd == "add_bank",
                      onTap: () => _toggleExpand("add_main" ,tagAdd: "add_bank"),
                      isSmall: true,
                      expandedContent: AddBankForm(onCancel: () => setState(() => _activeTag = null)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDefaultDetails(String provider ,{ Color color = Colors.black}) {
    return Column(
      children: [
        const SizedBox(height: 15),
        const Divider(thickness: 0.5),
        _detailRow("Amount:", "\$24.50"),
        _detailRow("Method:", "$provider Transfer"),
        _detailRow("Location:", "Yemen/Taiz"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: SizedBox(
              height: 45,
                child: AppButton(label: "Pay", color: color,borderRadius: 17,icon: Icons.payments_rounded,onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => PaymentSuccessPage())),))),
            const SizedBox(width: 10),
            Expanded(child: CancelButton(onPressed: () => setState(() => _activeTag = null))),
          ],
        )
      ],
    );
  }

  Widget _detailRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style:  TextStyle(color: AppColors.textSecondary)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
}
