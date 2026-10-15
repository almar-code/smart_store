import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/payment_repo.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepo repo;

  PaymentCubit(this.repo) : super(PaymentInitial());

  // جلب بطاقات العميل وحسابات المتجر
  Future<void> loadPaymentData(int customerId) async {
    emit(PaymentLoading());
    try {
      final methods = await repo.getPaymentMethods(customerId);
      final storeAccounts = await repo.getStorePaymentAccounts();
      emit(PaymentMethodsLoaded(methods, storeAccounts));
    } catch (e) {
      emit(PaymentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // إعداد البطاقة عبر Stripe
  Future<Map<String, dynamic>> setupCard(int customerId) async {
    try {
      return await repo.setupCard(customerId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // مزامنة البطاقة بعد نجاح الـ SetupIntent
  Future<void> syncCard({required int customerId, required String setupIntentId}) async {
    try {
      await repo.syncCard(customerId: customerId, setupIntentId: setupIntentId);
      loadPaymentData(customerId); // تحديث القائمة
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // بدء الدفع الإلكتروني (Stripe)
  Future<Map<String, dynamic>> startCheckout({
    required int customerId,
    required int? addressId,
    required int customerPaymentMethodId,
  }) async {
    try {
      return await repo.startCheckout(
        customerId: customerId,
        addressId: addressId,
        customerPaymentMethodId: customerPaymentMethodId,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // إرسال الطلب اليدوي (كاش، محافظ، حوالات)
  Future<void> createManualCheckout({
    required int customerId,
    required int addressId,
    required String paymentType,
    int? storePaymentAccountId,
    String? transactionReference,
    String? bankName,
  }) async {
    emit(PaymentLoading());
    try {
      final result = await repo.createManualCheckout(
        customerId: customerId,
        addressId: addressId,
        paymentType: paymentType,
        storePaymentAccountId: storePaymentAccountId,
        transactionReference: transactionReference,
        bankName: bankName,
      );
      emit(PaymentSuccess(result));
    } catch (e) {
      emit(PaymentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
  // حذف بطاقة دفع محفوظة
  Future<void> deletePaymentMethod(int paymentMethodId, int customerId) async {
    emit(PaymentLoading());
    try {
      await repo.deletePaymentMethod(paymentMethodId, customerId);
      loadPaymentData(customerId); // إعادة تحميل القائمة بعد الحذف بنجاح
    } catch (e) {
      emit(PaymentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}