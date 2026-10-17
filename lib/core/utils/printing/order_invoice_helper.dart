import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:smart_store/core/widgets/circularProgress.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/printing_service.dart';
import '../../widgets/app_messages.dart';

class OrderInvoiceHelper {
  static Future<void> printOrderInvoice(BuildContext context, OrderModel order) async {
    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgress()),
    );

    try {
      final pdfBytes = await PrintingService.fetchOrderInvoicePdf(order.orderId,context.locale.languageCode);

      // إغلاق مؤشر التحميل
      if (context.mounted) Navigator.pop(context);

      if (pdfBytes != null) {
        // طباعة أو معاينة ملف الـ PDF
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'Order_Invoice_${order.orderId}',
        );
      } else {
        if (context.mounted) {
          AppToasts.showErrorToast(context, 'Failed to load invoice'.tr());
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppToasts.showErrorToast(context, 'An error occurred while connecting'.tr());
      }
    }
  }
}