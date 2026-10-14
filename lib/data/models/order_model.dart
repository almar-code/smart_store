import '../models/user_address_model.dart';

class OrderModel {
  final int orderId;
  final int customerId;
  final int? addressId;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String createdAt;
  final UserAddressModel? address; // كائن العنوان

  OrderModel({
    required this.orderId,
    required this.customerId,
    this.addressId,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      addressId: json['address_id'],
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      // استخدام fromJson الخاصة بموديل العنوان مباشرة إذا كان موجوداً
      address: json['address'] != null
          ? UserAddressModel.fromJson(json['address'])
          : null,
    );
  }
}