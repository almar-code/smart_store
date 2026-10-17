import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';
import '../local/user_local.dart';

class UserAddressService {
  final Dio dio = Dio();
  final UserLocal userLocal = UserLocal();

  // جلب جميع العناوين (GET api/user-addresses)
  Future<List<dynamic>> getAddresses() async {
    final int customerId = await userLocal.getCustomerId();

    final response = await dio.get(
      ApiEndpoints.userAddresses,
      queryParameters: {'customer_id': customerId},
    );
    return response.data['data'];
  }

  // 2. حفظ العنوان (يدمج customer_id مع بيانات النموذج تلقائياً)
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> formData) async {
    final int customerId = await userLocal.getCustomerId();

    final Map<String, dynamic> requestData = {
      ...formData,
      'customer_id': customerId, // الإضافة التلقائية هنا
    };

    final response = await dio.post(
      ApiEndpoints.userAddresses,
      data: requestData,
    );
    return response.data['data'];
  }

  // تعديل عنوان (PUT api/user-addresses/{id})
  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> data) async {
    final int customerId = await userLocal.getCustomerId();
    final Map<String, dynamic> requestData = {
      ...data,
      'customer_id': customerId, // الإضافة التلقائية هنا
    };
    final response = await dio.put('${ApiEndpoints.userAddresses}/$id', data: requestData);
    return response.data['data'];
  }

  // حذف عنوان (DELETE api/user-addresses/{id})
  Future<void> deleteAddress(int id) async {
    await dio.delete('${ApiEndpoints.userAddresses}/$id');
  }

  // تعيين كافتراضي (PATCH api/user-addresses/{id}/set-default)
  Future<void> setDefaultAddress(int addressId) async {
    final int customerId = await userLocal.getCustomerId();

    await dio.patch(
      '${ApiEndpoints.userAddresses}/$addressId/set-default',
      data: {'customer_id': customerId},
    );
  }
}