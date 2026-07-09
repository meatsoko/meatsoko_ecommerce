import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionProductSummaryWidget extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String productType;
  final String brand;
  final String category;
  final String itemCondition;
  final double highestBid;
  final int totalBids;

  const AuctionProductSummaryWidget({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.productType,
    required this.brand,
    required this.category,
    required this.itemCondition,
    required this.highestBid,
    required this.totalBids,
  });

  String _getLocalizedItemCondition(BuildContext context) {
    final conditionMap = {
      'NEW': 'item_condition_new',
      'LIKE_NEW': 'item_condition_like_new',
      'EXCELLENT': 'item_condition_excellent',
      'GOOD': 'item_condition_good',
      'FAIR': 'item_condition_fair',
    };
    final key = conditionMap[itemCondition] ?? itemCondition;
    return getTranslated(key, context) ?? itemCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => CustomAssetImageWidget(Images.placeholder)
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                  Text(productType,
                    style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Row(
                      children: [
                        MetaItem(label: getTranslated('brand', context)!, value: brand),

                        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: Text('|',
                            style: titilliumRegular.copyWith(
                              color: Theme.of(context).hintColor.withValues(alpha: .5),
                            ),
                          ),
                        ),

                        MetaItem(label: getTranslated('category', context)!, value: category),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    MetaItem(label: getTranslated('item_condition', context)!, value: _getLocalizedItemCondition(context)),
                  ],
                ),
              ),
            ],
          ),

          Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).hintColor.withValues(alpha: .2)),

          Text(getTranslated('bidding_info', context)!,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          MetaItem(label: getTranslated('highest_bid', context)!,
            value: PriceConverter.convertPrice(context, highestBid),
            valueFontSize: Dimensions.fontSizeLarge,
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          MetaItem(label: getTranslated('highest_bid', context)!,
            value: '$totalBids',
            valueFontSize: Dimensions.fontSizeLarge,
          ),
        ],
      ),
    );
  }
}

class MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final double? valueFontSize;

  const MetaItem({
    super.key,
    required this.label,
    required this.value,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),

          TextSpan(
            text: value,
            style: titilliumBold.copyWith(
              fontSize: valueFontSize ?? Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}