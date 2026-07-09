import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionAdminCommissionPaymentWidget extends StatelessWidget {
  final double adminCommissionAmount;
  final bool isPaid;
  final AuctionTransactionPaymentInfo? paymentInfo;

  const AuctionAdminCommissionPaymentWidget({
    super.key,
    required this.adminCommissionAmount,
    this.isPaid = false,
    this.paymentInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (isPaid) {
      return _PaidCommissionWidget(
        adminCommissionAmount: adminCommissionAmount,
        paymentInfo: paymentInfo,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(
          children: [
            Text(
              getTranslated('amount_to_be_pay_admin', context)!,
              textAlign: TextAlign.center,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            PriceConverter.convertPrice(context, adminCommissionAmount),
            textAlign: TextAlign.center,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeOverLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              getTranslated('auction_commission_payment_message', context)!,
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaidCommissionWidget extends StatelessWidget {
  final double adminCommissionAmount;
  final AuctionTransactionPaymentInfo? paymentInfo;

  const _PaidCommissionWidget({
    required this.adminCommissionAmount,
    this.paymentInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(
            children: [
              Text(
                getTranslated('amount_paid', context) ?? 'Amount Paid',
                textAlign: TextAlign.center,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                PriceConverter.convertPrice(context, adminCommissionAmount),
                textAlign: TextAlign.center,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                getTranslated('successfully_completed_the_payment', context) ?? 'Successfully completed the payment.',
                textAlign: TextAlign.center,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.5,
                ),
              ),

              if (paymentInfo != null) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _PaymentInfoCard(paymentInfo: paymentInfo!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  final AuctionTransactionPaymentInfo paymentInfo;

  const _PaymentInfoCard({required this.paymentInfo});

  @override
  Widget build(BuildContext context) {
    final info = paymentInfo.methodInformations;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated('payment_info', context) ?? 'Payment info',
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if (paymentInfo.methodName != null)
            _InfoRow(
              label: getTranslated('method_name', context) ?? 'Method name',
              value: paymentInfo.methodName!,
            ),

          if (info?.mobileNumber != null)
            _InfoRow(
              label: getTranslated('mobile_number_label', context) ?? 'Mobile number',
              value: info!.mobileNumber!,
            ),

          if (info?.transactionId != null)
            _InfoRow(
              label: getTranslated('transaction_id_label', context) ?? 'Transaction ID',
              value: info!.transactionId!,
            ),

          if (info?.date != null)
            _InfoRow(
              label: getTranslated('date_label', context) ?? 'Date',
              value: info!.date!,
            ),

          if (info?.reference != null)
            _InfoRow(
              label: getTranslated('reference_label', context) ?? 'Reference',
              value: info!.reference!,
            ),

          if (paymentInfo.paymentNote != null)
            _InfoRow(
              label: getTranslated('payment_note_label', context) ?? 'Payment note',
              value: paymentInfo.paymentNote!,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Text(': ',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Expanded(
            child: Text(value,
              style: titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
