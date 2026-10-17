import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import 'package:smart_store/views/screens/payment/payment_success_screen.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/app_form_field.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/buttons/cancel_button.dart';
import '../../../core/widgets/cards/drop_card.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/underlined_title.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../data/models/user_address_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../logic/cart/cart_cubit.dart';
import '../../../logic/payments/payment_cubit.dart';
import '../../../logic/payments/payment_state.dart';
import '../../../logic/user_address/UserAddressCubit.dart';
import '../../widgets/payment/add_payment.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  final int customerId;

  const SelectPaymentMethodPage({
    super.key,
    required this.customerId,
  });

  @override
  State<SelectPaymentMethodPage> createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  String? _activeTag = "cash";
  String? _activeAdd;

  final _bankWalletFormKey = GlobalKey<FormBuilderState>();
  final _bankTransferFormKey = GlobalKey<FormBuilderState>();

  void _toggleExpand(String tag, {String? tagAdd}) {
    setState(() {
      _activeTag = (_activeTag == tag)
          ? (_activeTag == "add_main" && tagAdd != null ? "add_main" : null)
          : tag;
      _activeAdd = (_activeAdd == tagAdd) ? null : tagAdd;
    });
  }

  List<CustomerPaymentMethodModel> _paymentMethods = [];
  List<StorePaymentAccountModel> _storeAccounts = [];

  bool _loadingMethods = true;
  bool _isPaying = false;
  String? _selectedStoreAccountNumber;
  int? _selectedPaymentMethodId;
  int? _selectedStorePaymentAccountId;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    await context.read<PaymentCubit>().loadPaymentData(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    double price = cartCubit.totalPrice;
    double discount = cartCubit.totalDiscount;
    double netPrice = price - discount;

    final selectedAddress = context.watch<UserAddressCubit>().selectedAddress;
    final String addressText = [
      selectedAddress?.country,
      selectedAddress?.city,
      selectedAddress?.street,
      selectedAddress?.title,
    ].where((element) => element != null && element.isNotEmpty).join('، ');

    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentMethodsLoaded) {
          setState(() {
            _paymentMethods = state.methods;
            _storeAccounts = state.storeAccounts;
            _loadingMethods = false;
          });
        } else if (state is PaymentSuccess) {
          AppToasts.showSuccessToast(context, tr('order_created_successfully'));
          context.read<CartCubit>().fetchCart(customerId: 1);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => PaymentSuccessPage()),
                (route) => route.isFirst, // يبقي الصفحة الرئيسية فقط ويمسح باقي الصفحات خلفها
          );
        } else if (state is PaymentError) {
          AppToasts.showErrorToast(context, state.message);
          setState(() => _isPaying = false);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              scrolledUnderElevation: 0,
              elevation: 0,
              leading: Icon(Icons.credit_card,
                  size: isDesktop ? 25 : 21, color: AppColors.iconColor),
              titleSpacing: 0,
              title: AppTitle(
                firstPart: tr('Select'),
                secondPart: tr('Method'),
                fontSize: isDesktop ? 18 : 15,
                spacing: ' ',
              ),
              actions: [
                ArrowBack(),
                SizedBox(width: 10),
              ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gradientTop,
                    AppColors.gradientBottom,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 20,
                  vertical: isDesktop ? 20 : 10,
                ),
                child: Column(
                  children: [
                    UnderlinedTitle(
                      firstPart: tr('Select'),
                      secondPart: tr('Method'),
                      fontSize: isDesktop ? 22 : 18,
                      isCenter: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('withdraw_funds_subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        spacing: 6,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.price_change_outlined,
                                      size: 17,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr('total'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                netPrice.toStringAsFixed(2),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Icon(
                                (selectedAddress == null)
                                    ? Icons.location_off_outlined
                                    : Icons.location_on_outlined,
                                size: 15,
                                color: (selectedAddress == null)
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                              ),
                              Builder(
                                builder: (context) {
                                  if (selectedAddress == null) {
                                    return Text(
                                      tr('address_not_selected'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }

                                  return Text(
                                    addressText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: (context.locale.languageCode == 'en')
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(tr('payment_methods'),
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 15),
                    DropCard(
                      title: tr('cash'),
                      subtitle: tr('cash_on_delivery'),
                      icon: Icons.money,
                      color: AppColors.primary,
                      isSelected: _activeTag == "cash",
                      onTap: () {
                        setState(() {
                          _activeTag = "cash";
                          _selectedPaymentMethodId = null;
                        });
                      },
                      expandedContent: _buildCashCardDetails(netPrice, selectedAddress),
                    ),
                    DropCard(
                      title: tr('bank_and_wallet'),
                      subtitle: tr('pay_via_local_banks_and_wallets'),
                      icon: Icons.account_balance,
                      color: const Color(0xFF5C2FCF),
                      isSelected: _activeTag == "banks_wallet",
                      onTap: () {
                        setState(() {
                          _activeTag = "banks_wallet";
                          _selectedPaymentMethodId = null;
                        });
                      },
                      expandedContent: _buildBanksAndWalletsContent(netPrice, selectedAddress),
                    ),
                    DropCard(
                      title: tr('bank_transfers'),
                      subtitle: tr('direct_bank_wire_transfers'),
                      icon: Icons.account_balance,
                      color: Colors.blueAccent,
                      isSelected: _activeTag == "bank_transfers",
                      onTap: () {
                        setState(() {
                          _activeTag = "bank_transfers";
                          _selectedPaymentMethodId = null;
                        });
                      },
                      expandedContent: _buildBankTransfersContent(netPrice, selectedAddress),
                    ),
                    if (_loadingMethods)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: const CircularProgress(),
                      )
                    else if (_paymentMethods.isNotEmpty)
                      ..._paymentMethods.map(
                            (card) {
                          final id = card.customerPaymentMethodId;
                          final brand = card.brand;
                          final last4 = card.last4;
                          final month = card.expiryMonth.toString().padLeft(2, '0');
                          final year = card.expiryYear.toString();
                          final shortYear = year.length >= 2 ? year.substring(year.length - 2) : '';

                          final isSelected = _selectedPaymentMethodId == id ||
                              _activeTag == "card_$id";

                          return DropCard(
                            title: brand.toUpperCase(),
                            subtitle: '****$last4  $month/$shortYear',
                            icon: Icons.credit_card,
                            color: brand.toLowerCase() == 'visa'
                                ? const Color(0xFF1A1F71)
                                : const Color(0xFFFF5F00),
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethodId = id;
                                _activeTag = "card_$id";
                              });
                            },
                            expandedContent: _buildCardDetails(card, netPrice, selectedAddress),
                          );
                        },
                      ),
                    DropCard(
                      title: tr('add_method'),
                      subtitle: tr('add_new_payment_method'),
                      icon: Icons.add,
                      color: AppColors.iconColor,
                      isSelected: _activeTag == "add_main",
                      onTap: () => _toggleExpand("add_main"),
                      expandedContent: Column(
                        children: [
                          const SizedBox(height: 10),
                          DropCard(
                            title: tr('card'),
                            subtitle: tr('variable_fees_takes_minutes'),
                            icon: Icons.credit_card,
                            color: AppColors.primary,
                            isSelected: _activeAdd == "add_card",
                            onTap: () => _toggleExpand("add_main", tagAdd: "add_card"),
                            isSmall: true,
                            expandedContent: AddCardForm(
                              customerId: widget.customerId,
                              onCancel: () {
                                setState(() {
                                  _activeTag = null;
                                });
                              },
                              onCardAdded: () async {
                                await _loadPaymentData();
                                setState(() {
                                  _activeTag = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanksAndWalletsContent(double netPrice, UserAddressModel? selectedAddress) {
    final String addressText = [
      selectedAddress?.country,
      selectedAddress?.city,
      selectedAddress?.street,
      selectedAddress?.title,
    ].where((element) => element != null && element.isNotEmpty).join('، ');

    return FormBuilder(
      key: _bankWalletFormKey,
      child: Column(
        children: [
          const SizedBox(height: 15),
          const Divider(thickness: 0.5),
          const SizedBox(height: 10),
          _detailRow(tr('amount'), "${netPrice}\$"),
          _detailRow(tr('location'), (selectedAddress == null) ? tr('address_not_selected') : addressText),
          const SizedBox(height: 15),
          FormBuilderDropdown<String>(
            name: 'bankOrWalletName',
            alignment: AlignmentDirectional.centerStart,
            decoration: InputDecoration(
              labelText: tr('Select Bank or Wallet'),
              labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.account_balance_rounded,
                  color: Color(0xFF5C2FCF), size: 22),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                    color: AppColors.borderSecondary.withOpacity(0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                    color: AppColors.borderSecondary.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                const BorderSide(color: Color(0xFF5C2FCF), width: 1.5),
              ),
            ),
            icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
            dropdownColor: AppColors.background,
            borderRadius: BorderRadius.circular(15),
            items: _storeAccounts.map((account) {
              final id = account.storePaymentAccountId.toString();
              final name = (context.locale.languageCode == 'en') ? account.providerName : account.providerEnName;
              final type = account.accountType;

              return DropdownMenuItem<String>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      type == 'bank'
                          ? Icons.account_balance
                          : Icons.account_balance_wallet,
                      size: 18,
                      color: const Color(0xFF5C2FCF),
                    ),
                    const SizedBox(width: 10),
                    Text(name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStorePaymentAccountId =
                value == null ? null : int.tryParse(value);

                final account = _storeAccounts.cast<StorePaymentAccountModel?>().firstWhere(
                      (item) => item?.storePaymentAccountId.toString() == value,
                  orElse: () => null,
                );

                _selectedStoreAccountNumber = account?.accountNumber;
              });
            },
            validator: FormBuilderValidators.required(),
          ),
          if (_selectedStoreAccountNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF5C2FCF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF5C2FCF).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 20, color: Color(0xFF5C2FCF)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('Store Account Number'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedStoreAccountNumber!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C2FCF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _selectedStoreAccountNumber!));
                      AppToasts.showSuccessToast(context, tr('account_number_copied_successfully'));
                    },
                    icon: const Icon(Icons.copy_rounded, color: Color(0xFF5C2FCF), size: 20),
                    tooltip: tr('copy_account_number'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          CustomFormField(
            name: 'transactionNumber',
            label: tr('Transaction Number'),
            iconColor: const Color(0xFF5C2FCF),
            icon: Icons.numbers_rounded,
            color: const Color(0xFF5C2FCF),
            validators: [FormBuilderValidators.required()],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: AppButton(
                    label: tr('pay'),
                    color: const Color(0xFF5C2FCF),
                    borderRadius: 17,
                    icon: Icons.payments_rounded,
                    onTap: _isPaying ? null : _payWithBankAndWallet,
                    child: _isPaying
                        ? CircularProgress(color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: CancelButton(
                    onPressed: () {
                      setState(() {
                        _selectedStoreAccountNumber = null;
                        _activeTag = "cash";
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransfersContent(double netPrice, UserAddressModel? selectedAddress) {
    final String addressText = [
      selectedAddress?.country,
      selectedAddress?.city,
      selectedAddress?.street,
      selectedAddress?.title,
    ].where((element) => element != null && element.isNotEmpty).join('، ');

    return FormBuilder(
      key: _bankTransferFormKey,
      child: Column(
        children: [
          const SizedBox(height: 15),
          const Divider(thickness: 0.5),
          const SizedBox(height: 10),
          _detailRow(tr('amount'), "${netPrice}\$"),
          _detailRow(tr('location'), (selectedAddress == null) ? tr('address_not_selected') : addressText),
          const SizedBox(height: 15),
          CustomFormField(
            name: 'bankName',
            label: tr('Bank Name'),
            iconColor: Colors.blueAccent,
            icon: Icons.account_balance,
            color: Colors.blueAccent,
            validators: [FormBuilderValidators.required()],
          ),
          const SizedBox(height: 12),
          CustomFormField(
            name: 'TransferNumber',
            label: tr('Transfer Number / Reference Number'),
            iconColor: Colors.blueAccent,
            icon: Icons.numbers_rounded,
            color: Colors.blueAccent,
            validators: [FormBuilderValidators.required()],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: AppButton(
                    label: tr('pay'),
                    color: Colors.blueAccent,
                    borderRadius: 17,
                    icon: Icons.payments_rounded,
                    onTap: _isPaying ? null : _payWithBankTransfer,
                    child: _isPaying
                        ? CircularProgress(color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: CancelButton(
                    onPressed: () {
                      setState(() {
                        _activeTag = "cash";
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(CustomerPaymentMethodModel card, double netPrice, UserAddressModel? selectedAddress) {
    final String addressText = [
      selectedAddress?.country,
      selectedAddress?.city,
      selectedAddress?.street,
      selectedAddress?.title,
    ].where((element) => element != null && element.isNotEmpty).join('، ');

    return Column(
      children: [
        const SizedBox(height: 15),
        const Divider(thickness: 0.5),
        _detailRow(tr('amount'), "${netPrice}\$"),
        _detailRow(tr('method'), '${card.brand} Transfer'),
        _detailRow(tr('location'), (selectedAddress == null) ? tr('address_not_selected') : addressText),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: tr('pay'),
                  color: card.brand.toLowerCase() == 'visa'
                      ? const Color(0xFF1A1F71)
                      : const Color(0xFFFF5F00),
                  borderRadius: 17,
                  icon: Icons.payments_rounded,
                  onTap: _isPaying ? null : () => _payWithCard(card),
                  child: _isPaying
                      ? CircularProgress(color: Colors.white, size: 20)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: CancelButton(
                  onPressed: () {
                    setState(() {
                      _selectedPaymentMethodId = null;
                      _activeTag = "cash";
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCashCardDetails(double netPrice, UserAddressModel? selectedAddress) {
    final String addressText = [
      selectedAddress?.country,
      selectedAddress?.city,
      selectedAddress?.street,
      selectedAddress?.title,
    ].where((element) => element != null && element.isNotEmpty).join('، ');

    return Column(
      children: [
        const SizedBox(height: 15),
        const Divider(thickness: 0.5),
        _detailRow(tr('amount'), "${netPrice}\$"),
        _detailRow(tr('method'), tr('cash_transfer')),
        _detailRow(tr('location'), (selectedAddress == null) ? tr('address_not_selected') : addressText),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: AppButton(
                  label: tr('pay'),
                  color: AppColors.primary,
                  borderRadius: 17,
                  icon: Icons.payments_rounded,
                  onTap: _isPaying ? null : _payWithCash,
                  child: _isPaying
                      ? CircularProgress(color: Colors.white, size: 20)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: CancelButton(
                  onPressed: () {
                    setState(() {
                      _selectedPaymentMethodId = null;
                      _activeTag = null;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _payWithCash() async {
    await _submitManualOrder(paymentType: 'cash');
  }

  Future<void> _payWithBankAndWallet() async {
    final form = _bankWalletFormKey.currentState;
    if (form == null || !form.saveAndValidate()) return;

    final values = form.value;
    final accountId = int.tryParse(values['bankOrWalletName']?.toString() ?? '');
    final transactionReference = values['transactionNumber']?.toString().trim() ?? '';

    if (accountId == null || transactionReference.isEmpty) return;

    await _submitManualOrder(
      paymentType: 'bank_wallet',
      storePaymentAccountId: accountId,
      transactionReference: transactionReference,
    );
  }

  Future<void> _payWithBankTransfer() async {
    final form = _bankTransferFormKey.currentState;
    if (form == null || !form.saveAndValidate()) return;

    final values = form.value;
    final bankName = values['bankName']?.toString().trim() ?? '';
    final reference = values['TransferNumber']?.toString().trim() ?? '';

    if (bankName.isEmpty || reference.isEmpty) return;

    await _submitManualOrder(
      paymentType: 'bank_transfer',
      bankName: bankName,
      transactionReference: reference,
    );
  }

  Future<void> _payWithCard(CustomerPaymentMethodModel card) async {
    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      final int? mySelectedId = context.read<UserAddressCubit>().selectedAddress?.addressId;

      final data = await context.read<PaymentCubit>().startCheckout(
        customerId: widget.customerId,
        addressId: mySelectedId,
        customerPaymentMethodId: card.customerPaymentMethodId,
      );

      final clientSecret = data['client_secret']?.toString();
      final stripePaymentMethodId = data['stripe_payment_method_id']?.toString();

      if (clientSecret == null || stripePaymentMethodId == null) {
        throw Exception('Payment information is incomplete.');
      }

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: stripePaymentMethodId,
          ),
        ),
      );

      if (!mounted) return;

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        AppToasts.showSuccessToast(context, tr('order_created_successfully'));
        context.read<CartCubit>().fetchCart(customerId: 1);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => PaymentSuccessPage()),
              (route) => route.isFirst, // يبقي الصفحة الرئيسية فقط ويمسح باقي الصفحات خلفها
        );
      } else {
        AppToasts.showSuccessToast(context, 'Payment status: ${paymentIntent.status}');
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      AppToasts.showErrorToast(context, tr('payment_cancelled_or_failed'));
    } catch (e) {
      if (!mounted) return;
      AppToasts.showErrorToast(context, tr('unexpected_error'));
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  Widget _detailRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(color: AppColors.textSecondary)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold))
      ],
    ),
  );

  Future<void> _submitManualOrder({
    required String paymentType,
    int? storePaymentAccountId,
    String? transactionReference,
    String? bankName,
  }) async {
    if (_isPaying) return;

    final address = context.read<UserAddressCubit>().selectedAddress;

    if (address == null || address.addressId == null) {
      AppToasts.showWarningToast(context, tr('please_select_shipping_address'));
      return;
    }

    setState(() => _isPaying = true);

    await context.read<PaymentCubit>().createManualCheckout(
      customerId: widget.customerId,
      addressId: address.addressId!,
      paymentType: paymentType,
      storePaymentAccountId: storePaymentAccountId,
      transactionReference: transactionReference,
      bankName: bankName,
    );
  }
}