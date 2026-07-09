import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionOrderPlaceBottomSheetWidget extends StatelessWidget {
  final String? title;
  final String? description;

  const AuctionOrderPlaceBottomSheetWidget({
    super.key,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Close button
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 30,
                width: 30,
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Theme.of(context).textTheme.titleMedium!.color,
                ),
              ),
            ),
          ),

          // Success icon
          CustomAssetImageWidget(Images.orderSuccessIcon, height: 60, width: 60),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Title
          Text(
            title ?? getTranslated('auction_claimed_successfully', Get.context!) ?? '',
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Description
          Text(
            description ?? getTranslated('your_auction_claimed_successfully', Get.context!) ?? '',
            textAlign: TextAlign.center,
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          // Explore More Items button — routes to auction dashboard
          SizedBox(
            height: 45,
            width: 200,
            child: CustomButton(
              radius: 5,
              buttonText: getTranslated('explore_more_items', context),
              onTap: () {
                RouterHelper.getDashboardRoute(
                  action: RouteAction.pushReplacement,
                  page: 'auction',
                );
              },
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}
