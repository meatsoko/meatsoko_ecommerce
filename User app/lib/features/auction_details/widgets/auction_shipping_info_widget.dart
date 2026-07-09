import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionShippingInfoWidget extends StatelessWidget {
  final String addressType;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String zip;

  const AuctionShippingInfoWidget({
    super.key,
    required this.addressType,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.zip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: .2),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(getTranslated('shipping', context) ?? "",
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  addressType,
                  style: titilliumSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ShippingRow(label: getTranslated('name', context) ?? "", value: name),

          ShippingRow(label: getTranslated('phone', context) ?? "", value: phone),

          ShippingRow(label: getTranslated('address', context) ?? "", value: address),

          ShippingRow(label: getTranslated('city_zip', context) ?? "", value: '$city, $zip'),
        ],
      ),
    );
  }
}

class ShippingRow extends StatelessWidget {
  final String label;
  final String value;

  const ShippingRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraExtraSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ),

          Text(' : ',
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color)),

          Expanded(
            child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}