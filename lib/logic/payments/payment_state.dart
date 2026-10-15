import '../../data/models/payment_model.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentMethodsLoaded extends PaymentState {
  final List<CustomerPaymentMethodModel> methods;
  final List<StorePaymentAccountModel> storeAccounts;
  PaymentMethodsLoaded(this.methods, this.storeAccounts);
}

class PaymentSuccess extends PaymentState {
  final Map<String, dynamic> data;
  PaymentSuccess(this.data);
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}