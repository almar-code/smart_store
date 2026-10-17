import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/printing/order_invoice_helper.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/drop_card.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import '../../../data/models/order_model.dart';
import '../../../logic/orders/order_cubit.dart';
import '../../../logic/orders/order_state.dart';
import '../../widgets/flash/flash_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _activeTag;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchOrders(1);//رقم العميل
  }

  void _toggleExpand(String tag) {
    setState(() {
      _activeTag = (_activeTag == tag) ? null : tag;
    });
  }

  // تحديد اللون والأيقونة بناءً على الحالات السبع المطلوبة
  Map<String, dynamic> _getOrderStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'color': const Color(0xFFE16B38), 'icon': Icons.access_time_rounded, 'label': tr('status_pending')};
      case 'processing':
        return {'color': Colors.blue, 'icon': Icons.sync, 'label': tr('status_processing')};
      case 'ready':
        return {'color': const Color(0xFF38E1D3), 'icon': Icons.timeline, 'label': tr('status_ready')};
      case 'shipped':
        return {'color': Colors.indigo, 'icon': Icons.local_shipping_outlined, 'label': tr('status_shipped')};
      case 'completed':
        return {'color': AppColors.primary, 'icon': Icons.done, 'label': tr('status_completed')};
      case 'cancelled':
        return {'color': const Color(0x93FB0404), 'icon': Icons.error_outline, 'label': tr('status_cancelled')};
      case 'refunded':
        return {'color': Colors.purple, 'icon': Icons.assignment_return, 'label': tr('status_refunded')};
      default:
        return {'color': Colors.grey, 'icon': Icons.help_outline, 'label': status};
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: Icon(CupertinoIcons.list_bullet_below_rectangle,
              size: isDesktop ? 25 : 21, color: AppColors.iconColor),
          titleSpacing: 0,
          title: AppTitle(
            firstPart: tr('first orders'),
            secondPart: tr('second orders'),
            fontSize: isDesktop ? 18 : 15,
            spacing: (context.locale.languageCode == 'ar') ? '' : ' ',
          ),
          actions: [
            ArrowBack(),
            SizedBox(width: 10),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
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
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
              vertical: isDesktop ? 20 : 10,
            ),
            child: Column(
              children: [
                UnderlinedTitle(
                  firstPart: (context.locale.languageCode == 'en') ? tr('Orders') : tr('list'),
                  secondPart: (context.locale.languageCode == 'en') ? tr('list') : tr('Orders'),
                  fontSize: isDesktop ? 22 : 18,
                  isCenter: true,
                ),
                const SizedBox(height: 8),
                Text(
                  tr("orders_subtitle"),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 30),
                BlocBuilder<OrderCubit, OrderState>(
                  builder: (context, state) {
                    if (state is OrderLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: AddressShimmer(),
                      );
                    } else if (state is OrderLoaded) {
                      if (state.orders.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(tr('no_orders_found'), style: TextStyle(color: AppColors.textSecondary)),
                        );
                      }
                      return Column(
                        children: state.orders.map((order) {
                          final config = _getOrderStatusConfig(order.status);
                          final tag = order.orderId.toString();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: DropCard(
                              title: "${order.orderId}",
                              subtitle: config['label'],
                              icon: config['icon'],
                              color: config['color'],
                              isSelected: _activeTag == tag,
                              onTap: () => _toggleExpand(tag),
                              expandedContent: _buildDefaultDetails(order, isDesktop,color: config['color'] ),
                            ),
                          );
                        }).toList(),
                      );
                    } else if (state is OrderError) {
                      return Text(state.message, style: const TextStyle(color: Colors.red));
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultDetails(OrderModel order, bool isDesktop,{Color color = Colors.transparent}) {
    bool isCancelled = order.status.toLowerCase() == 'cancelled';
    final String addressText = [
      order.address?.country,
      order.address?.city,
      order.address?.street,
      order.address?.title,
    ].where((element) => element != null && element.isNotEmpty).join('، ');
    Widget cancelButton = AppButton(
      label: tr("cancel_order"),
      color: Colors.transparent,
      textColor: AppColors.textColor,
      borderRadius: 17,
      icon: Icons.cancel_outlined,
      onTap: () async {
        final confirm = await AppToasts.showConfirmDialog(
          context: context,
          title: tr('confirm_delete_title'),
          message: tr('confirm_delete_order_msg'),
        );

        if (confirm == true && context.mounted) {
          context.read<OrderCubit>().cancelOrder(order.orderId, 1);//رقم العميل
        }
      },
      borderColor: AppColors.borderSecondary,
    );

    Widget printButton = AppButton(
      label: tr("print_order"),
      color: color,
      textColor: Colors.white,
      borderRadius: 17,
      icon: Icons.print_outlined,
      onTap: () {
        OrderInvoiceHelper.printOrderInvoice(context,order);
        },
      borderColor: AppColors.borderSecondary,
    );

    return Column(
      children: [
        const SizedBox(height: 5),
        const Divider(thickness: 0.5),
        _detailRow(tr("order_number"), "${order.orderId}"),
        _detailRow(tr("amount"), "\$${order.totalPrice.toStringAsFixed(2)}"),
        _detailRow(tr("payment_status"), tr(order.paymentStatus)),
        _detailRow(tr("date"),DateHelper.formatDateTime( order.createdAt)),
        _detailRow(tr("location"),
          order.address != null ? addressText : tr("no_address"),),
        const Divider(thickness: 0.5),
        const SizedBox(height: 5),

        // التحكم بمكان زر الطباعة وزر الإلغاء حسب الشاشة (كمبيوتر أو جوال)
        if (isDesktop) ...[
          Row(
            children: [
              if (!isCancelled) ...[
                Expanded(child: SizedBox(height: 45, child: cancelButton)),
                const SizedBox(width: 10),
              ],
              Expanded(child: SizedBox(height: 45, child: printButton)),
            ],
          ),
        ] else ...[
          if (!isCancelled) ...[
            SizedBox(height: 45, width: double.infinity, child: cancelButton),
            const SizedBox(height: 10),
          ],
          SizedBox(height: 45, width: double.infinity, child: printButton),
        ],
      ],
    );
  }

  Widget _detailRow(String textSecondary, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(textSecondary, style: TextStyle(color: AppColors.textSecondary)),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}