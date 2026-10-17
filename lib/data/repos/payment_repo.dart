import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentRepo {
  final PaymentService service;
  PaymentRepo(this.service);

  Future<List<CustomerPaymentMethodModel>> getPaymentMethods(int customerId) async {
    final data = await service.getPaymentMethods(customerId);
    return data.map((json) => CustomerPaymentMethodModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> setupCard(int customerId) async {
    return await service.setupCard(customerId);
  }

  Future<Map<String, dynamic>> syncCard({required int customerId, required String setupIntentId}) async {
    return await service.syncCard(customerId: customerId, setupIntentId: setupIntentId);
  }

  Future<Map<String, dynamic>> startCheckout({
    required int customerId,
    required int? addressId,
    required int customerPaymentMethodId,
  }) async {
    return await service.startCheckout(
      customerId: customerId,
      addressId: addressId,
      customerPaymentMethodId: customerPaymentMethodId,
    );
  }

  Future<List<StorePaymentAccountModel>> getStorePaymentAccounts() async {
    final data = await service.getStorePaymentAccounts();
    return data.map((json) => StorePaymentAccountModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> createManualCheckout({
    required int customerId,
    required int addressId,
    required String paymentType,
    int? storePaymentAccountId,
    String? transactionReference,
    String? bankName,
  }) async {
    return await service.createManualCheckout(
      customerId: customerId,
      addressId: addressId,
      paymentType: paymentType,
      storePaymentAccountId: storePaymentAccountId,
      transactionReference: transactionReference,
      bankName: bankName,
    );
  }
  Future<void> deletePaymentMethod(int paymentMethodId, int customerId) async {
    await service.deletePaymentMethod(paymentMethodId, customerId);
  }
}