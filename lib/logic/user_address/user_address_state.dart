import '../../data/models/user_address_model.dart';

abstract class UserAddressState {}

class UserAddressInitial extends UserAddressState {}

class UserAddressLoading extends UserAddressState {}

class UserAddressEmpty extends UserAddressState {}

class UserAddressLoaded extends UserAddressState {
  final List<UserAddressModel> addresses;
  UserAddressLoaded(this.addresses);
}

class UserAddressActionSuccess extends UserAddressState {
  final String message;
  UserAddressActionSuccess(this.message);
}

class UserAddressError extends UserAddressState {
  final String message;
  UserAddressError(this.message);
}