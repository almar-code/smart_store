import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentRepo {
  final PaymentService service;
  PaymentRepo(this.service);

  Future<List<CustomerPaymentMethodModel>> getPaymentMethods() async {
    final data = await service.getPaymentMethods();
    return data.map((json) => CustomerPaymentMethodModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> setupCard() async {
    return await service.setupCard();
  }

  Future<Map<String, dynamic>> syncCard({ required String setupIntentId}) async {
    return await service.syncCard(setupIntentId: setupIntentId);
  }

  Future<Map<String, dynamic>> startCheckout({
    required int? addressId,
    required int customerPaymentMethodId,
  }) async {
    return await service.startCheckout(
      addressId: addressId,
      customerPaymentMethodId: customerPaymentMethodId,
    );
  }

  Future<List<StorePaymentAccountModel>> getStorePaymentAccounts() async {
    final data = await service.getStorePaymentAccounts();
    return data.map((json) => StorePaymentAccountModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> createManualCheckout({
    required int addressId,
    required String paymentType,
    int? storePaymentAccountId,
    String? transactionReference,
    String? bankName,
  }) async {
    return await service.createManualCheckout(
      addressId: addressId,
      paymentType: paymentType,
      storePaymentAccountId: storePaymentAccountId,
      transactionReference: transactionReference,
      bankName: bankName,
    );
  }
  Future<void> deletePaymentMethod(int paymentMethodId) async {
    await service.deletePaymentMethod(paymentMethodId);
  }
}