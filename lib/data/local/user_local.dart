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
  Future<int> getCustomerId() async {
    final box = Hive.box('user_info_box');
    final customerId = (box.isEmpty) ? '' :  box.get('customer_id');
    return customerId;
  }
  Future<void> clearUser() async {

    final box = await Hive.openBox(boxName);
    await box.clear();

  }
  /// يرجع رقم العميل الحقيقي، أو null إذا لم يكن مسجلاً
  /// (بدون القيمة الوهمية 1 حتى لا تُدمج مشاهدات كل الزوار في عميل واحد)
  Future<int?> getCustomerIdOrNull() async {
    final box = await Hive.openBox(boxName);
    final value = box.get('customer_id');
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}