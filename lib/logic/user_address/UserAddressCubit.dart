import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_address_state.dart';
import '../../data/repos/user_address_repo.dart';

class UserAddressCubit extends Cubit<UserAddressState> {
  final UserAddressRepo repo;

  UserAddressCubit(this.repo) : super(UserAddressInitial());

  // جلب كافة العناوين
  Future<void> getAddresses() async {
    emit(UserAddressLoading());
    try {
      final addresses = await repo.getAddresses();
      if (addresses.isEmpty) {
        emit(UserAddressEmpty());
      } else {
        emit(UserAddressLoaded(addresses));
      }
    } catch (e) {
      emit(UserAddressError('fetch_addresses_error'));
    }
  }

  // حفظ عنوان جديد
  Future<void> addAddress(Map<String, dynamic> data) async {
    emit(UserAddressLoading());
    try {
      await repo.createAddress(data);
      emit(UserAddressActionSuccess('address_added_success'));
      getAddresses(); // إعادة جلب القائمة المحدثة
    } catch (e) {
      emit(UserAddressError('add_address_error'));
    }
  }
  Future<void> updateAddress(int id, Map<String, dynamic> data) async {
    emit(UserAddressLoading());
    try {
      await repo.updateAddress(id, data);
      emit(UserAddressActionSuccess('address_updated_success'));
      getAddresses(); // إعادة جلب القائمة المحدثة بعد التعديل
    } catch (e) {
      emit(UserAddressError('update_address_error'));
    }
  }
  // تعيين العنوان كافتراضي
  Future<void> setDefaultAddress(int id) async {
    emit(UserAddressLoading());
    try {
      await repo.setDefaultAddress(id);
      emit(UserAddressActionSuccess('set_default_address_success'));
      getAddresses();
    } catch (e) {
      emit(UserAddressError('set_default_address_error'));
    }
  }

  // حذف عنوان
  Future<void> deleteAddress(int id) async {
    emit(UserAddressLoading());
    try {
      await repo.deleteAddress(id);
      emit(UserAddressActionSuccess('delete_address_success'));
      getAddresses();
    } catch (e) {
      emit(UserAddressError('delete_address_error'));
    }
  }
}