import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionParticipantAddressWidget extends StatelessWidget {
  final String? shippingAddressType;
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingAddress;
  final String? shippingCityZip;

  final String? billingAddressType;
  final String? billingName;
  final String? billingPhone;
  final String? billingAddress;
  final String? billingCityZip;

  final bool isSameAsShipping;

  const AuctionParticipantAddressWidget({
    super.key,
    this.shippingAddressType,
    this.shippingName,
    this.shippingPhone,
    this.shippingAddress,
    this.shippingCityZip,
    this.billingAddressType,
    this.billingName,
    this.billingPhone,
    this.billingAddress,
    this.billingCityZip,
    this.isSameAsShipping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (isSameAsShipping) ...[
          _AddressCard(
            title: getTranslated('shipping', context)!,
            addressType: shippingAddressType,
            name: shippingName,
            phone: shippingPhone,
            address: shippingAddress,
            cityZip: shippingCityZip,
            isSameAddress: isSameAsShipping,
          ),
        ] else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AddressCard(
                    title: getTranslated('shipping', context)!,
                    addressType: shippingAddressType,
                    name: shippingName,
                    phone: shippingPhone,
                    address: shippingAddress,
                    cityZip: shippingCityZip,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  _AddressCard(
                    title: getTranslated('billing', context)!,
                    addressType: billingAddressType,
                    name: billingName,
                    phone: billingPhone,
                    address: billingAddress,
                    cityZip: billingCityZip,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String title;
  final String? addressType;
  final String? name;
  final String? phone;
  final String? address;
  final String? cityZip;
  final bool isSameAddress;

  const _AddressCard({
    required this.title,
    this.addressType,
    this.name,
    this.phone,
    this.address,
    this.cityZip,
    this.isSameAddress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSameAddress ? double.infinity : 220,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: isSameAddress ? BorderRadius.zero : BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: .15),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (addressType != null) ...[
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: Dimensions.paddingSizeExtraExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    addressType!,
                    style: titilliumSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _AddressRow(
            label: getTranslated('name', context)!,
            value: name ?? '',
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

          _AddressRow(
            label: getTranslated('phone', context)!,
            value: phone ?? '',
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

          _AddressRow(
            label: getTranslated('address', context)!,
            value: address ?? '',
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

          _AddressRow(
            label: getTranslated('city_zip', context)!,
            value: cityZip ?? '',
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          if(isSameAddress)  
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
                horizontal: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Text(
                getTranslated('shipping_and_billing_is_same', context)!,
                textAlign: TextAlign.center,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            )

        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String label;
  final String value;

  const _AddressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ',
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Text(': ',
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}