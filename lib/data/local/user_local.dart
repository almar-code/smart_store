import 'package:hive/hive.dart';
import '../../logic/login/login_cubit.dart';
import '../models/user_model.dart';

class UserLocal {

  static const String boxName = 'user_info_box';

  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(boxName);

    await box.putAll(user.toMap());
  }

  Future<UserModel?> getUser() async {

    final box = await Hive.openBox(boxName);

    if(box.isEmpty) return null;

    return UserModel.fromMap(
      Map<String,dynamic>.from(box.toMap()),
    );
  }
  Future<int?> getCustomerId() async {
    var box = Hive.box('user_info_box');
    var customerID = (box.isEmpty) ? '' :  box.get('customer_id');
    return int.tryParse(customerID.toString());
  }
  hasPhone() {
    final box = Hive.box('user_info_box');

    String? phone = box.get('phone');

    return (phone != null && phone.isNotEmpty);
  }
  Future<void> clearUser() async {

    final box = await Hive.openBox(boxName);
    await box.clear();

  }

  // تحديث الاسم فقط
  Future<void> updateName(String name) async {
    final box = await Hive.openBox(boxName);
    await box.put('name', name);
  }
  // تحديث الصورة فقط
  Future<void> updateImage(String image) async {
    final box = await Hive.openBox(boxName);
    await box.put('image', image);
  }

}