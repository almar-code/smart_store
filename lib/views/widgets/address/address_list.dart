import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/cancel_button.dart';
import '../../../core/widgets/cards/address_drop_card.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../data/models/user_address_model.dart';
import '../../../logic/user_address/UserAddressCubit.dart';
import '../../../logic/user_address/user_address_state.dart';
import '../../screens/address/add_address_screen.dart';
import '../flash/flash_screen.dart';
import 'empty_address_list.dart';

class AddressListView extends StatefulWidget {
  final bool isIconsShow;
  final Function(UserAddressModel address)? onEditAddress; // كولباك لإرجاع العنوان المراد تعديله للصفحة الرئيسية

  const

  AddressListView({
    super.key,
    this.isIconsShow = true,
    this.onEditAddress,
  });

  @override
  State<AddressListView> createState() => _AddressListViewState();
}

class _AddressListViewState extends State<AddressListView> {
  int? _activeAddressId;

  @override
  void initState() {
    super.initState();
    context.read<UserAddressCubit>().getAddresses();
  }

  void _toggleExpand(int addressId) {
    setState(() {
      _activeAddressId = (_activeAddressId == addressId) ? null : addressId;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocConsumer<UserAddressCubit, UserAddressState>(
      listener: (context, state) {
        if (state is UserAddressActionSuccess) {
          AppToasts.showSuccessToast(context, tr(state.message));
        } else if (state is UserAddressError) {
          AppToasts.showErrorToast(context, tr(state.message));
        }
      },
      builder: (context, state) {
        if (state is UserAddressLoading && state is! UserAddressLoaded) {
          return AddressShimmer();
        }

        if (state is UserAddressEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: EmptyAddressScreen(),
            ),
          );
        }

        if (state is UserAddressLoaded) {
          final addresses = state.addresses;

          return ListView.builder(
            padding: EdgeInsets.all(isDesktop ? 16 : 8),
            itemCount: addresses.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final address = addresses[index];
              final bool isSelected = _activeAddressId == address.addressId;

              return AddressDropCard(
                title: address.title,
                subtitle: "${address.city}, ${address.country}",
                icon: _getIconForTitle(address.title),
                iconSize: isDesktop ? 22 : 20,
                color: address.isDefault ? AppColors.primary : AppColors.redColor,
                isSelected: isSelected,
                isDefault: address.isDefault,
                onTap: () => _toggleExpand(address.addressId),
                expandedContent: _buildExpandedDetails(context, address),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildExpandedDetails(BuildContext context, UserAddressModel address) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Divider(thickness: 0.5),
        const SizedBox(height: 6),
        _detailRow(tr('country'), address.country),
        _detailRow(tr('city'), address.city),
        _detailRow(tr('street'), address.street),
        if (address.building != null && address.building!.isNotEmpty)
          _detailRow(tr('building'), address.building!),
        if (address.postalCode != null && address.postalCode!.isNotEmpty)
          _detailRow(tr('postal_code'), address.postalCode!),
        const SizedBox(height: 15),

        // الأزرار الثلاثة: الافتراضي، التعديل، والحذف
        Row(
          spacing: 8,
          children: [
            // 1. زر التعيين كافتراضي
            if(!address.isDefault)
              Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label:  tr('set_as_default_address'),
                  color:  AppColors.primary,
                  borderRadius: 12,
                  icon: Icons.check_circle_outline,
                  onTap: address.isDefault
                      ? null
                      : () {
                    context.read<UserAddressCubit>().setDefaultAddress(address.addressId);
                  },
                ),
              ),
            ),

            // 2. زر التعديل
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: tr('edit'),
                  color: AppColors.background,
                  textColor: AppColors.textColor,
                  borderRadius: 12,
                  borderColor: AppColors.borderSecondary,
                  icon: Icons.edit_location_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddAddress(addressToEdit: address),
                      ),
                    );
                    if (widget.onEditAddress != null) {
                      widget.onEditAddress!(address);
                    }
                  },
                ),
              ),
            ),

            // 3. زر الحذف مع رسالة التأكيد
            Expanded(
              child: SizedBox(
                height: 45,
                child: DeleteButton(
                  onPressed: () async {
                    final confirm = await AppToasts.showConfirmDialog(
                      context: context,
                      title: tr('confirm_delete_title'),
                      message: tr('confirm_delete_address_msg'),
                    );

                    if (confirm == true && context.mounted) {
                      context.read<UserAddressCubit>().deleteAddress(address.addressId);
                    }
                  },
                  borderRadius: 12,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    ),
  );

  IconData _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('home') || lower.contains('بيت') || lower.contains('منزل')) {
      return CupertinoIcons.home;
    } else if (lower.contains('work') ||lower.contains('office') || lower.contains('عمل') || lower.contains('مكتب')) {
      return Icons.work_outline;
    }
    return CupertinoIcons.map_pin_ellipse;
  }
}