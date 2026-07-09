import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/payment_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/helper/extension_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionPaymentInfoWidget extends StatelessWidget {
  final PaymentStatus? paymentStatus;
  final String paymentMethod;
  final double paidAmount;

  const AuctionPaymentInfoWidget({
    super.key,
    this.paymentStatus,
    required this.paymentMethod,
    required this.paidAmount,
  });

  Color _statusColor(BuildContext context) => switch (paymentStatus) {
    PaymentStatus.paid    => Theme.of(context).colorScheme.onTertiaryContainer,
    PaymentStatus.unpaid  => Theme.of(context).colorScheme.error,
    PaymentStatus.pending => Theme.of(context).colorScheme.tertiary,
    null                  => Theme.of(context).colorScheme.error,
  };

  String _statusLabel(BuildContext context) => switch (paymentStatus) {
    PaymentStatus.paid    => getTranslated('paid', context)!,
    PaymentStatus.unpaid  => getTranslated('unpaid', context)!,
    PaymentStatus.pending => getTranslated('pending', context)!,
    null                  => getTranslated('unpaid', context)!,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslated('payment_info', context)!,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).hintColor.withValues(alpha: .2)),

            PaymentInfoRow(
              label: getTranslated('payment_status', context)!,
              child: Text(
                _statusLabel(context),
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: _statusColor(context),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            PaymentInfoRow(
              label: getTranslated('payment_method', context)!,
              child: Text(
                paymentMethod.toTitleCase(),
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            PaymentInfoRow(
              label: getTranslated('paid_amount', context)!,
              child: Text(
                PriceConverter.convertPrice(context, paidAmount),
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentInfoRow extends StatelessWidget {
  final String label;
  final Widget child;

  const PaymentInfoRow({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        child,
      ],
    );
  }
}