import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../data/models/user_address_model.dart';
import '../../../logic/user_address/UserAddressCubit.dart';
import '../../../logic/user_address/user_address_state.dart';
import '../flash/flash_screen.dart';

class CheckoutAddressListView extends StatefulWidget {
  final Function(UserAddressModel selectedAddress)? onAddressSelected;

  const CheckoutAddressListView({
    super.key,
    this.onAddressSelected,
  });

  @override
  State<CheckoutAddressListView> createState() => _CheckoutAddressListViewState();
}

class _CheckoutAddressListViewState extends State<CheckoutAddressListView> {
  // تتبع العنوان المحدد للشحن حالياً
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    context.read<UserAddressCubit>().getAddresses();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocConsumer<UserAddressCubit, UserAddressState>(
      listener: (context, state) {
        // عند تحميل العناوين لأول مرة، نختار العنوان الافتراضي تلقائياً إن وجد
        if (state is UserAddressLoaded && _selectedAddressId == null) {
          final defaultAddr = state.addresses.firstWhere(
                (element) => element.isDefault,
            orElse: () => state.addresses.first,
          );
          setState(() {
            _selectedAddressId = defaultAddr.addressId;
          });
          if (widget.onAddressSelected != null) {
            widget.onAddressSelected!(defaultAddr);
          }
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
              child: Text(
                tr('no_addresses_found'),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
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
              // فحص ما إذا كان هذا العنوان هو المحدد للشحن حالياً
              final bool isSelectedForShipping = _selectedAddressId == address.addressId;

              return _buildShippingAddressCard(
                context,
                address: address,
                isSelected: isSelectedForShipping,
                isDesktop: isDesktop,
                onTap: () {
                  setState(() {
                    _selectedAddressId = address.addressId;
                  });
                  if (widget.onAddressSelected != null) {
                    widget.onAddressSelected!(address);
                  }
                },
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildShippingAddressCard(
      BuildContext context, {
        required UserAddressModel address,
        required bool isSelected,
        required bool isDesktop,
        required VoidCallback onTap,
      }) {
    // تجميع التفاصيل في نص واحد
    final String details = [
      address.country,
      address.city,
      address.street,
      if (address.building != null && address.building!.isNotEmpty) address.building,
    ].where((e) => e != null && e!.isNotEmpty).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSecondary,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.boxShadow.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // 1. أيقونة مسمى العنوان
            Container(
              width: isDesktop ? 45 : 40,
              height: isDesktop ? 45 : 40,
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : AppColors.redColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForTitle(address.title),
                color: isSelected ? AppColors.primary : AppColors.redColor,
                size: isDesktop ? 22 : 18,
              ),
            ),
            const SizedBox(width: 14),

            // 2. المسمى والتفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.title,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 16 : 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // يبقى وسم Default ثابتاً للعنوان الافتراضي دائماً
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            tr('default'),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isDesktop ? 13 : 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // 3. دائرة الاختيار (Radio Button) تضيء للعنوان المحدد حالياً فقط
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('home') || lower.contains('بيت') || lower.contains('منزل')) {
      return CupertinoIcons.home;
    } else if (lower.contains('work') || lower.contains('office') || lower.contains('عمل') || lower.contains('مكتب')) {
      return Icons.work_outline;
    }
    return CupertinoIcons.map_pin_ellipse;
  }
}