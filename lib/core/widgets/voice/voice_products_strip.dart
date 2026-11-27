import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../views/screens/product/products_screen.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_endpoints.dart';
import '../../utils/AiRippleManager.dart';
import '../../utils/local_notification_helper.dart';
import '../three_dots_loader.dart';

// شريط افقي لمنتجات رد المساعد الصوتي
class VoiceProductsStrip extends StatelessWidget {
  final List<dynamic> products;

  const VoiceProductsStrip({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index] as Map<String, dynamic>;
          return _VoiceProductCard(product: product);
        },
      ),
    );
  }
}

class _VoiceProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _VoiceProductCard({required this.product});

  // اغلاق المحادثة وفتح صفحة المنتج
  void _open() {
    final int? id = int.tryParse(product['p_id'].toString());
    if (id == null) return;

    AiRippleManager.closeRipple();
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProductScreens(
          productID: id,
          subCategoryID: null,
          categoryID: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEn = context.locale.languageCode == 'en';
    final String name = isEn
        ? (product['p_name_en']?.toString() ?? '')
        : (product['p_name']?.toString() ?? '');
    final String image = product['p_image']?.toString() ?? '';

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.ContainerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  ApiEndpoints.productImageUrl(image),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.backgroundSecondary,
                      child: const Center(child: ThreeDotsLoader()),
                    );
                  },
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/app icon/icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: isEn ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}