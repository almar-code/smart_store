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

  Future<void> clearUser() async {

    final box = await Hive.openBox(boxName);
    await box.clear();

  }
}