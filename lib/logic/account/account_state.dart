import '../../data/models/user_model.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

// المستخدم غير مسجل
class AccountGuest extends AccountState {}

class AccountLoaded extends AccountState {
  final UserModel user;
  AccountLoaded(this.user);
}

// جاري حفظ الاسم مع بقاء البيانات ظاهرة
class AccountNameUpdating extends AccountLoaded {
  AccountNameUpdating(super.user);
}

class AccountNameUpdated extends AccountLoaded {
  final String message;
  AccountNameUpdated(super.user, this.message);
}

class AccountNameError extends AccountLoaded {
  final String message;
  AccountNameError(super.user, this.message);
}

// جاري حذف الصورة
class AccountAvatarDeleting extends AccountLoaded {
  AccountAvatarDeleting(super.user);
}

class AccountAvatarDeleted extends AccountLoaded {
  final String message;
  AccountAvatarDeleted(super.user, this.message);
}

class AccountAvatarError extends AccountLoaded {
  final String message;
  AccountAvatarError(super.user, this.message);
}
