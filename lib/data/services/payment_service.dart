import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_endpoints.dart';

class PaymentService {
  final Dio dio = Dio();
  final box = Hive.box('user_info_box');

  Future<List<dynamic>> getPaymentMethods() async {
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');

    final response = await dio.get(
      ApiEndpoints.getPaymentMethods,
      queryParameters: {'customer_id': customerId},
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> setupCard() async {
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');
    final response = await dio.post(
      ApiEndpoints.setupCard,
      data: {'customer_id': customerId},
      options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> syncCard({ required String setupIntentId}) async {
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');
    final response = await dio.post(
      ApiEndpoints.syncCard,
      data: {'customer_id': customerId, 'setup_intent_id': setupIntentId},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> startCheckout({
    required int? addressId,
    required int customerPaymentMethodId,
  }) async {
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');

    final response = await dio.post(
      ApiEndpoints.startCheckout,
      data: {
        'customer_id': customerId,
        'address_id': addressId,
        'customer_payment_method_id': customerPaymentMethodId,
      },
      options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
    );
    return response.data['data'];
  }

  Future<List<dynamic>> getStorePaymentAccounts() async {
    final response = await dio.get(
      ApiEndpoints.getStorePaymentAccounts,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> createManualCheckout({
    required int addressId,
    required String paymentType,
    int? storePaymentAccountId,
    String? transactionReference,
    String? bankName,
  }) async {
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');
    final response = await dio.post(
      ApiEndpoints.createManualCheckout,
      data: {
        'customer_id': customerId,
        'address_id': addressId,
        'payment_type': paymentType,
        if (storePaymentAccountId != null) 'store_payment_account_id': storePaymentAccountId,
        if (transactionReference != null) 'transaction_reference': transactionReference.trim(),
        if (bankName != null) 'bank_name': bankName.trim(),
      },
      options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
    );
    return response.data['data'];
  }
  Future<Map<String, dynamic>> deletePaymentMethod(int paymentMethodId) async {
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');

    final response = await dio.delete(
      ApiEndpoints.deletePaymentMethod(paymentMethodId),
      data: {'customer_id': customerId},
      options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
    );
    return response.data;
  }
}