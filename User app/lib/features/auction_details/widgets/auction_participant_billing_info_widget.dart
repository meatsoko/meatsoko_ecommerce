import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/extension_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionParticipantBillingInfoWidget extends StatelessWidget {
  final double productPrice;
  final double shippingFee;
  final double tax;
  final double total;
  final String paymentMethod;
  final double paidAmount;

  const AuctionParticipantBillingInfoWidget({
    super.key,
    required this.productPrice,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.paidAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslated('billing_info', context)!,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            _BillingRow(
              label: getTranslated('product_price', context)!,
              value: PriceConverter.convertPrice(context, productPrice),
              isBold: true,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            _BillingRow(
              label: getTranslated('shipping_fee', context)!,
              value: PriceConverter.convertPrice(context, shippingFee),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            _BillingRow(
              label: getTranslated('tax', context)!,
              value: PriceConverter.convertPrice(context, tax),
            ),

            Divider(
              height: Dimensions.paddingSizeLarge,
              color: Theme.of(context).hintColor.withValues(alpha: .2),
            ),

            _BillingRow(
              label: getTranslated('total', context)!,
              value: PriceConverter.convertPrice(context, total),
              isBold: true,
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            _BillingRow(
              label: '${getTranslated('paid_by', context)!} ${paymentMethod.toTitleCase()}',
              value: PriceConverter.convertPrice(context, paidAmount),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _BillingRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: (isBold ? titilliumBold : titilliumRegular).copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Text(
          value,
          style: (isBold ? titilliumBold : titilliumRegular).copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}