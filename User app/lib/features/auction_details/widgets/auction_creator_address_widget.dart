import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionCreatorAddressWidget extends StatelessWidget {
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingCityZip;
  final String? shippingAddress;
  final String? billingName;
  final String? billingPhone;
  final String? billingCityZip;
  final String? billingAddress;
  final bool isSameAsShipping;

  const AuctionCreatorAddressWidget({
    super.key,
    this.shippingName,
    this.shippingPhone,
    this.shippingCityZip,
    this.shippingAddress,
    this.billingName,
    this.billingPhone,
    this.billingCityZip,
    this.billingAddress,
    this.isSameAsShipping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTranslated('shipping_address', context)!,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            AddressRow(label: getTranslated('name', context)!, value: shippingName ?? ''),
            const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

            AddressRow(label: getTranslated('phone', context)!, value: shippingPhone ?? ''),
            const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

            AddressRow(label: getTranslated('city_zip', context)!, value: shippingCityZip ?? ''),
            const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

            AddressRow(label: getTranslated('address', context)!, value: shippingAddress ?? ''),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(getTranslated('billing_address', context)!,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            if (isSameAsShipping)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Text(getTranslated('same_as_shipping_address', context)!,
                  textAlign: TextAlign.center,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              )
            else ...[
              AddressRow(label: getTranslated('name', context)!, value: billingName ?? ''),
              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

              AddressRow(label: getTranslated('phone', context)!, value: billingPhone ?? ''),
              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

              AddressRow(label: getTranslated('city_zip', context)!, value: billingCityZip ?? ''),
              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

              AddressRow(label: getTranslated('address', context)!, value: billingAddress ?? ''),
            ],
          ],
        ),
      ),
    );
  }
}

class AddressRow extends StatelessWidget {
  final String label;
  final String value;

  const AddressRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        Expanded(
          child: Text(value,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}