import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/network_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repos/auth_repo.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AuthRepo repo;

  AccountCubit(this.repo) : super(AccountInitial());

  UserModel? _user;

  // جلب بيانات المستخدم من Hive
  Future<void> loadUser() async {
    // التحميل يظهر أول مرة فقط
    if (_user == null) emit(AccountLoading());

    final user = await repo.getLocalUser();
    if (user == null) {
      _user = null;
      emit(AccountGuest());
      return;
    }
    _user = user;
    emit(AccountLoaded(user));
  }

  // تعديل اسم المستخدم
  Future<void> updateName(String name) async {
    final user = _user;
    if (user == null || state is AccountNameUpdating) return;

    final newName = name.trim();

    // لا يوجد تغيير
    if (newName == user.name.trim()) {
      emit(AccountNameUpdated(user, ''));
      return;
    }

    if (!await NetworkService.hasInternet()) {
      emit(AccountNameError(user, 'internet_connection_error'));
      return;
    }

    emit(AccountNameUpdating(user));
    try {
      await repo.updateUserName(newName);
      _user = await repo.getLocalUser() ?? user;
      emit(AccountNameUpdated(_user!, 'name_updated_success'));
    } catch (e) {
      emit(AccountNameError(user, 'name_update_failed'));
    }
  }

  // حذف الصورة الشخصية
  Future<void> deleteAvatar() async {
    final user = _user;
    if (user == null || state is AccountAvatarDeleting) return;

    if (!await NetworkService.hasInternet()) {
      emit(AccountAvatarError(user, 'internet_connection_error'));
      return;
    }

    emit(AccountAvatarDeleting(user));
    try {
      await repo.deleteUserAvatar();
      _user = await repo.getLocalUser() ?? user;
      emit(AccountAvatarDeleted(_user!, 'avatar_deleted_success'));
    } catch (e) {
      emit(AccountAvatarError(user, 'avatar_delete_failed'));
    }
  }
}
