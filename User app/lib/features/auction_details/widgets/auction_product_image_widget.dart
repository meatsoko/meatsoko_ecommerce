import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionProductImageWidget extends StatelessWidget {
  final String productName;
  final String thumbnailUrl;
  final String itemCondition;
  final int totalViews;
  final int totalBids;

  const AuctionProductImageWidget({
    super.key,
    required this.productName,
    required this.thumbnailUrl,
    required this.itemCondition,
    required this.totalViews,
    required this.totalBids,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProductHeaderRow(
            productName: productName,
            thumbnailUrl: thumbnailUrl,
            itemCondition: itemCondition,
          ),
          _StatRow(
            totalViews: totalViews,
            totalBids: totalBids,
          ),
        ],
      ),
    );
  }
}

class _ProductHeaderRow extends StatelessWidget {
  final String productName;
  final String thumbnailUrl;
  final String itemCondition;

  const _ProductHeaderRow({
    required this.productName,
    required this.thumbnailUrl,
    required this.itemCondition,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(image: thumbnailUrl, width: 70, height: 70,)
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeEight),
                Row(
                  children: [
                    Text(getTranslated('item_condition', context) ?? "",
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Icon(
                      Icons.info_outline_rounded,
                      size: Dimensions.iconSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
                    Text(itemCondition,
                      style: titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final int totalViews;
  final int totalBids;

  const _StatRow({
    required this.totalViews,
    required this.totalBids,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Dimensions.radiusDefault),
          bottomRight: Radius.circular(Dimensions.radiusDefault),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              image: Images.view,
              label: getTranslated('total_views', context) ?? "",
              value: totalViews.toString(),
            ),
          ),
          Container(
            width: 0.5,
            height: 30,
            color: Theme.of(context).hintColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _StatItem(
              image: Images.gavelIcon,
              label: getTranslated('total_bids', context) ?? "",
              value: totalBids.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String image;
  final String label;
  final String value;

  const _StatItem({
    required this.image,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomAssetImageWidget(image, width: 20, height: 20),
        const SizedBox(width: Dimensions.paddingSizeEight),
        Text(label,
          style: textRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          value,
          style: titilliumBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}