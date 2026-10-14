import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/cancel_button.dart';
import '../../../core/widgets/circularProgress.dart';
import '../../../logic/payments/payment_cubit.dart';

class AddCardForm extends StatefulWidget {
  final int customerId;
  final VoidCallback onCancel;
  final VoidCallback onCardAdded;

  const AddCardForm({
    super.key,
    required this.customerId,
    required this.onCancel,
    required this.onCardAdded,
  });

  @override
  State<AddCardForm> createState() => _AddCardFormState();
}

class _AddCardFormState extends State<AddCardForm> {
  bool _loading = false;

  Future<void> _addCard() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    try {
      final paymentCubit = context.read<PaymentCubit>();
      final data = await paymentCubit.setupCard(widget.customerId);

      if (data['success'] != true) {
        AppToasts.showWarningToast(context, tr('error_try_again'));
        throw Exception(data['message'] ?? 'Unable to prepare card setup.');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Smart Abaya Store',
          customerId: data['customer'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          setupIntentClientSecret: data['setupIntent'],
          primaryButtonLabel: tr('Add Card'),
          allowsDelayedPaymentMethods: false,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final setupIntent = await Stripe.instance.retrieveSetupIntent(
        data['setupIntent'],
      );

      await paymentCubit.syncCard(
        customerId: widget.customerId,
        setupIntentId: setupIntent.id,
      );

      if (!mounted) return;
      AppToasts.showSuccessToast(context, tr('card_added_successfully'));

      widget.onCardAdded();
    } on StripeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.error.localizedMessage ?? tr('payment_was_cancelled'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 0.5,
        ),
        const SizedBox(height: 10),
        Text(
          tr('card_info_secure_stripe'),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: AppButton(
            label: _loading ? tr('processing') : tr('Add Card'),
            color: AppColors.primary,
            borderRadius: 17,
            icon: Icons.add_card_rounded,
            onTap: _loading ? () {} : _addCard,
            child: _loading
                ? CircularProgress(color: Colors.white, size: 20)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: CancelButton(
            onPressed: _loading ? () {} : widget.onCancel,
          ),
        ),
      ],
    );
  }
}