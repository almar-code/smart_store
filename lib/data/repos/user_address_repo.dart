import '../models/user_address_model.dart';
import '../services/user_address_service.dart';

class UserAddressRepo {
  final UserAddressService service;
  UserAddressRepo(this.service);

  Future<List<UserAddressModel>> getAddresses() async {
    final data = await service.getAddresses();
    return data
        .map<UserAddressModel>((json) => UserAddressModel.fromJson(json))
        .toList();
  }

  Future<UserAddressModel> createAddress(Map<String, dynamic> data) async {
    final res = await service.createAddress(data);
    return UserAddressModel.fromJson(res);
  }

  Future<UserAddressModel> updateAddress(int id, Map<String, dynamic> data) async {
    final res = await service.updateAddress(id, data);
    return UserAddressModel.fromJson(res);
  }

  Future<void> deleteAddress(int id) async {
    await service.deleteAddress(id);
  }

  Future<void> setDefaultAddress(int id) async {
    await service.setDefaultAddress(id);
  }
}