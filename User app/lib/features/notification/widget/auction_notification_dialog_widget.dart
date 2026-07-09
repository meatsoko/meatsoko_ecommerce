import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionNotificationDialogWidget extends StatelessWidget {
  final AuctionNotificationItem item;
  const AuctionNotificationDialogWidget({super.key, required this.item});

  static const _creatorTypes = {
    'auction_approved',
    'auction_denied',
    'auction_new_participation',
    'auction_new_bid',
    'auction_expired_result',
    'auction_item_claimed',
    'auction_claim_payment_verified_owner',
    'auction_withdrawal_approved',
    'auction_withdrawal_rejected',
  };

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).pop();
    if (_creatorTypes.contains(item.type)) {
      RouterHelper.getCreatorAuctionDetailsRoute(slug: item.slug ?? '', action: RouteAction.push);
    } else {
      RouterHelper.getParticipationAuctionDetailsRoute(slug: item.slug ?? '', action: RouteAction.push);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: Stack(
      children: [
        Positioned(
          right: 0, top: 0,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, opticalSize: 3),
          ),
        ),

        Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: Dimensions.paddingSizeDefault, width: double.infinity),

          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: 70, height: 70,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 2),
            ),
            child: CustomAssetImageWidget(Images.gavelIcon, width: 50, height: 50, fit: BoxFit.contain),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(item.typeLabel,
              textAlign: TextAlign.center,
              style: titilliumSemiBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Text(item.message ?? '',
              textAlign: TextAlign.center,
              style: titilliumRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),

          if (item.auctionName != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  child: CustomImageWidget(
                    image: item.imageFullUrl?.path ?? '',
                    width: 45, height: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: Text(item.auctionName!,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ]),
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          GestureDetector(
            onTap: () => _navigateToDetails(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Text(getTranslated('view_details', context) ?? 'View Details',
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
      ],
    ));
  }
}
