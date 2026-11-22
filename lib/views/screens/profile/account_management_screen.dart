import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/guest_prompt.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/internet_check.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/account/account_cubit.dart';
import '../../../logic/account/account_state.dart';
import '../../../logic/login/login_cubit.dart';
import '../../../logic/login/profile_logic.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../widgets/account/account_header.dart';
import '../../widgets/account/account_widgets.dart';
import '../../widgets/account/edit_name_sheet.dart';
import '../../widgets/account/photo_options_sheet.dart';
import '../../widgets/login/phone_number.dart';
import 'profile_screen.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountCubit>()..loadUser(),
      child: const AccountManagementView(),
    );
  }
}

class AccountManagementView extends StatelessWidget {
  const AccountManagementView({super.key});

  // ==================== الإجراءات ====================

  // الضغط على الصورة: بدون صورة يفتح الاختيار مباشرة، ومع صورة يعرض الخيارات
  Future<void> _onAvatarTap(BuildContext context, bool hasImage) async {
    if (!hasImage) return _changePhoto(context);

    final option = await PhotoOptionsSheet.show(context);
    if (!context.mounted) return;

    if (option == PhotoOption.change) await _changePhoto(context);
    if (option == PhotoOption.delete) await _deletePhoto(context);
  }

  // تعديل الصورة من ProfileLogic
  Future<void> _changePhoto(BuildContext context) async {
    await ProfileLogic.updateAvatar(context);
    if (context.mounted) context.read<AccountCubit>().loadUser();
  }

  // تأكيد ثم حذف الصورة
  Future<void> _deletePhoto(BuildContext context) async {
    final confirm = await AppToasts.showConfirmDialog(
      context: context,
      title: tr('account_delete_photo'),
      message: tr('account_delete_photo_confirm'),
    );
    if (confirm == true && context.mounted) {
      context.read<AccountCubit>().deleteAvatar();
    }
  }

  // نافذة الخروج الموجودة في صفحة البروفايل
  Future<void> _logout(BuildContext context) async {
    await showLogoutDialog(context);
    if (context.mounted && !context.read<LoginCubit>().state) {
      Navigator.of(context).pop();
    }
  }

  void _copyEmail(BuildContext context, String email) {
    Clipboard.setData(ClipboardData(text: email));
    AppToasts.showSuccessToast(context, tr('account_email_copied'));
  }

  // رسائل حالات الاسم والصورة
  void _listener(BuildContext context, AccountState state) {
    String? success;
    String? error;

    if (state is AccountNameUpdated && state.message.isNotEmpty) success = state.message;
    if (state is AccountAvatarDeleted) success = state.message;
    if (state is AccountNameError) error = state.message;
    if (state is AccountAvatarError) error = state.message;

    if (success != null) {
      AppToasts.showSuccessToast(context, tr(success));
      // تحديث البيانات في باقي الصفحات
      context.read<LoginCubit>()
        ..setLoggedOut()
        ..setLoggedIn();
    } else if (error != null) {
      if (error == 'internet_connection_error') {
        InternetCheck.internetCheck(context);
      } else {
        AppToasts.showErrorToast(context, tr(error));
      }
    }
  }

  // ==================== الواجهة ====================

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    context.locale;

    return BlocListener<LoginCubit, bool>(
      // بعد تعديل الصورة او الرقم يتم اعادة تفعيل LoginCubit
      listenWhen: (_, isLoggedIn) => isLoggedIn,
      listener: (context, _) => context.read<AccountCubit>().loadUser(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Icon(
              CupertinoIcons.person_crop_circle,
              size: isDesktop ? 25 : 21,
              color: AppColors.iconColor,
            ),
            titleSpacing: 0,
            title: AppTitle(
              firstPart: tr('account_title_manage'),
              secondPart: tr('account_title_profile'),
              fontSize: isDesktop ? 18 : 15,
              spacing: ' ',
            ),
            actions: const [ArrowBack()],
          ),
          body: BlocConsumer<AccountCubit, AccountState>(
            listener: _listener,
            builder: (context, state) {
              if (state is AccountGuest) {
                return GuestPrompt(subtitle: tr('account_guest_subtitle'));
              }
              if (state is AccountLoaded) {
                return _buildContent(context, state.user, state is AccountAvatarDeleting, isDesktop);
              }
              return const Center(child: CircularProgress(size: 35));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserModel user, bool deleting, bool isDesktop) {
    int i = 0;
    // حركة ظهور متتابعة للأقسام
    Widget enter(Widget w) => w
        .animate(delay: (70 * i++).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: .08, end: 0, curve: Curves.easeOutCubic);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 650 : double.infinity),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: isDesktop ? 20 : 12),
          children: [
            enter(AccountHeader(
              user: user,
              isLoading: deleting,
              onAvatarTap: () => _onAvatarTap(context, user.image.isNotEmpty),
            )),
            SizedBox(height: isDesktop ? 30 : 24),

            enter(AccountSectionCard(
              title: tr('account_personal_info'),
              background: 'assets/images/personal_information.png',
              children: [
                AccountInfoRow(
                  icon: CupertinoIcons.person,
                  label: tr('full_name'),
                  value: user.name.isEmpty ? tr('account_not_set') : user.name,
                  trailing: AccountPillButton(
                    label: tr('edit'),
                    icon: CupertinoIcons.pencil,
                    onTap: () => EditNameSheet.show(context, user.name),
                  ),
                  onTap: () => EditNameSheet.show(context, user.name),
                ),
                AccountInfoRow(
                  icon: CupertinoIcons.mail,
                  label: tr('email_address'),
                  value: user.email,
                  trailing: const AccountLockedBadge(),
                  onLongPress: () => _copyEmail(context, user.email),
                ),
                AccountInfoRow(
                  icon: CupertinoIcons.phone,
                  label: tr('phone_number'),
                  value: user.phone.isEmpty ? tr('account_not_set') : user.phone,
                  trailing: AccountPillButton(
                    label: user.phone.isEmpty ? tr('add') : tr('edit'),
                    icon: user.phone.isEmpty ? CupertinoIcons.add : CupertinoIcons.pencil,
                    onTap: () => PhoneNumber.show(context,(){
                      context.read<NavigationCubit>().updateIndex(4);
                    }),
                  ),
                  onTap: () => PhoneNumber.show(context,(){
                    context.read<NavigationCubit>().updateIndex(4);
                  }),
                ),
              ],
            )),
            SizedBox(height: isDesktop ? 26 : 22),

            enter(AccountSectionTitle(tr('account_session_section'))),
            enter(AccountLogoutCard(onTap: () => _logout(context))),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
