class CustomerPaymentMethodModel {
  final int customerPaymentMethodId;
  final String brand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;

  CustomerPaymentMethodModel({
    required this.customerPaymentMethodId,
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
  });

  factory CustomerPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentMethodModel(
      customerPaymentMethodId: json['customer_payment_method_id'] ?? 0,
      brand: json['brand'] ?? 'card',
      last4: json['last4'] ?? '',
      expiryMonth: json['expiry_month'] ?? 1,
      expiryYear: json['expiry_year'] ?? 2026,
    );
  }
}

class StorePaymentAccountModel {
  final int storePaymentAccountId;
  final String providerName;
  final String providerEnName;
  final String accountType;
  final String accountNumber;

  StorePaymentAccountModel({
    required this.storePaymentAccountId,
    required this.providerName,
    required this.providerEnName,
    required this.accountType,
    required this.accountNumber,
  });

  factory StorePaymentAccountModel.fromJson(Map<String, dynamic> json) {
    return StorePaymentAccountModel(
      storePaymentAccountId: json['store_payment_account_id'] ?? 0,
      providerName: json['provider_name'] ?? '',
      providerEnName: json['provider_en_name'] ?? json['provider_name'] ?? '',
      accountType: json['account_type'] ?? '',
      accountNumber: json['account_number'] ?? '',
    );
  }
}